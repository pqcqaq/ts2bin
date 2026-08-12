#include "bingo_abi.h"

#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void *bingo_object_layout_copy_v1(void *source);

int main(int argc, char **argv) {
    if (argc != 4) return 2;
    char *source_offset_end = NULL;
    char *target_offset_end = NULL;
    char *bits_end = NULL;
    errno = 0;
    unsigned long source_offset = strtoul(argv[1], &source_offset_end, 10);
    unsigned long target_offset = strtoul(argv[2], &target_offset_end, 10);
    unsigned long long bits = strtoull(argv[3], &bits_end, 16);
    if (errno != 0 || source_offset_end == argv[1] || *source_offset_end != '\0' ||
        target_offset_end == argv[2] || *target_offset_end != '\0' ||
        bits_end == argv[3] || *bits_end != '\0' || strlen(argv[3]) != 16 ||
        source_offset < sizeof(BingoObjectHeaderV1) ||
        target_offset < sizeof(BingoObjectHeaderV1) ||
        source_offset > 4096 - sizeof(double) || target_offset > 4096 - sizeof(double)) return 2;

    BingoTraceDescriptorV1 trace = {
        .schema_version = BINGO_OBJECT_LAYOUT_SCHEMA_VERSION,
        .flags = 0,
        .object_size = source_offset + sizeof(double),
        .pointer_count = 0,
        .pointer_map_words = 0,
        .pointer_offsets = NULL,
        .trace_callback = NULL,
    };
    BingoShapeDescriptorV1 shape = {
        .schema_version = BINGO_OBJECT_LAYOUT_SCHEMA_VERSION,
        .flags = 0,
        .object_size = source_offset + sizeof(double),
        .object_align = _Alignof(double),
        .property_count = 1,
        .presence_word_count = 0,
        .properties = NULL,
        .trace = &trace,
    };
    BingoObjectHeaderV1 *source = NULL;
    if (bingo_gc_heap_reset_v1() != BINGO_GC_OK ||
        bingo_gc_alloc_v1(&shape, &source) != BINGO_GC_OK || source == NULL) return 1;

    uint64_t input = (uint64_t)bits;
    memcpy((unsigned char *)source + source_offset, &input, sizeof(input));
    BingoObjectHeaderV1 *copy = bingo_object_layout_copy_v1(source);
    if (copy == NULL) return 1;

    uint64_t changed = UINT64_C(0x3ff0000000000000);
    uint64_t output = 0;
    memcpy((unsigned char *)source + source_offset, &changed, sizeof(changed));
    memcpy(&output, (unsigned char *)copy + target_offset, sizeof(output));
    printf("%d:%016" PRIx64 "\n", copy != source, output);
    return copy != source && output == input ? 0 : 1;
}
