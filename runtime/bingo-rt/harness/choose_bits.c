#include "bingo_abi.h"

#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int parse_byte(const char *text, uint8_t *value) {
    if (strlen(text) != 2 || !isxdigit((unsigned char)text[0]) || !isxdigit((unsigned char)text[1])) {
        return 0;
    }
    char *end = NULL;
    errno = 0;
    unsigned long parsed = strtoul(text, &end, 16);
    if (errno != 0 || end == text || *end != '\0' || parsed > UINT8_MAX) {
        return 0;
    }
    *value = (uint8_t)parsed;
    return 1;
}

static int parse_bits(const char *text, uint64_t *bits) {
    if (strlen(text) != 16) {
        return 0;
    }
    for (size_t index = 0; index < 16; index++) {
        if (!isxdigit((unsigned char)text[index])) {
            return 0;
        }
    }
    char *end = NULL;
    errno = 0;
    unsigned long long value = strtoull(text, &end, 16);
    if (errno != 0 || end == text || *end != '\0') {
        return 0;
    }
    *bits = (uint64_t)value;
    return 1;
}

static double double_from_bits(uint64_t bits) {
    double value;
    memcpy(&value, &bits, sizeof(value));
    return value;
}

static uint64_t double_to_bits(double value) {
    uint64_t bits;
    memcpy(&bits, &value, sizeof(bits));
    return bits;
}

int main(int argc, char **argv) {
    uint8_t flag;
    uint64_t left_bits;
    uint64_t right_bits;
    if (argc != 4 || !parse_byte(argv[1], &flag) || !parse_bits(argv[2], &left_bits) || !parse_bits(argv[3], &right_bits)) {
        fputs("usage: choose-harness <flag-byte-hex> <left-binary64-hex> <right-binary64-hex>\n", stderr);
        return 2;
    }
    if (bingo_rt_abi_version_v1() != BINGO_RUNTIME_ABI_VERSION) {
        fputs("bingo runtime ABI mismatch\n", stderr);
        return 3;
    }
    double result = choose(flag, double_from_bits(left_bits), double_from_bits(right_bits));
    printf("%016" PRIx64 "\n", double_to_bits(result));
    return 0;
}
