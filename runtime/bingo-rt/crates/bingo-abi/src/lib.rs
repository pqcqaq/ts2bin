#![forbid(unsafe_code)]

include!("generated.rs");

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn schema_and_runtime_abi_are_versioned() {
        assert_eq!(ABI_SCHEMA_VERSION, 1);
        assert_eq!(RUNTIME_ABI_VERSION, 1);
        assert_eq!(OBJECT_LAYOUT_SCHEMA_VERSION, 1);
        assert_eq!(OBJECT_LAYOUT_SCHEMA_HASH.len(), 64);
        assert_eq!(BINGO_GC_OK, 0);
        assert_eq!(BINGO_GC_FRAME_STATE, 5);
    }

    #[test]
    fn object_layout_v1_matches_64_bit_c_abi() {
        use core::mem::{align_of, offset_of, size_of};

        assert_eq!(
            (
                size_of::<BingoObjectHeaderV1>(),
                align_of::<BingoObjectHeaderV1>()
            ),
            (24, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoObjectHeaderV1, descriptor),
                offset_of!(BingoObjectHeaderV1, size_bytes),
                offset_of!(BingoObjectHeaderV1, gc_word)
            ),
            (0, 8, 16)
        );
        assert_eq!(
            (
                size_of::<BingoShapeDescriptorV1>(),
                align_of::<BingoShapeDescriptorV1>()
            ),
            (48, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoShapeDescriptorV1, schema_version),
                offset_of!(BingoShapeDescriptorV1, flags),
                offset_of!(BingoShapeDescriptorV1, object_size),
                offset_of!(BingoShapeDescriptorV1, object_align),
                offset_of!(BingoShapeDescriptorV1, property_count),
                offset_of!(BingoShapeDescriptorV1, presence_word_count),
                offset_of!(BingoShapeDescriptorV1, properties),
                offset_of!(BingoShapeDescriptorV1, trace)
            ),
            (0, 4, 8, 16, 24, 28, 32, 40)
        );
        assert_eq!(
            (
                size_of::<BingoPropertyDescriptorV1>(),
                align_of::<BingoPropertyDescriptorV1>()
            ),
            (40, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoPropertyDescriptorV1, key),
                offset_of!(BingoPropertyDescriptorV1, kind),
                offset_of!(BingoPropertyDescriptorV1, flags),
                offset_of!(BingoPropertyDescriptorV1, reserved),
                offset_of!(BingoPropertyDescriptorV1, field_offset),
                offset_of!(BingoPropertyDescriptorV1, presence_bit),
                offset_of!(BingoPropertyDescriptorV1, slot),
                offset_of!(BingoPropertyDescriptorV1, enumeration_order),
                offset_of!(BingoPropertyDescriptorV1, value_descriptor)
            ),
            (0, 8, 9, 10, 12, 16, 20, 24, 32)
        );
        assert_eq!(
            (
                size_of::<BingoTraceDescriptorV1>(),
                align_of::<BingoTraceDescriptorV1>()
            ),
            (40, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoTraceDescriptorV1, schema_version),
                offset_of!(BingoTraceDescriptorV1, flags),
                offset_of!(BingoTraceDescriptorV1, object_size),
                offset_of!(BingoTraceDescriptorV1, pointer_count),
                offset_of!(BingoTraceDescriptorV1, pointer_map_words),
                offset_of!(BingoTraceDescriptorV1, pointer_offsets),
                offset_of!(BingoTraceDescriptorV1, trace_callback)
            ),
            (0, 4, 8, 16, 20, 24, 32)
        );
    }

    #[test]
    fn gc_root_abi_matches_64_bit_c_layout() {
        use core::mem::{align_of, offset_of, size_of};

        assert_eq!(
            (size_of::<BingoGcFrameV1>(), align_of::<BingoGcFrameV1>()),
            (32, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoGcFrameV1, previous),
                offset_of!(BingoGcFrameV1, slots),
                offset_of!(BingoGcFrameV1, slot_count),
                offset_of!(BingoGcFrameV1, active_bits),
            ),
            (0, 8, 16, 24)
        );
        assert_eq!(
            (size_of::<BingoGcStatsV1>(), align_of::<BingoGcStatsV1>()),
            (24, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoGcStatsV1, allocated_objects),
                offset_of!(BingoGcStatsV1, allocated_bytes),
                offset_of!(BingoGcStatsV1, collections),
            ),
            (0, 8, 16)
        );
    }

    #[test]
    fn dynamic_value_abi_matches_64_bit_c_layout() {
        use core::mem::{align_of, offset_of, size_of};

        assert_eq!(
            (
                size_of::<BingoDynamicValueV1>(),
                align_of::<BingoDynamicValueV1>()
            ),
            (16, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoDynamicValueV1, tag),
                offset_of!(BingoDynamicValueV1, reserved),
                offset_of!(BingoDynamicValueV1, payload),
            ),
            (0, 4, 8)
        );
        assert_eq!(
            (
                size_of::<BingoUtf16ViewV1>(),
                align_of::<BingoUtf16ViewV1>()
            ),
            (16, 8)
        );
        assert_eq!(BINGO_DYNAMIC_EXCEPTION, 6);
        assert_eq!(
            (
                size_of::<BingoHostNumberPropertyV1>(),
                align_of::<BingoHostNumberPropertyV1>()
            ),
            (24, 8)
        );
        assert_eq!(
            (
                offset_of!(BingoHostNumberPropertyV1, key_data),
                offset_of!(BingoHostNumberPropertyV1, key_length),
                offset_of!(BingoHostNumberPropertyV1, number_bits),
            ),
            (0, 8, 16)
        );
    }
}
