#include <stdint.h>
#include <stdio.h>

typedef void *(*bingo_source_fn)(void *environment, void *value);

typedef struct bingo_function_ref {
    bingo_source_fn code;
    void *environment;
} bingo_function_ref;

extern void *bingo_function_thunk_object_v1(bingo_function_ref source, void *value);

static void *expected_environment;
static int environment_preserved;

static void *source(void *environment, void *value) {
    environment_preserved = environment == expected_environment;
    return value;
}

int main(void) {
    uint64_t environment = UINT64_C(0x1122334455667788);
    uint64_t object = UINT64_C(0x8877665544332211);
    expected_environment = &environment;
    bingo_function_ref ref = {source, &environment};
    void *result = bingo_function_thunk_object_v1(ref, &object);
    printf("%d %d\n", environment_preserved, result == &object);
    return environment_preserved && result == &object ? 0 : 1;
}
