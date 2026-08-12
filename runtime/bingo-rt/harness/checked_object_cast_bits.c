#include "bingo_abi.h"

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern uint32_t bingo_checked_object_cast_v1(BingoObjectHeaderV1 *source, BingoObjectHeaderV1 **out_value, uint8_t *out_match);

static const BingoTraceDescriptorV1 trace32 = {1, 0, 32, 0, 0, NULL, NULL};
static const BingoTraceDescriptorV1 trace40 = {1, 0, 40, 0, 0, NULL, NULL};
static const BingoPropertyDescriptorV1 value_data = {"value", 1, 0, 0, 24, UINT32_MAX, 0, 0, NULL};
static const BingoPropertyDescriptorV1 value_accessor = {"value", 2, 0, 0, 0, UINT32_MAX, 0, 0, NULL};
static const BingoPropertyDescriptorV1 extra_properties[] = {
    {"value", 1, 0, 0, 24, UINT32_MAX, 0, 0, NULL},
    {"extra", 1, 0, 0, 32, UINT32_MAX, 1, 1, NULL},
};

static BingoShapeDescriptorV1 shape_for(const char *kind) {
    BingoShapeDescriptorV1 shape = {1, 0, 32, 8, 0, 0, NULL, &trace32};
    if (strcmp(kind, "matching") == 0) {
        shape.property_count = 1;
        shape.properties = &value_data;
    } else if (strcmp(kind, "extra") == 0) {
        shape.object_size = 40;
        shape.trace = &trace40;
        shape.property_count = 2;
        shape.properties = extra_properties;
    } else if (strcmp(kind, "accessor") == 0) {
        shape.property_count = 1;
        shape.properties = &value_accessor;
    } else if (strcmp(kind, "missing") != 0) {
        shape.schema_version = 0;
    }
    return shape;
}

int main(int argc, char **argv) {
    if (argc != 3 || strlen(argv[2]) != 16) return 2;
    char *end = NULL;
    unsigned long long bits = strtoull(argv[2], &end, 16);
    if (end == argv[2] || *end != '\0') return 2;
    BingoShapeDescriptorV1 source_shape = shape_for(argv[1]);
    if (source_shape.schema_version != 1) return 2;
    BingoObjectHeaderV1 *source = NULL;
    if (bingo_gc_heap_reset_v1() != BINGO_GC_OK || bingo_gc_alloc_v1(&source_shape, &source) != BINGO_GC_OK || source == NULL) return 3;
    if (strcmp(argv[1], "matching") == 0 || strcmp(argv[1], "extra") == 0) memcpy((unsigned char *)source + 24, &bits, sizeof(bits));
    BingoObjectHeaderV1 *result = NULL;
    uint8_t match = 0xff;
    uint32_t status = bingo_checked_object_cast_v1(source, &result, &match);
    if (status != BINGO_GC_OK || match > 1 || (match == 1 && result != source) || (match == 0 && result != NULL)) return 4;
    uint64_t output = (uint64_t)bits;
    if (match == 1) memcpy(&output, (unsigned char *)result + 24, sizeof(output));
    printf("%u:%016" PRIx64 "\n", match, output);
    return 0;
}
