#include "bingo_abi.h"

#include <stddef.h>
#include <stdint.h>

_Static_assert(sizeof(BingoDynamicValueV1) == 16, "BingoDynamicValueV1 size");
_Static_assert(_Alignof(BingoDynamicValueV1) == 8, "BingoDynamicValueV1 alignment");
_Static_assert(offsetof(BingoDynamicValueV1, tag) == 0, "BingoDynamicValueV1.tag offset");
_Static_assert(offsetof(BingoDynamicValueV1, reserved) == 4,
               "BingoDynamicValueV1.reserved offset");
_Static_assert(offsetof(BingoDynamicValueV1, payload) == 8,
               "BingoDynamicValueV1.payload offset");

#if UINTPTR_MAX == UINT64_MAX
_Static_assert(sizeof(BingoUtf16ViewV1) == 16, "BingoUtf16ViewV1 size");
_Static_assert(_Alignof(BingoUtf16ViewV1) == 8, "BingoUtf16ViewV1 alignment");
_Static_assert(offsetof(BingoUtf16ViewV1, data) == 0, "BingoUtf16ViewV1.data offset");
_Static_assert(offsetof(BingoUtf16ViewV1, length) == 8,
               "BingoUtf16ViewV1.length offset");
_Static_assert(sizeof(BingoHostNumberPropertyV1) == 24,
               "BingoHostNumberPropertyV1 size");
_Static_assert(_Alignof(BingoHostNumberPropertyV1) == 8,
               "BingoHostNumberPropertyV1 alignment");
_Static_assert(offsetof(BingoHostNumberPropertyV1, key_data) == 0,
               "BingoHostNumberPropertyV1.key_data offset");
_Static_assert(offsetof(BingoHostNumberPropertyV1, key_length) == 8,
               "BingoHostNumberPropertyV1.key_length offset");
_Static_assert(offsetof(BingoHostNumberPropertyV1, number_bits) == 16,
               "BingoHostNumberPropertyV1.number_bits offset");
#endif

static int status_is(uint32_t got, uint32_t want) { return got == want ? 0 : 1; }

int main(void) {
    static const uint16_t VALUE[] = {'v', 'a', 'l', 'u', 'e'};
    static const uint16_t ZERO[] = {'z', 'e', 'r', 'o'};
    static const uint16_t MISSING[] = {'m', 'i', 's', 's', 'i', 'n', 'g'};
    const uint64_t NAN_BITS = UINT64_C(0x7ff8000000000042);
    const uint64_t NEGATIVE_ZERO_BITS = UINT64_C(0x8000000000000000);
    BingoHostNumberPropertyV1 properties[] = {{VALUE, 5, NAN_BITS},
                                               {ZERO, 4, NEGATIVE_ZERO_BITS}};
    BingoHostNumberPropertyV1 duplicate[] = {{VALUE, 5, 1}, {VALUE, 5, 2}};
    BingoDynamicValueV1 object = {9, 9, 9};
    BingoDynamicValueV1 result = {9, 9, 9};
    BingoUtf16ViewV1 value_key = {VALUE, 5};
    BingoUtf16ViewV1 zero_key = {ZERO, 4};
    BingoUtf16ViewV1 missing_key = {MISSING, 7};

    if (status_is(bingo_gc_heap_reset_v1(), BINGO_GC_OK) ||
        status_is(bingo_host_number_record_register_v1(properties, 2, &object), BINGO_GC_OK) ||
        object.tag != 1 || object.reserved != 0 || object.payload == 0) {
        return 10;
    }
    if (status_is(bingo_dynamic_property_load_v1(object, value_key, &result), BINGO_GC_OK) ||
        result.tag != 2 || result.reserved != 0 || result.payload != NAN_BITS) {
        return 11;
    }
    if (status_is(bingo_dynamic_property_load_v1(object, zero_key, &result), BINGO_GC_OK) ||
        result.tag != 2 || result.payload != NEGATIVE_ZERO_BITS) {
        return 12;
    }
    if (status_is(bingo_dynamic_property_load_v1(object, missing_key, &result), BINGO_GC_OK) ||
        result.tag != 0 || result.reserved != 0 || result.payload != 0) {
        return 13;
    }
    if (status_is(bingo_host_number_record_register_v1(duplicate, 2, &result),
                  BINGO_GC_INVALID_ARGUMENT) ||
        result.tag != 0 || result.reserved != 0 || result.payload != 0) {
        return 14;
    }
    if (status_is(bingo_gc_heap_reset_v1(), BINGO_GC_OK) ||
        status_is(bingo_dynamic_property_load_v1(object, value_key, &result),
                  BINGO_GC_INVALID_ARGUMENT) ||
        result.tag != 0 || result.reserved != 0 || result.payload != 0) {
        return 15;
    }
    return 0;
}
