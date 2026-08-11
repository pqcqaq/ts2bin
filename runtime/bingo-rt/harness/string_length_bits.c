#include "bingo_abi.h"

#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int hex_value(char value) {
    if (value >= '0' && value <= '9') {
        return value - '0';
    }
    if (value >= 'a' && value <= 'f') {
        return value - 'a' + 10;
    }
    return -1;
}

static int parse_utf16(const char *text, BingoUtf16String *result, uint16_t **storage) {
    size_t bytes = strlen(text);
    if (bytes % 4 != 0) {
        return 0;
    }
    size_t length = bytes / 4;
    uint16_t *units = length == 0 ? NULL : calloc(length, sizeof(uint16_t));
    if (length != 0 && units == NULL) {
        return 0;
    }
    for (size_t index = 0; index < length; index++) {
        uint16_t unit = 0;
        for (size_t digit = 0; digit < 4; digit++) {
            int value = hex_value(text[index * 4 + digit]);
            if (value < 0) {
                free(units);
                return 0;
            }
            unit = (uint16_t)((unit << 4) | (uint16_t)value);
        }
        units[index] = unit;
    }
    result->data = units;
    result->length = (uint64_t)length;
    *storage = units;
    return 1;
}

static uint64_t double_to_bits(double value) {
    uint64_t bits;
    memcpy(&bits, &value, sizeof(bits));
    return bits;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fputs("usage: string-length-harness <utf16-code-unit-hex>\n", stderr);
        return 2;
    }
    if (bingo_rt_abi_version_v1() != BINGO_RUNTIME_ABI_VERSION) {
        fputs("bingo runtime ABI mismatch\n", stderr);
        return 3;
    }
    if (strcmp(argv[1], "--invalid-null") == 0) {
        BingoUtf16String invalid = {NULL, 1};
        (void)stringLength(invalid);
        return 4;
    }
    BingoUtf16String value;
    uint16_t *storage = NULL;
    if (!parse_utf16(argv[1], &value, &storage)) {
        fputs("invalid canonical UTF-16 code-unit hex\n", stderr);
        return 2;
    }
    double result = stringLength(value);
    free(storage);
    printf("%016" PRIx64 "\n", double_to_bits(result));
    return 0;
}
