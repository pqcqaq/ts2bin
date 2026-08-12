#include <errno.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void bingo_object_view_read_accessor_v1(void *source, double *payload_out, uint8_t *tag_out);

union aligned_accessor_storage {
    max_align_t alignment;
    unsigned char bytes[4096];
};

int main(int argc, char **argv) {
    if (argc != 4) return 2;
    char *offset_end = NULL;
    char *tag_end = NULL;
    char *bits_end = NULL;
    errno = 0;
    unsigned long offset = strtoul(argv[1], &offset_end, 10);
    unsigned long tag = strtoul(argv[2], &tag_end, 10);
    unsigned long long bits = strtoull(argv[3], &bits_end, 16);
    if (errno != 0 || offset_end == argv[1] || *offset_end != '\0' ||
        tag_end == argv[2] || *tag_end != '\0' || tag > 2 ||
        bits_end == argv[3] || *bits_end != '\0' || strlen(argv[3]) != 16 ||
        offset > sizeof(union aligned_accessor_storage) - 9) return 2;

    union aligned_accessor_storage object;
    memset(&object, 0, sizeof(object));
    double payload;
    memcpy(&payload, &bits, sizeof(payload));
    memcpy(object.bytes + offset, &payload, sizeof(payload));
    object.bytes[offset + 8] = (uint8_t)tag;

    double output_payload = 0;
    uint8_t output_tag = 0xff;
    bingo_object_view_read_accessor_v1(object.bytes, &output_payload, &output_tag);
    uint64_t output_bits;
    memcpy(&output_bits, &output_payload, sizeof(output_bits));
    printf("%u:%016" PRIx64 "\n", output_tag, output_bits);
    return 0;
}
