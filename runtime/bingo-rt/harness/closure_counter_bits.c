#include "bingo_abi.h"

#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern double closureCounter(double value);

static int parse_bits(const char *text, uint64_t *bits) {
    if (strlen(text) != 16) return 0;
    for (size_t index = 0; index < 16; index++) {
        if (!isxdigit((unsigned char)text[index])) return 0;
    }
    char *end = NULL;
    errno = 0;
    unsigned long long value = strtoull(text, &end, 16);
    if (errno != 0 || end == text || *end != '\0') return 0;
    *bits = (uint64_t)value;
    return 1;
}

int main(int argc, char **argv) {
    uint64_t input_bits;
    if (argc != 2 || !parse_bits(argv[1], &input_bits)) return 2;
    if (bingo_rt_abi_version_v1() != BINGO_RUNTIME_ABI_VERSION) return 3;
    double input;
    memcpy(&input, &input_bits, sizeof(input));
    double result = closureCounter(input);
    uint64_t result_bits;
    memcpy(&result_bits, &result, sizeof(result_bits));
    printf("%016" PRIx64 "\n", result_bits);
    return 0;
}
