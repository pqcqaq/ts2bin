#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern double classCounter(double value);

int main(int argc, char **argv) {
    if (argc != 2 || strlen(argv[1]) != 16) return 2;
    char *end = NULL;
    uint64_t input = strtoull(argv[1], &end, 16);
    if (end == NULL || *end != '\0') return 2;
    double value;
    memcpy(&value, &input, sizeof(value));
    double result = classCounter(value);
    uint64_t output;
    memcpy(&output, &result, sizeof(output));
    printf("%016" PRIx64 "\n", output);
    return 0;
}
