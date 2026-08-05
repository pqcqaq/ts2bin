#include <stdint.h>
#include <stdio.h>

extern int32_t bingo_rt_v1_smoke_add(int32_t left, int32_t right);

int main(void) {
    int32_t result = bingo_rt_v1_smoke_add(20, 22);
    if (result != 42) {
        fprintf(stderr, "runtime link smoke returned %d\n", result);
        return 1;
    }
    puts("Rust staticlib + LLD smoke passed");
    return 0;
}
