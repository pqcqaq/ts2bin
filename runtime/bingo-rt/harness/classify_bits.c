#include "bingo_abi.h"

#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
    uint64_t value_bits;
    if (argc != 2 || !parse_bits(argv[1], &value_bits)) {
        fputs("usage: classify-harness <value-binary64-hex>\n", stderr);
        return 2;
    }
    if (bingo_rt_abi_version_v1() != BINGO_RUNTIME_ABI_VERSION) {
        fputs("bingo runtime ABI mismatch\n", stderr);
        return 3;
    }
    double result = classify(double_from_bits(value_bits));
    printf("%016" PRIx64 "\n", double_to_bits(result));
    return 0;
}
