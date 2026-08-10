#include "bingo_abi.h"

int main(void) {
    bingo_startup_empty_v1();
    return bingo_rt_abi_version_v1() == BINGO_RUNTIME_ABI_VERSION ? 0 : 1;
}
