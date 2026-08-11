#include "bingo_abi.h"

#include <math.h>

enum {
    BINGO_APPLICATION_INVALID_RESULT = 70,
    BINGO_APPLICATION_ABI_MISMATCH = 71,
};

uint32_t bingo_application_startup_v1(void) {
    if (bingo_rt_abi_version_v1() != BINGO_RUNTIME_ABI_VERSION) {
        return BINGO_APPLICATION_ABI_MISMATCH;
    }
    bingo_startup_empty_v1();
    double result = bingo_program_main_v1();
    if (!isfinite(result) || result < 0.0 || result > 255.0 || trunc(result) != result) {
        return BINGO_APPLICATION_INVALID_RESULT;
    }
    return (uint32_t)result;
}

int main(void) {
    return (int)bingo_application_startup_v1();
}
