#![deny(unsafe_op_in_unsafe_fn)]

use bingo_abi::{
    BINGO_DYNAMIC_EXCEPTION, BINGO_GC_CORRUPT_HEAP, BINGO_GC_FRAME_STATE,
    BINGO_GC_INVALID_ARGUMENT, BINGO_GC_OK, BINGO_GC_OUT_OF_MEMORY, BINGO_GC_WRONG_THREAD,
    BingoDynamicValueV1, BingoGcFrameV1, BingoGcStatsV1, BingoHostNumberPropertyV1,
    BingoObjectHeaderV1, BingoShapeDescriptorV1, BingoUtf16ViewV1,
};
use bingo_memory::{Heap, HeapError};
use std::collections::HashMap;
use std::sync::{Mutex, OnceLock};
use std::thread::{self, ThreadId};

fn abi_version() -> u32 {
    bingo_abi::RUNTIME_ABI_VERSION
}

struct RuntimeState {
    owner: Option<ThreadId>,
    heap: Heap,
    frames: Vec<usize>,
    host_objects: HashMap<u64, HostObject>,
    next_host_handle: u64,
}

const DYNAMIC_TAG_UNDEFINED: u32 = 0;
const DYNAMIC_TAG_OBJECT: u32 = 1;
const DYNAMIC_TAG_NUMBER: u32 = 2;
const MAX_DYNAMIC_KEY_UNITS: u64 = 1 << 20;
const MAX_HOST_RECORD_PROPERTIES: u64 = 1 << 10;

#[derive(Clone, Copy)]
pub enum HostProperty {
    Number(u64),
    Accessor(fn() -> Result<u64, ()>),
}

struct HostObject {
    properties: HashMap<Vec<u16>, HostProperty>,
}

impl RuntimeState {
    fn new() -> Self {
        Self {
            owner: None,
            heap: Heap::new(),
            frames: Vec::new(),
            host_objects: HashMap::new(),
            next_host_handle: 1,
        }
    }

    fn claim_current_thread(&mut self) -> Result<(), u32> {
        let current = thread::current().id();
        match &self.owner {
            Some(owner) if *owner != current => Err(BINGO_GC_WRONG_THREAD),
            Some(_) => Ok(()),
            None => {
                self.owner = Some(current);
                Ok(())
            }
        }
    }

    fn current_frame(&self, frame: *mut BingoGcFrameV1) -> Result<(), u32> {
        if frame.is_null() || self.frames.last().copied() != Some(frame as usize) {
            return Err(BINGO_GC_FRAME_STATE);
        }
        Ok(())
    }

    fn collect(&mut self) -> Result<(), u32> {
        // SAFETY: linked frames are admitted only by frame_link. The owning
        // mutator is stopped while the mutex is held. collect_roots still
        // revalidates every mutable frame field before reading caller slots.
        let roots = unsafe { self.collect_roots()? };
        self.heap.collect(&roots).map_err(status_for_heap_error)
    }

    unsafe fn collect_roots(&self) -> Result<Vec<*mut BingoObjectHeaderV1>, u32> {
        let mut roots = Vec::new();
        for (index, &address) in self.frames.iter().enumerate().rev() {
            let frame = address as *const BingoGcFrameV1;
            // SAFETY: frame_link required a readable frame that remains live
            // until LIFO unlink; owning-mutator confinement excludes races.
            let frame = unsafe { &*frame };
            if frame.reserved != 0
                || frame.slot_count > 64
                || frame.slot_count != 0 && frame.slots.is_null()
                || frame.active_bits & !active_mask(frame.slot_count) != 0
                || frame.previous as usize
                    != index
                        .checked_sub(1)
                        .map_or(0, |previous| self.frames[previous])
            {
                return Err(BINGO_GC_FRAME_STATE);
            }
            for slot in 0..frame.slot_count {
                if frame.active_bits & (1_u64 << slot) == 0 {
                    continue;
                }
                // SAFETY: slot_count and slots were validated above; the frame
                // contract keeps the caller-owned array alive while linked.
                roots.push(unsafe { *frame.slots.add(slot as usize) });
            }
        }
        Ok(roots)
    }
}

fn active_mask(slot_count: u32) -> u64 {
    if slot_count == 64 {
        u64::MAX
    } else {
        (1_u64 << slot_count) - 1
    }
}

fn status_for_heap_error(error: HeapError) -> u32 {
    match error {
        HeapError::InvalidArgument => BINGO_GC_INVALID_ARGUMENT,
        HeapError::OutOfMemory => BINGO_GC_OUT_OF_MEMORY,
        HeapError::CorruptHeap => BINGO_GC_CORRUPT_HEAP,
    }
}

fn with_runtime(operation: impl FnOnce(&mut RuntimeState) -> u32) -> u32 {
    let Ok(mut state) = runtime().lock() else {
        return BINGO_GC_CORRUPT_HEAP;
    };
    if let Err(status) = state.claim_current_thread() {
        return status;
    }
    operation(&mut state)
}

fn runtime() -> &'static Mutex<RuntimeState> {
    static RUNTIME: OnceLock<Mutex<RuntimeState>> = OnceLock::new();
    RUNTIME.get_or_init(|| Mutex::new(RuntimeState::new()))
}

fn gc_heap_reset() -> u32 {
    with_runtime(|state| {
        if !state.frames.is_empty() {
            return BINGO_GC_FRAME_STATE;
        }
        state.heap.reset();
        state.host_objects.clear();
        BINGO_GC_OK
    })
}

fn gc_alloc(
    shape: *const BingoShapeDescriptorV1,
    out_object: *mut *mut BingoObjectHeaderV1,
) -> u32 {
    if out_object.is_null() {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    // Clear the out-parameter before entering any fallible boundary path.
    // SAFETY: the ABI contract requires a writable out-parameter.
    unsafe { out_object.write(core::ptr::null_mut()) };
    with_runtime(|state| {
        // SAFETY: compiler-emitted descriptors are frozen and readable. The
        // memory crate validates all semantic layout fields before allocation.
        match unsafe { state.heap.allocate(shape) } {
            Ok(object) => {
                // SAFETY: out_object was checked above and remains exclusively
                // borrowed for this ABI call.
                unsafe { out_object.write(object) };
                BINGO_GC_OK
            }
            Err(error) => status_for_heap_error(error),
        }
    })
}

fn gc_frame_link(frame: *mut BingoGcFrameV1) -> u32 {
    if frame.is_null() {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    with_runtime(|state| {
        // SAFETY: the ABI contract supplies a writable frame lasting until
        // unlink. All fields are validated before it becomes reachable.
        let frame_ref = unsafe { &mut *frame };
        if !frame_ref.previous.is_null()
            || frame_ref.reserved != 0
            || frame_ref.slot_count > 64
            || frame_ref.slot_count != 0 && frame_ref.slots.is_null()
            || frame_ref.active_bits != 0
        {
            return BINGO_GC_FRAME_STATE;
        }
        if state.frames.try_reserve(1).is_err() {
            return BINGO_GC_OUT_OF_MEMORY;
        }
        frame_ref.previous = state.frames.last().copied().unwrap_or(0) as *mut BingoGcFrameV1;
        state.frames.push(frame as usize);
        BINGO_GC_OK
    })
}

fn gc_frame_unlink(frame: *mut BingoGcFrameV1) -> u32 {
    with_runtime(|state| {
        if let Err(status) = state.current_frame(frame) {
            return status;
        }
        // SAFETY: current_frame proves this is the linked head owned by the
        // stopped mutator.
        let frame_ref = unsafe { &mut *frame };
        state.frames.pop();
        frame_ref.previous = core::ptr::null_mut();
        frame_ref.active_bits = 0;
        BINGO_GC_OK
    })
}

fn gc_root_store(frame: *mut BingoGcFrameV1, slot: u32, value: *mut BingoObjectHeaderV1) -> u32 {
    with_runtime(|state| {
        if let Err(status) = state.current_frame(frame) {
            return status;
        }
        if !state.heap.contains_or_null(value) {
            return BINGO_GC_INVALID_ARGUMENT;
        }
        // SAFETY: current_frame proves readability. slot bounds and the slot
        // array are checked before the caller-owned location is written.
        let frame_ref = unsafe { &mut *frame };
        if slot >= frame_ref.slot_count || frame_ref.slots.is_null() {
            return BINGO_GC_INVALID_ARGUMENT;
        }
        // SAFETY: slot is strictly below slot_count and slots is non-null.
        unsafe { frame_ref.slots.add(slot as usize).write(value) };
        BINGO_GC_OK
    })
}

fn gc_root_clear(frame: *mut BingoGcFrameV1, slot: u32) -> u32 {
    gc_root_store(frame, slot, core::ptr::null_mut())
}

fn gc_root_publish(frame: *mut BingoGcFrameV1, active_bits: u64) -> u32 {
    with_runtime(|state| {
        if let Err(status) = state.current_frame(frame) {
            return status;
        }
        // SAFETY: current_frame proves this is the current linked frame.
        let frame_ref = unsafe { &mut *frame };
        if active_bits & !active_mask(frame_ref.slot_count) != 0 {
            return BINGO_GC_INVALID_ARGUMENT;
        }
        frame_ref.active_bits = active_bits;
        BINGO_GC_OK
    })
}

fn gc_root_reload(
    frame: *mut BingoGcFrameV1,
    slot: u32,
    out_object: *mut *mut BingoObjectHeaderV1,
) -> u32 {
    if out_object.is_null() {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    // SAFETY: the ABI contract requires a writable out-parameter.
    unsafe { out_object.write(core::ptr::null_mut()) };
    with_runtime(|state| {
        if let Err(status) = state.current_frame(frame) {
            return status;
        }
        // SAFETY: current_frame proves readability; bounds are checked before
        // loading from the caller-owned slot array.
        let frame_ref = unsafe { &*frame };
        if slot >= frame_ref.slot_count || frame_ref.slots.is_null() {
            return BINGO_GC_INVALID_ARGUMENT;
        }
        // SAFETY: slot is strictly below slot_count and both pointers are valid
        // for this call.
        unsafe { out_object.write(*frame_ref.slots.add(slot as usize)) };
        BINGO_GC_OK
    })
}

fn gc_safepoint() -> u32 {
    gc_collect()
}

fn gc_collect() -> u32 {
    with_runtime(|state| match state.collect() {
        Ok(()) => BINGO_GC_OK,
        Err(status) => status,
    })
}

fn gc_write_barrier(
    owner: *mut BingoObjectHeaderV1,
    slot_offset: u32,
    value: *mut BingoObjectHeaderV1,
) -> u32 {
    with_runtime(|state| {
        match state
            .heap
            .validate_barrier(owner, slot_offset as usize, value)
        {
            Ok(()) => BINGO_GC_OK,
            Err(error) => status_for_heap_error(error),
        }
    })
}

fn gc_stats(out_stats: *mut BingoGcStatsV1) -> u32 {
    if out_stats.is_null() {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    with_runtime(|state| {
        let stats = state.heap.stats();
        // SAFETY: the ABI contract requires a writable out-parameter, checked
        // before entering the runtime lock.
        unsafe {
            out_stats.write(BingoGcStatsV1 {
                allocated_objects: stats.allocated_objects,
                allocated_bytes: stats.allocated_bytes,
                collections: stats.collections,
            });
        }
        BINGO_GC_OK
    })
}

fn shape_matches(
    object: *mut BingoObjectHeaderV1,
    target_shape: *const BingoShapeDescriptorV1,
    out_match: *mut u8,
) -> u32 {
    if object.is_null() || target_shape.is_null() || out_match.is_null() {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    // Clear the result before any fallible validation path.
    unsafe { out_match.write(0) };
    with_runtime(|state| {
        if !state.heap.contains_or_null(object) {
            return BINGO_GC_INVALID_ARGUMENT;
        }
        // SAFETY: target_shape is a readable compiler-emitted descriptor by
        // ABI contract; Heap first authenticates object ownership, then
        // validates and structurally compares both descriptors.
        match unsafe { state.heap.shape_matches(object, target_shape) } {
            Ok(matches) => {
                unsafe { out_match.write(matches as u8) };
                BINGO_GC_OK
            }
            Err(error) => status_for_heap_error(error),
        }
    })
}

fn dynamic_property_load(
    receiver: BingoDynamicValueV1,
    key: BingoUtf16ViewV1,
    out_value: *mut BingoDynamicValueV1,
) -> u32 {
    if out_value.is_null() {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    // SAFETY: the ABI requires a writable result slot, checked above.
    unsafe {
        out_value.write(BingoDynamicValueV1 {
            tag: DYNAMIC_TAG_UNDEFINED,
            reserved: 0,
            payload: 0,
        });
    }
    if receiver.tag != DYNAMIC_TAG_OBJECT
        || receiver.reserved != 0
        || receiver.payload == 0
        || key.length > MAX_DYNAMIC_KEY_UNITS
        || key.length > usize::MAX as u64
        || (key.length != 0 && key.data.is_null())
    {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    let key = if key.length == 0 {
        &[]
    } else {
        // SAFETY: the host owns the readable UTF-16 view for the duration of
        // this call; null and platform length overflow were rejected above.
        unsafe { core::slice::from_raw_parts(key.data, key.length as usize) }
    };
    with_runtime(|state| {
        let Some(object) = state.host_objects.get(&receiver.payload) else {
            return BINGO_GC_INVALID_ARGUMENT;
        };
        let Some(property) = object.properties.get(key).copied() else {
            return BINGO_GC_OK;
        };
        let bits = match property {
            HostProperty::Number(bits) => bits,
            HostProperty::Accessor(accessor) => match accessor() {
                Ok(bits) => bits,
                Err(()) => return BINGO_DYNAMIC_EXCEPTION,
            },
        };
        // SAFETY: out_value is exclusively writable for this call.
        unsafe {
            out_value.write(BingoDynamicValueV1 {
                tag: DYNAMIC_TAG_NUMBER,
                reserved: 0,
                payload: bits,
            });
        }
        BINGO_GC_OK
    })
}

fn host_number_record_register(
    properties: *const BingoHostNumberPropertyV1,
    property_count: u64,
    out_object: *mut BingoDynamicValueV1,
) -> u32 {
    if out_object.is_null() {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    // SAFETY: the ABI requires a writable result slot, checked above.
    unsafe {
        out_object.write(BingoDynamicValueV1 {
            tag: DYNAMIC_TAG_UNDEFINED,
            reserved: 0,
            payload: 0,
        });
    }
    if property_count > MAX_HOST_RECORD_PROPERTIES
        || property_count > usize::MAX as u64
        || (property_count != 0 && properties.is_null())
    {
        return BINGO_GC_INVALID_ARGUMENT;
    }
    let properties = if property_count == 0 {
        &[]
    } else {
        // SAFETY: the host keeps the descriptor array readable during this
        // call; null, count bound, and platform conversion were checked.
        unsafe { core::slice::from_raw_parts(properties, property_count as usize) }
    };
    let mut copied = HashMap::new();
    if copied.try_reserve(properties.len()).is_err() {
        return BINGO_GC_OUT_OF_MEMORY;
    }
    for property in properties {
        if property.key_length > MAX_DYNAMIC_KEY_UNITS
            || property.key_length > usize::MAX as u64
            || (property.key_length != 0 && property.key_data.is_null())
        {
            return BINGO_GC_INVALID_ARGUMENT;
        }
        let key = if property.key_length == 0 {
            &[]
        } else {
            // SAFETY: each key view is host-owned and readable for this call;
            // its null and length fields were validated above.
            unsafe { core::slice::from_raw_parts(property.key_data, property.key_length as usize) }
        };
        let mut owned = Vec::new();
        if owned.try_reserve_exact(key.len()).is_err() {
            return BINGO_GC_OUT_OF_MEMORY;
        }
        owned.extend_from_slice(key);
        if copied
            .insert(owned, HostProperty::Number(property.number_bits))
            .is_some()
        {
            return BINGO_GC_INVALID_ARGUMENT;
        }
    }
    match register_host_object(copied) {
        Ok(handle) => {
            // SAFETY: out_object remains exclusively writable for this call.
            unsafe {
                out_object.write(BingoDynamicValueV1 {
                    tag: DYNAMIC_TAG_OBJECT,
                    reserved: 0,
                    payload: handle,
                });
            }
            BINGO_GC_OK
        }
        Err(status) => status,
    }
}

pub fn register_host_object(properties: HashMap<Vec<u16>, HostProperty>) -> Result<u64, u32> {
    let mut handle = 0;
    let status = with_runtime(|state| {
        handle = state.next_host_handle;
        let Some(next) = handle.checked_add(1) else {
            return BINGO_GC_OUT_OF_MEMORY;
        };
        if state.host_objects.try_reserve(1).is_err() {
            return BINGO_GC_OUT_OF_MEMORY;
        }
        state.next_host_handle = next;
        state.host_objects.insert(handle, HostObject { properties });
        BINGO_GC_OK
    });
    if status == BINGO_GC_OK {
        Ok(handle)
    } else {
        Err(status)
    }
}

#[cfg(test)]
fn reset_test_runtime() {
    let mut state = runtime().lock().expect("test runtime lock");
    state.owner = None;
    state.frames.clear();
    state.heap.reset();
    state.host_objects.clear();
}

include!("generated_exports.rs");

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;
    use std::sync::MutexGuard;

    fn test_runtime_guard() -> MutexGuard<'static, ()> {
        static GUARD: OnceLock<Mutex<()>> = OnceLock::new();
        GUARD
            .get_or_init(|| Mutex::new(()))
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner())
    }

    #[test]
    fn runtime_identity_matches_abi_crate() {
        let _guard = test_runtime_guard();
        assert_eq!(super::abi_version(), bingo_abi::RUNTIME_ABI_VERSION);
    }

    #[test]
    fn active_mask_covers_exact_slot_domain() {
        let _guard = test_runtime_guard();
        assert_eq!(super::active_mask(0), 0);
        assert_eq!(super::active_mask(3), 0b111);
        assert_eq!(super::active_mask(64), u64::MAX);
    }

    #[test]
    fn shape_match_requires_heap_object_and_structural_descriptor() {
        let _guard = test_runtime_guard();
        reset_test_runtime();
        assert_eq!(gc_heap_reset(), BINGO_GC_OK);
        let trace = bingo_abi::BingoTraceDescriptorV1 {
            schema_version: 1,
            flags: 0,
            object_size: 24,
            pointer_count: 0,
            pointer_map_words: 0,
            pointer_offsets: core::ptr::null(),
            trace_callback: core::ptr::null(),
        };
        let shape = BingoShapeDescriptorV1 {
            schema_version: 1,
            flags: 0,
            object_size: 24,
            object_align: 8,
            property_count: 0,
            presence_word_count: 0,
            properties: core::ptr::null(),
            trace: (&trace as *const bingo_abi::BingoTraceDescriptorV1).cast(),
        };
        let other_shape = BingoShapeDescriptorV1 {
            trace: (&trace as *const bingo_abi::BingoTraceDescriptorV1).cast(),
            ..shape
        };
        let different_trace = bingo_abi::BingoTraceDescriptorV1 {
            object_size: 32,
            ..trace
        };
        let different_shape = BingoShapeDescriptorV1 {
            object_size: 32,
            trace: (&different_trace as *const bingo_abi::BingoTraceDescriptorV1).cast(),
            ..shape
        };
        let mut object = core::ptr::null_mut();
        assert_eq!(gc_alloc(&shape, &mut object), BINGO_GC_OK);
        let mut matched = 7_u8;
        assert_eq!(shape_matches(object, &shape, &mut matched), BINGO_GC_OK);
        assert_eq!(matched, 1);
        assert_eq!(
            shape_matches(object, &other_shape, &mut matched),
            BINGO_GC_OK
        );
        assert_eq!(matched, 1);
        assert_eq!(
            shape_matches(object, &different_shape, &mut matched),
            BINGO_GC_OK
        );
        assert_eq!(matched, 0);
        assert_eq!(
            shape_matches(core::ptr::null_mut(), &shape, &mut matched),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(matched, 0);
        check_shape_match_property_metadata_and_keys();
    }

    fn dynamic_object(handle: u64) -> BingoDynamicValueV1 {
        BingoDynamicValueV1 {
            tag: DYNAMIC_TAG_OBJECT,
            reserved: 0,
            payload: handle,
        }
    }

    fn key_view(key: &[u16]) -> BingoUtf16ViewV1 {
        BingoUtf16ViewV1 {
            data: key.as_ptr(),
            length: key.len() as u64,
        }
    }

    fn accessor_throws() -> Result<u64, ()> {
        Err(())
    }

    #[test]
    fn dynamic_property_load_authenticates_handles_and_preserves_number_bits() {
        let _guard = test_runtime_guard();
        reset_test_runtime();
        assert_eq!(gc_heap_reset(), BINGO_GC_OK);
        let stable_key: Vec<u16> = "stable".encode_utf16().collect();
        let negative_zero_key: Vec<u16> = "negativeZero".encode_utf16().collect();
        let nan_key: Vec<u16> = "nan".encode_utf16().collect();
        let throw_key: Vec<u16> = "throw".encode_utf16().collect();
        let mut properties = HashMap::new();
        properties.insert(stable_key.clone(), HostProperty::Number(42_f64.to_bits()));
        properties.insert(
            negative_zero_key.clone(),
            HostProperty::Number((-0.0_f64).to_bits()),
        );
        properties.insert(nan_key.clone(), HostProperty::Number(0x7ff8_0000_0000_0042));
        properties.insert(throw_key.clone(), HostProperty::Accessor(accessor_throws));
        let handle = register_host_object(properties).expect("host handle");

        let mut result = BingoDynamicValueV1 {
            tag: u32::MAX,
            reserved: u32::MAX,
            payload: u64::MAX,
        };
        assert_eq!(
            dynamic_property_load(dynamic_object(handle), key_view(&stable_key), &mut result),
            BINGO_GC_OK
        );
        assert_eq!(
            (result.tag, result.reserved, result.payload),
            (DYNAMIC_TAG_NUMBER, 0, 42_f64.to_bits())
        );
        assert_eq!(
            dynamic_property_load(
                dynamic_object(handle),
                key_view(&negative_zero_key),
                &mut result
            ),
            BINGO_GC_OK
        );
        assert_eq!(result.payload, (-0.0_f64).to_bits());
        assert_eq!(
            dynamic_property_load(dynamic_object(handle), key_view(&nan_key), &mut result),
            BINGO_GC_OK
        );
        assert_eq!(result.payload, 0x7ff8_0000_0000_0042);
        assert_eq!(
            dynamic_property_load(dynamic_object(handle), key_view(&throw_key), &mut result),
            BINGO_DYNAMIC_EXCEPTION
        );
        assert_eq!(
            (result.tag, result.reserved, result.payload),
            (DYNAMIC_TAG_UNDEFINED, 0, 0)
        );
    }

    #[test]
    fn dynamic_property_load_fails_closed_and_reset_invalidates_handles() {
        let _guard = test_runtime_guard();
        reset_test_runtime();
        assert_eq!(gc_heap_reset(), BINGO_GC_OK);
        let key: Vec<u16> = "value".encode_utf16().collect();
        let handle = register_host_object(HashMap::new()).expect("host handle");
        let mut result = BingoDynamicValueV1 {
            tag: 9,
            reserved: 9,
            payload: 9,
        };
        assert_eq!(
            dynamic_property_load(dynamic_object(handle), key_view(&key), &mut result),
            BINGO_GC_OK
        );
        assert_eq!(
            (result.tag, result.reserved, result.payload),
            (DYNAMIC_TAG_UNDEFINED, 0, 0)
        );
        assert_eq!(
            dynamic_property_load(dynamic_object(handle + 1), key_view(&key), &mut result),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(
            (result.tag, result.reserved, result.payload),
            (DYNAMIC_TAG_UNDEFINED, 0, 0)
        );
        assert_eq!(gc_heap_reset(), BINGO_GC_OK);
        assert_eq!(
            dynamic_property_load(dynamic_object(handle), key_view(&key), &mut result),
            BINGO_GC_INVALID_ARGUMENT
        );
        let reserved = BingoDynamicValueV1 {
            reserved: 1,
            ..dynamic_object(handle)
        };
        assert_eq!(
            dynamic_property_load(reserved, key_view(&key), &mut result),
            BINGO_GC_INVALID_ARGUMENT
        );
        let wrong_tag = BingoDynamicValueV1 {
            tag: DYNAMIC_TAG_NUMBER,
            ..dynamic_object(handle)
        };
        assert_eq!(
            dynamic_property_load(wrong_tag, key_view(&key), &mut result),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(
            dynamic_property_load(
                dynamic_object(handle),
                BingoUtf16ViewV1 {
                    data: core::ptr::null(),
                    length: 1
                },
                &mut result
            ),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(
            dynamic_property_load(
                dynamic_object(handle),
                BingoUtf16ViewV1 {
                    data: core::ptr::dangling(),
                    length: MAX_DYNAMIC_KEY_UNITS + 1,
                },
                &mut result
            ),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(
            dynamic_property_load(
                dynamic_object(handle),
                key_view(&key),
                core::ptr::null_mut()
            ),
            BINGO_GC_INVALID_ARGUMENT
        );
    }

    #[test]
    fn dynamic_property_load_rejects_a_non_owner_thread() {
        let _guard = test_runtime_guard();
        reset_test_runtime();
        assert_eq!(gc_heap_reset(), BINGO_GC_OK);
        let handle = register_host_object(HashMap::new()).expect("host handle");
        let (status, result) = std::thread::spawn(move || {
            let key: Vec<u16> = "value".encode_utf16().collect();
            let mut result = BingoDynamicValueV1 {
                tag: 9,
                reserved: 9,
                payload: 9,
            };
            let status = dynamic_property_load(dynamic_object(handle), key_view(&key), &mut result);
            (status, result)
        })
        .join()
        .expect("worker thread");
        assert_eq!(status, BINGO_GC_WRONG_THREAD);
        assert_eq!(
            (result.tag, result.reserved, result.payload),
            (DYNAMIC_TAG_UNDEFINED, 0, 0)
        );
    }

    #[test]
    fn host_number_record_registration_is_atomic_and_round_trips_bits() {
        let _guard = test_runtime_guard();
        reset_test_runtime();
        let key: Vec<u16> = "value".encode_utf16().collect();
        let descriptors = [BingoHostNumberPropertyV1 {
            key_data: key.as_ptr(),
            key_length: key.len() as u64,
            number_bits: 0x7ff8_0000_0000_0042,
        }];
        let mut object = BingoDynamicValueV1 {
            tag: 9,
            reserved: 9,
            payload: 9,
        };
        assert_eq!(
            host_number_record_register(descriptors.as_ptr(), 1, &mut object),
            BINGO_GC_OK
        );
        assert_eq!((object.tag, object.reserved), (DYNAMIC_TAG_OBJECT, 0));
        let handle = object.payload;
        let mut result = BingoDynamicValueV1 {
            tag: 9,
            reserved: 9,
            payload: 9,
        };
        assert_eq!(
            dynamic_property_load(dynamic_object(handle), key_view(&key), &mut result),
            BINGO_GC_OK
        );
        assert_eq!(
            (result.tag, result.reserved, result.payload),
            (DYNAMIC_TAG_NUMBER, 0, 0x7ff8_0000_0000_0042)
        );
        assert_eq!(gc_heap_reset(), BINGO_GC_OK);
        assert_eq!(
            dynamic_property_load(dynamic_object(handle), key_view(&key), &mut result),
            BINGO_GC_INVALID_ARGUMENT
        );
    }

    #[test]
    fn host_number_record_registration_fails_closed_without_consuming_handle() {
        let _guard = test_runtime_guard();
        reset_test_runtime();
        let key: Vec<u16> = "duplicate".encode_utf16().collect();
        let mut first = BingoDynamicValueV1 {
            tag: 9,
            reserved: 9,
            payload: 9,
        };
        assert_eq!(
            host_number_record_register(core::ptr::null(), 0, &mut first),
            BINGO_GC_OK
        );
        let duplicate = [
            BingoHostNumberPropertyV1 {
                key_data: key.as_ptr(),
                key_length: key.len() as u64,
                number_bits: 1,
            },
            BingoHostNumberPropertyV1 {
                key_data: key.as_ptr(),
                key_length: key.len() as u64,
                number_bits: 2,
            },
        ];
        let mut object = BingoDynamicValueV1 {
            tag: 9,
            reserved: 9,
            payload: 9,
        };
        assert_eq!(
            host_number_record_register(duplicate.as_ptr(), 2, &mut object),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(
            (object.tag, object.reserved, object.payload),
            (DYNAMIC_TAG_UNDEFINED, 0, 0)
        );
        assert_eq!(
            host_number_record_register(core::ptr::null(), 1, &mut object),
            BINGO_GC_INVALID_ARGUMENT
        );
        let invalid_key = [BingoHostNumberPropertyV1 {
            key_data: core::ptr::null(),
            key_length: 1,
            number_bits: 0,
        }];
        assert_eq!(
            host_number_record_register(invalid_key.as_ptr(), 1, &mut object),
            BINGO_GC_INVALID_ARGUMENT
        );
        let oversize_key = [BingoHostNumberPropertyV1 {
            key_data: core::ptr::dangling(),
            key_length: MAX_DYNAMIC_KEY_UNITS + 1,
            number_bits: 0,
        }];
        assert_eq!(
            host_number_record_register(oversize_key.as_ptr(), 1, &mut object),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(
            host_number_record_register(core::ptr::null(), 0, core::ptr::null_mut()),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(
            host_number_record_register(core::ptr::null(), 0, &mut object),
            BINGO_GC_OK
        );
        assert_eq!(
            object.payload,
            first.payload + 1,
            "failed registrations consumed a handle"
        );
    }

    fn check_shape_match_property_metadata_and_keys() {
        assert_eq!(gc_heap_reset(), BINGO_GC_OK);
        let trace = bingo_abi::BingoTraceDescriptorV1 {
            schema_version: 1,
            flags: 0,
            object_size: 32,
            pointer_count: 0,
            pointer_map_words: 0,
            pointer_offsets: core::ptr::null(),
            trace_callback: core::ptr::null(),
        };
        let key = b"value\0";
        let other_key = b"value\0";
        let wrong_key = b"other\0";
        let property = |key: &[u8]| bingo_abi::BingoPropertyDescriptorV1 {
            key: key.as_ptr().cast(),
            kind: 1,
            flags: 0,
            reserved: 0,
            field_offset: 24,
            presence_bit: u32::MAX,
            slot: 0,
            enumeration_order: 0,
            value_descriptor: core::ptr::null(),
        };
        let source_property = property(key);
        let equivalent_property = property(other_key);
        let different_property = property(wrong_key);
        let malformed_property = bingo_abi::BingoPropertyDescriptorV1 {
            kind: 3,
            ..property(key)
        };
        let accessor_property = bingo_abi::BingoPropertyDescriptorV1 {
            kind: 2,
            field_offset: 0,
            ..property(key)
        };
        let optional_property = bingo_abi::BingoPropertyDescriptorV1 {
            presence_bit: 0,
            ..property(key)
        };
        let shape = |property: &bingo_abi::BingoPropertyDescriptorV1| BingoShapeDescriptorV1 {
            schema_version: 1,
            flags: 0,
            object_size: 32,
            object_align: 8,
            property_count: 1,
            presence_word_count: 0,
            properties: (property as *const bingo_abi::BingoPropertyDescriptorV1).cast(),
            trace: (&trace as *const bingo_abi::BingoTraceDescriptorV1).cast(),
        };
        let source_shape = shape(&source_property);
        let equivalent_shape = shape(&equivalent_property);
        let different_shape = shape(&different_property);
        let malformed_shape = shape(&malformed_property);
        let accessor_shape = shape(&accessor_property);
        let optional_shape = BingoShapeDescriptorV1 {
            presence_word_count: 1,
            ..shape(&optional_property)
        };
        let extra_key = b"extra\0";
        let extra_trace = bingo_abi::BingoTraceDescriptorV1 {
            object_size: 40,
            ..trace
        };
        let extra_properties = [
            property(key),
            bingo_abi::BingoPropertyDescriptorV1 {
                key: extra_key.as_ptr().cast(),
                field_offset: 32,
                slot: 1,
                enumeration_order: 1,
                ..property(extra_key)
            },
        ];
        let extra_shape = BingoShapeDescriptorV1 {
            object_size: 40,
            property_count: 2,
            properties: extra_properties.as_ptr().cast(),
            trace: (&extra_trace as *const bingo_abi::BingoTraceDescriptorV1).cast(),
            ..shape(&source_property)
        };
        let mut object = core::ptr::null_mut();
        assert_eq!(gc_alloc(&source_shape, &mut object), BINGO_GC_OK);
        let mut matched = 0;
        assert_eq!(
            shape_matches(object, &equivalent_shape, &mut matched),
            BINGO_GC_OK
        );
        assert_eq!(matched, 1);
        assert_eq!(
            shape_matches(object, &different_shape, &mut matched),
            BINGO_GC_OK
        );
        assert_eq!(matched, 0);
        let mut extra_object = core::ptr::null_mut();
        assert_eq!(gc_alloc(&extra_shape, &mut extra_object), BINGO_GC_OK);
        assert_eq!(
            shape_matches(extra_object, &equivalent_shape, &mut matched),
            BINGO_GC_OK
        );
        assert_eq!(matched, 1);
        assert_eq!(
            shape_matches(object, &malformed_shape, &mut matched),
            BINGO_GC_INVALID_ARGUMENT
        );
        assert_eq!(matched, 0);
        let mut accessor_object = core::ptr::null_mut();
        assert_eq!(gc_alloc(&accessor_shape, &mut accessor_object), BINGO_GC_OK);
        assert_eq!(
            shape_matches(accessor_object, &equivalent_shape, &mut matched),
            BINGO_GC_OK
        );
        assert_eq!(matched, 0);
        let mut optional_object = core::ptr::null_mut();
        assert_eq!(gc_alloc(&optional_shape, &mut optional_object), BINGO_GC_OK);
        assert_eq!(
            shape_matches(optional_object, &equivalent_shape, &mut matched),
            BINGO_GC_OK
        );
        assert_eq!(matched, 0);
    }
}
