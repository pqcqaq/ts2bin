#include <errno.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern double bingo_object_view_read_v1(void *source);

union aligned_object_storage {
    max_align_t alignment;
    unsigned char bytes[4096];
};

int main(int argc, char **argv) {
    if (argc != 3) return 2;
    char *offset_end = NULL;
    char *bits_end = NULL;
    errno = 0;
    unsigned long offset = strtoul(argv[1], &offset_end, 10);
    unsigned long long bits = strtoull(argv[2], &bits_end, 16);
    if (errno != 0 || offset_end == argv[1] || *offset_end != '\0' ||
        bits_end == argv[2] || *bits_end != '\0' || strlen(argv[2]) != 16 ||
        offset > sizeof(union aligned_object_storage) - sizeof(double)) return 2;

    union aligned_object_storage object;
    memset(&object, 0, sizeof(object));
    double value;
    memcpy(&value, &bits, sizeof(value));
    memcpy(object.bytes + offset, &value, sizeof(value));
    double result = bingo_object_view_read_v1(object.bytes);
    uint64_t output;
    memcpy(&output, &result, sizeof(output));
    printf("%016" PRIx64 "\n", output);
    return 0;
}
