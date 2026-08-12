#include "bingo_abi.h"

#include <stddef.h>

_Static_assert(sizeof(void *) == 8, "object layout v1 requires a 64-bit target");
_Static_assert(sizeof(BingoObjectHeaderV1) == 24 && _Alignof(BingoObjectHeaderV1) == 8, "BingoObjectHeaderV1 extent");
_Static_assert(offsetof(BingoObjectHeaderV1, descriptor) == 0, "BingoObjectHeaderV1.descriptor");
_Static_assert(offsetof(BingoObjectHeaderV1, size_bytes) == 8, "BingoObjectHeaderV1.size_bytes");
_Static_assert(offsetof(BingoObjectHeaderV1, gc_word) == 16, "BingoObjectHeaderV1.gc_word");

_Static_assert(sizeof(BingoShapeDescriptorV1) == 48 && _Alignof(BingoShapeDescriptorV1) == 8, "BingoShapeDescriptorV1 extent");
_Static_assert(offsetof(BingoShapeDescriptorV1, object_size) == 8, "BingoShapeDescriptorV1.object_size");
_Static_assert(offsetof(BingoShapeDescriptorV1, object_align) == 16, "BingoShapeDescriptorV1.object_align");
_Static_assert(offsetof(BingoShapeDescriptorV1, property_count) == 24, "BingoShapeDescriptorV1.property_count");
_Static_assert(offsetof(BingoShapeDescriptorV1, properties) == 32, "BingoShapeDescriptorV1.properties");
_Static_assert(offsetof(BingoShapeDescriptorV1, trace) == 40, "BingoShapeDescriptorV1.trace");

_Static_assert(sizeof(BingoPropertyDescriptorV1) == 40 && _Alignof(BingoPropertyDescriptorV1) == 8, "BingoPropertyDescriptorV1 extent");
_Static_assert(offsetof(BingoPropertyDescriptorV1, kind) == 8, "BingoPropertyDescriptorV1.kind");
_Static_assert(offsetof(BingoPropertyDescriptorV1, field_offset) == 12, "BingoPropertyDescriptorV1.field_offset");
_Static_assert(offsetof(BingoPropertyDescriptorV1, presence_bit) == 16, "BingoPropertyDescriptorV1.presence_bit");
_Static_assert(offsetof(BingoPropertyDescriptorV1, value_descriptor) == 32, "BingoPropertyDescriptorV1.value_descriptor");

_Static_assert(sizeof(BingoTraceDescriptorV1) == 40 && _Alignof(BingoTraceDescriptorV1) == 8, "BingoTraceDescriptorV1 extent");
_Static_assert(offsetof(BingoTraceDescriptorV1, object_size) == 8, "BingoTraceDescriptorV1.object_size");
_Static_assert(offsetof(BingoTraceDescriptorV1, pointer_count) == 16, "BingoTraceDescriptorV1.pointer_count");
_Static_assert(offsetof(BingoTraceDescriptorV1, pointer_offsets) == 24, "BingoTraceDescriptorV1.pointer_offsets");
_Static_assert(offsetof(BingoTraceDescriptorV1, trace_callback) == 32, "BingoTraceDescriptorV1.trace_callback");

_Static_assert(sizeof(BingoGcFrameV1) == 32 && _Alignof(BingoGcFrameV1) == 8, "BingoGcFrameV1 extent");
_Static_assert(offsetof(BingoGcFrameV1, previous) == 0, "BingoGcFrameV1.previous");
_Static_assert(offsetof(BingoGcFrameV1, slots) == 8, "BingoGcFrameV1.slots");
_Static_assert(offsetof(BingoGcFrameV1, slot_count) == 16, "BingoGcFrameV1.slot_count");
_Static_assert(offsetof(BingoGcFrameV1, active_bits) == 24, "BingoGcFrameV1.active_bits");

_Static_assert(sizeof(BingoGcStatsV1) == 24 && _Alignof(BingoGcStatsV1) == 8, "BingoGcStatsV1 extent");
_Static_assert(offsetof(BingoGcStatsV1, allocated_objects) == 0, "BingoGcStatsV1.allocated_objects");
_Static_assert(offsetof(BingoGcStatsV1, allocated_bytes) == 8, "BingoGcStatsV1.allocated_bytes");
_Static_assert(offsetof(BingoGcStatsV1, collections) == 16, "BingoGcStatsV1.collections");

_Static_assert(BINGO_GC_OK == 0 && BINGO_GC_FRAME_STATE == 5, "GC status ABI");
