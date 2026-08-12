#![deny(unsafe_op_in_unsafe_fn)]

use bingo_abi::{
    BingoObjectHeaderV1, BingoPropertyDescriptorV1, BingoShapeDescriptorV1, BingoTraceDescriptorV1,
};
use core::alloc::Layout;
use core::mem::{align_of, size_of};
use core::ptr::NonNull;
use std::alloc::{alloc_zeroed, dealloc};
use std::collections::HashMap;

const GC_MARK_BIT: usize = 1;

/// HeapError identifies a stable failure at the raw heap boundary.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum HeapError {
    InvalidArgument,
    OutOfMemory,
    CorruptHeap,
}

/// HeapStats reports the live allocation set after the latest completed operation.
#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub struct HeapStats {
    pub allocated_objects: usize,
    pub allocated_bytes: usize,
    pub collections: usize,
}

struct Allocation {
    pointer: NonNull<u8>,
    layout: Layout,
    pointer_offsets: Vec<usize>,
    marked: bool,
}

/// Heap owns one non-moving, precise mark-sweep allocation domain.
///
/// Heap itself does not synchronize. The runtime wrapper confines it to one
/// owning mutator and stops that mutator before calling [`Heap::collect`].
pub struct Heap {
    allocations: Vec<Allocation>,
    allocation_index: HashMap<usize, usize>,
    stats: HeapStats,
}

// Heap moves only as an owner of allocation addresses. The runtime mutex and
// owning-thread check prevent the pointed-to Bingo objects from being accessed
// concurrently after such a move.
unsafe impl Send for Heap {}

impl Heap {
    /// Creates an empty allocation domain with no roots or global state.
    pub fn new() -> Self {
        Self {
            allocations: Vec::new(),
            allocation_index: HashMap::new(),
            stats: HeapStats::default(),
        }
    }

    /// Allocates and zero-initializes one object described by `shape`.
    ///
    /// # Safety
    ///
    /// `shape`, its trace descriptor, and its pointer-offset array must remain
    /// readable for the duration of this call. They normally refer to frozen
    /// compiler-emitted metadata. The returned object remains valid until a
    /// collection proves it unreachable or this heap is reset/dropped.
    pub unsafe fn allocate(
        &mut self,
        shape: *const BingoShapeDescriptorV1,
    ) -> Result<*mut BingoObjectHeaderV1, HeapError> {
        let (layout, pointer_offsets) = unsafe { validate_shape(shape)? };

        // SAFETY: layout was validated above. A null result is handled as OOM
        // before any pointer is dereferenced.
        let raw = unsafe { alloc_zeroed(layout) };
        let pointer = NonNull::new(raw).ok_or(HeapError::OutOfMemory)?;
        let header = pointer.as_ptr().cast::<BingoObjectHeaderV1>();
        // SAFETY: the allocation is at least a complete, correctly aligned
        // header and is exclusively owned by this Heap.
        unsafe {
            header.write(BingoObjectHeaderV1 {
                descriptor: shape.cast(),
                size_bytes: layout.size(),
                gc_word: 0,
            });
        }
        let index = self.allocations.len();
        self.allocation_index.insert(header as usize, index);
        self.allocations.push(Allocation {
            pointer,
            layout,
            pointer_offsets,
            marked: false,
        });
        self.stats.allocated_objects += 1;
        self.stats.allocated_bytes += layout.size();
        Ok(header)
    }

    /// Collects every allocation not reachable from the exact root list.
    pub fn collect(&mut self, roots: &[*mut BingoObjectHeaderV1]) -> Result<(), HeapError> {
        if let Err(error) = self.mark(roots) {
            self.clear_marks();
            return Err(error);
        }
        self.sweep();
        self.stats.collections += 1;
        Ok(())
    }

    /// Returns whether `value` is null or belongs to this heap.
    pub fn contains_or_null(&self, value: *mut BingoObjectHeaderV1) -> bool {
        value.is_null() || self.allocation_index.contains_key(&(value as usize))
    }

    /// Compares a heap object's authenticated descriptor with a readable
    /// compiler-emitted target descriptor by value rather than module-local address.
    ///
    /// # Safety
    /// `target` and all descriptor arrays/keys reachable from it must remain
    /// readable for this call.
    pub unsafe fn shape_matches(
        &self,
        object: *mut BingoObjectHeaderV1,
        target: *const BingoShapeDescriptorV1,
    ) -> Result<bool, HeapError> {
        if !self.allocation_index.contains_key(&(object as usize)) || target.is_null() {
            return Err(HeapError::InvalidArgument);
        }
        // SAFETY: membership proves object is a live allocation with a complete header.
        let source = unsafe { (*object).descriptor.cast::<BingoShapeDescriptorV1>() };
        // SAFETY: source was validated at allocation; target readability is the caller contract.
        unsafe { structurally_equal_shapes(source, target) }
    }

    /// Validates the v1 semantic write-barrier boundary.
    pub fn validate_barrier(
        &self,
        owner: *mut BingoObjectHeaderV1,
        slot_offset: usize,
        value: *mut BingoObjectHeaderV1,
    ) -> Result<(), HeapError> {
        let Some(&index) = self.allocation_index.get(&(owner as usize)) else {
            return Err(HeapError::InvalidArgument);
        };
        if !self.contains_or_null(value)
            || self.allocations[index]
                .pointer_offsets
                .binary_search(&slot_offset)
                .is_err()
        {
            return Err(HeapError::InvalidArgument);
        }
        Ok(())
    }

    /// Returns current live-allocation and completed-collection counters.
    pub fn stats(&self) -> HeapStats {
        self.stats
    }

    /// Releases every allocation and restores empty-heap counters.
    pub fn reset(&mut self) {
        for allocation in self.allocations.drain(..) {
            // SAFETY: each allocation was obtained with this exact layout and
            // is removed exactly once from the owning Heap.
            unsafe { dealloc(allocation.pointer.as_ptr(), allocation.layout) };
        }
        self.allocation_index.clear();
        self.stats = HeapStats::default();
    }

    fn mark(&mut self, roots: &[*mut BingoObjectHeaderV1]) -> Result<(), HeapError> {
        let mut worklist = Vec::with_capacity(roots.len());
        for &root in roots {
            if root.is_null() {
                continue;
            }
            if !self.allocation_index.contains_key(&(root as usize)) {
                return Err(HeapError::CorruptHeap);
            }
            worklist.push(root as usize);
        }

        while let Some(address) = worklist.pop() {
            let Some(&index) = self.allocation_index.get(&address) else {
                return Err(HeapError::CorruptHeap);
            };
            if self.allocations[index].marked {
                continue;
            }
            self.allocations[index].marked = true;
            let header = self.allocations[index]
                .pointer
                .as_ptr()
                .cast::<BingoObjectHeaderV1>();
            // SAFETY: header points at a live allocation owned exclusively by
            // this stopped heap.
            unsafe { (*header).gc_word |= GC_MARK_BIT };

            for &offset in &self.allocations[index].pointer_offsets {
                // SAFETY: offsets were copied only after complete bounds and
                // alignment validation, and the object is still allocated.
                let child = unsafe {
                    *self.allocations[index]
                        .pointer
                        .as_ptr()
                        .add(offset)
                        .cast::<*mut BingoObjectHeaderV1>()
                };
                if child.is_null() {
                    continue;
                }
                if !self.allocation_index.contains_key(&(child as usize)) {
                    return Err(HeapError::CorruptHeap);
                }
                worklist.push(child as usize);
            }
        }
        Ok(())
    }

    fn clear_marks(&mut self) {
        for allocation in &mut self.allocations {
            allocation.marked = false;
            let header = allocation.pointer.as_ptr().cast::<BingoObjectHeaderV1>();
            // SAFETY: every entry remains owned and allocated during this pass.
            unsafe { (*header).gc_word &= !GC_MARK_BIT };
        }
    }

    fn sweep(&mut self) {
        let mut survivors = Vec::with_capacity(self.allocations.len());
        for mut allocation in self.allocations.drain(..) {
            if allocation.marked {
                allocation.marked = false;
                let header = allocation.pointer.as_ptr().cast::<BingoObjectHeaderV1>();
                // SAFETY: this allocation survives and remains exclusively owned.
                unsafe { (*header).gc_word &= !GC_MARK_BIT };
                survivors.push(allocation);
            } else {
                self.stats.allocated_objects -= 1;
                self.stats.allocated_bytes -= allocation.layout.size();
                // SAFETY: unreachable allocation is removed once with its
                // original allocation layout.
                unsafe { dealloc(allocation.pointer.as_ptr(), allocation.layout) };
            }
        }
        self.allocations = survivors;
        self.rebuild_index();
    }

    fn rebuild_index(&mut self) {
        self.allocation_index.clear();
        for (index, allocation) in self.allocations.iter().enumerate() {
            self.allocation_index.insert(
                allocation.pointer.as_ptr().cast::<BingoObjectHeaderV1>() as usize,
                index,
            );
        }
    }
}

impl Default for Heap {
    fn default() -> Self {
        Self::new()
    }
}

impl Drop for Heap {
    fn drop(&mut self) {
        self.reset();
    }
}

unsafe fn validate_shape(
    shape: *const BingoShapeDescriptorV1,
) -> Result<(Layout, Vec<usize>), HeapError> {
    let shape = unsafe { shape.as_ref() }.ok_or(HeapError::InvalidArgument)?;
    if shape.schema_version != 1
        || shape.object_size < size_of::<BingoObjectHeaderV1>()
        || shape.object_align < align_of::<BingoObjectHeaderV1>()
    {
        return Err(HeapError::InvalidArgument);
    }
    let layout = Layout::from_size_align(shape.object_size, shape.object_align)
        .map_err(|_| HeapError::InvalidArgument)?;
    let trace = unsafe { (shape.trace as *const BingoTraceDescriptorV1).as_ref() }
        .ok_or(HeapError::InvalidArgument)?;
    if trace.schema_version != 1
        || trace.object_size != shape.object_size
        || trace.pointer_map_words != 0
        || !trace.trace_callback.is_null()
        || trace.pointer_count as usize > shape.object_size / size_of::<usize>()
    {
        return Err(HeapError::InvalidArgument);
    }
    if trace.pointer_count != 0 && trace.pointer_offsets.is_null() {
        return Err(HeapError::InvalidArgument);
    }
    let offsets = if trace.pointer_count == 0 {
        &[][..]
    } else {
        // SAFETY: the caller contract makes the descriptor array readable;
        // pointer_count was bounded by the containing object size above.
        unsafe {
            core::slice::from_raw_parts(
                trace.pointer_offsets.cast::<u32>(),
                trace.pointer_count as usize,
            )
        }
    };
    let mut result = Vec::with_capacity(offsets.len());
    for (index, &offset) in offsets.iter().enumerate() {
        let offset = offset as usize;
        if offset < size_of::<BingoObjectHeaderV1>()
            || !offset.is_multiple_of(align_of::<*mut BingoObjectHeaderV1>())
            || offset
                .checked_add(size_of::<*mut BingoObjectHeaderV1>())
                .is_none_or(|end| end > shape.object_size)
            || index > 0 && result[index - 1] >= offset
        {
            return Err(HeapError::InvalidArgument);
        }
        result.push(offset);
    }
    Ok((layout, result))
}

unsafe fn structurally_equal_shapes(
    source: *const BingoShapeDescriptorV1,
    target: *const BingoShapeDescriptorV1,
) -> Result<bool, HeapError> {
    let (source_layout, _) = unsafe { validate_shape(source)? };
    let (target_layout, _) = unsafe { validate_shape(target)? };
    // SAFETY: validate_shape proved both top-level and trace pointers readable.
    let source = unsafe { &*source };
    let target = unsafe { &*target };
    let source_properties = unsafe { validated_shape_properties(source, false)? };
    let target_properties = unsafe { validated_shape_properties(target, true)? };
    if source.schema_version != target.schema_version
        || source.flags != target.flags
        || source_layout.size() < target_layout.size()
        || source_layout.align() < target_layout.align()
    {
        return Ok(false);
    }
    if source_properties.len() < target_properties.len() {
        return Ok(false);
    }
    for right in target_properties {
        let Some(left) = source_properties
            .iter()
            .find(|left| unsafe { descriptor_keys_equal(left.key, right.key) }.unwrap_or(false))
        else {
            return Ok(false);
        };
        if left.kind != right.kind
            || left.flags != right.flags
            || left.reserved != right.reserved
            || left.field_offset != right.field_offset
            || left.presence_bit != right.presence_bit
            || left.slot != right.slot
            || !left.value_descriptor.is_null()
            || !right.value_descriptor.is_null()
        {
            return Ok(false);
        }
    }
    Ok(true)
}

unsafe fn validated_shape_properties(
    shape: &BingoShapeDescriptorV1,
    required_data_target: bool,
) -> Result<&[BingoPropertyDescriptorV1], HeapError> {
    if shape.property_count > 1024 || shape.property_count != 0 && shape.properties.is_null() {
        return Err(HeapError::InvalidArgument);
    }
    let properties: &[BingoPropertyDescriptorV1] = if shape.property_count == 0 {
        &[][..]
    } else {
        unsafe {
            core::slice::from_raw_parts(shape.properties.cast(), shape.property_count as usize)
        }
    };
    for (index, property) in properties.iter().enumerate() {
        if (property.kind != 1 && property.kind != 2)
            || required_data_target && property.kind != 1
            || property.flags != 0
            || property.reserved != 0
            || required_data_target && property.presence_bit != u32::MAX
            || property.enumeration_order != index as u32
            || property.kind == 1
                && (property.field_offset < size_of::<BingoObjectHeaderV1>() as u32
                    || property.field_offset as usize + size_of::<*mut BingoObjectHeaderV1>()
                        > shape.object_size)
            || property.kind == 2 && property.field_offset != 0
            || !property.value_descriptor.is_null()
        {
            return Err(HeapError::InvalidArgument);
        }
        unsafe { descriptor_key_length(property.key)? };
    }
    Ok(properties)
}

unsafe fn descriptor_key_length(key: *const core::ffi::c_void) -> Result<usize, HeapError> {
    if key.is_null() {
        return Err(HeapError::InvalidArgument);
    }
    let key = key.cast::<u8>();
    for length in 0..=1024 {
        // SAFETY: descriptor key readability and NUL termination within the
        // bounded ABI limit are required by the compiler-emitted descriptor contract.
        if unsafe { *key.add(length) } == 0 {
            return Ok(length);
        }
    }
    Err(HeapError::InvalidArgument)
}

unsafe fn descriptor_keys_equal(
    left: *const core::ffi::c_void,
    right: *const core::ffi::c_void,
) -> Result<bool, HeapError> {
    let left_length = unsafe { descriptor_key_length(left)? };
    let right_length = unsafe { descriptor_key_length(right)? };
    if left_length != right_length {
        return Ok(false);
    }
    // SAFETY: both bounded lengths were established by descriptor_key_length.
    Ok(
        unsafe { core::slice::from_raw_parts(left.cast::<u8>(), left_length) }
            == unsafe { core::slice::from_raw_parts(right.cast::<u8>(), right_length) },
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use core::ffi::c_void;

    struct DescriptorFixture {
        offsets: Vec<u32>,
        trace: Box<BingoTraceDescriptorV1>,
        shape: Box<BingoShapeDescriptorV1>,
    }

    impl DescriptorFixture {
        fn new(offsets: Vec<u32>) -> Self {
            let object_size = size_of::<BingoObjectHeaderV1>() + size_of::<usize>();
            let mut fixture = Self {
                offsets,
                trace: Box::new(BingoTraceDescriptorV1 {
                    schema_version: 1,
                    flags: 0,
                    object_size,
                    pointer_count: 0,
                    pointer_map_words: 0,
                    pointer_offsets: core::ptr::null(),
                    trace_callback: core::ptr::null(),
                }),
                shape: Box::new(BingoShapeDescriptorV1 {
                    schema_version: 1,
                    flags: 0,
                    object_size,
                    object_align: align_of::<usize>(),
                    property_count: 0,
                    presence_word_count: 0,
                    properties: core::ptr::null(),
                    trace: core::ptr::null(),
                }),
            };
            fixture.trace.pointer_count = fixture.offsets.len() as u32;
            fixture.trace.pointer_offsets = if fixture.offsets.is_empty() {
                core::ptr::null()
            } else {
                fixture.offsets.as_ptr().cast::<c_void>()
            };
            fixture.shape.trace = (&*fixture.trace as *const BingoTraceDescriptorV1).cast();
            fixture
        }

        fn shape(&self) -> *const BingoShapeDescriptorV1 {
            &*self.shape
        }
    }

    fn pointer_offset() -> usize {
        size_of::<BingoObjectHeaderV1>()
    }

    unsafe fn store_reference(owner: *mut BingoObjectHeaderV1, value: *mut BingoObjectHeaderV1) {
        // SAFETY: test descriptors reserve one aligned pointer-sized field at
        // pointer_offset and both objects remain owned by the test heap.
        unsafe {
            owner
                .cast::<u8>()
                .add(pointer_offset())
                .cast::<*mut BingoObjectHeaderV1>()
                .write(value);
        }
    }

    #[test]
    fn rooted_cycle_survives_then_is_swept() {
        let fixture = DescriptorFixture::new(vec![pointer_offset() as u32]);
        let mut heap = Heap::new();
        // SAFETY: fixture owns readable descriptors for the duration of calls.
        let left = unsafe { heap.allocate(fixture.shape()) }.unwrap();
        // SAFETY: fixture owns readable descriptors for the duration of calls.
        let right = unsafe { heap.allocate(fixture.shape()) }.unwrap();
        // SAFETY: both objects have the fixture's pointer field.
        unsafe {
            store_reference(left, right);
            store_reference(right, left);
        }

        heap.collect(&[left]).unwrap();
        assert_eq!(heap.stats().allocated_objects, 2);
        assert!(heap.contains_or_null(left));
        assert!(heap.contains_or_null(right));

        heap.collect(&[]).unwrap();
        assert_eq!(heap.stats().allocated_objects, 0);
        assert_eq!(heap.stats().collections, 2);
    }

    #[test]
    fn cycle_and_root_stress_keeps_stable_addresses() {
        const OBJECTS: usize = 4096;

        let fixture = DescriptorFixture::new(vec![pointer_offset() as u32]);
        let mut heap = Heap::new();
        let mut objects = Vec::with_capacity(OBJECTS);
        for _ in 0..OBJECTS {
            // SAFETY: fixture owns readable descriptors for the duration of calls.
            objects.push(unsafe { heap.allocate(fixture.shape()) }.unwrap());
        }
        for index in 0..OBJECTS {
            // SAFETY: every object has one traced reference field, and the
            // modulo edge creates a complete reachable cycle.
            unsafe { store_reference(objects[index], objects[(index + 1) % OBJECTS]) };
        }

        for _ in 0..8 {
            heap.collect(&[objects[0]]).unwrap();
            assert_eq!(heap.stats().allocated_objects, OBJECTS);
            assert!(objects.iter().all(|value| heap.contains_or_null(*value)));
        }
        heap.collect(&[]).unwrap();
        assert_eq!(heap.stats().allocated_objects, 0);
    }

    #[test]
    fn collection_uses_only_exact_roots() {
        let fixture = DescriptorFixture::new(Vec::new());
        let mut heap = Heap::new();
        // SAFETY: fixture owns readable descriptors for the duration of calls.
        let live = unsafe { heap.allocate(fixture.shape()) }.unwrap();
        // SAFETY: fixture owns readable descriptors for the duration of calls.
        let dead = unsafe { heap.allocate(fixture.shape()) }.unwrap();

        heap.collect(&[live, core::ptr::null_mut()]).unwrap();
        assert!(heap.contains_or_null(live));
        assert!(!heap.contains_or_null(dead));
        // SAFETY: live survived the collection and remains heap-owned.
        assert_eq!(unsafe { live.as_ref().unwrap() }.gc_word, 0);
    }

    #[test]
    fn rejects_foreign_root_and_reachable_reference() {
        let plain = DescriptorFixture::new(Vec::new());
        let traced = DescriptorFixture::new(vec![pointer_offset() as u32]);
        let mut heap = Heap::new();
        let mut foreign_header = BingoObjectHeaderV1 {
            descriptor: core::ptr::null(),
            size_bytes: 0,
            gc_word: 0,
        };
        assert_eq!(
            heap.collect(&[&mut foreign_header]),
            Err(HeapError::CorruptHeap)
        );

        // SAFETY: fixture owns readable descriptors for the duration of calls.
        let owner = unsafe { heap.allocate(traced.shape()) }.unwrap();
        // SAFETY: the owner has the traced pointer field; the intentionally
        // foreign value is never dereferenced because membership fails first.
        unsafe { store_reference(owner, &mut foreign_header) };
        assert_eq!(heap.collect(&[owner]), Err(HeapError::CorruptHeap));
        assert_eq!(heap.stats().allocated_objects, 1);

        // A subsequent reset remains valid after the failed mark attempt.
        heap.reset();
        // SAFETY: the plain fixture remains readable and proves reuse.
        assert!(unsafe { heap.allocate(plain.shape()) }.is_ok());
    }

    #[test]
    fn rejects_malformed_trace_layouts_and_barriers() {
        let mut duplicate =
            DescriptorFixture::new(vec![pointer_offset() as u32, pointer_offset() as u32]);
        let mut heap = Heap::new();
        // SAFETY: descriptor memory is readable but semantically malformed.
        assert_eq!(
            unsafe { heap.allocate(duplicate.shape()) },
            Err(HeapError::InvalidArgument)
        );

        duplicate.trace.pointer_count = 1;
        duplicate.offsets[0] = 1;
        // SAFETY: descriptor memory is readable but the offset is unaligned.
        assert_eq!(
            unsafe { heap.allocate(duplicate.shape()) },
            Err(HeapError::InvalidArgument)
        );

        let fixture = DescriptorFixture::new(vec![pointer_offset() as u32]);
        // SAFETY: fixture owns readable descriptors for the duration of calls.
        let owner = unsafe { heap.allocate(fixture.shape()) }.unwrap();
        assert_eq!(
            heap.validate_barrier(owner, pointer_offset(), core::ptr::null_mut()),
            Ok(())
        );
        assert_eq!(
            heap.validate_barrier(owner, pointer_offset() + 8, core::ptr::null_mut()),
            Err(HeapError::InvalidArgument)
        );
    }
}
