#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern double classAccess(void);

int main(int argc, char **argv) {
  (void)argv;
  if (argc != 1) return 2;
  double result = classAccess();
  uint64_t result_bits;
  memcpy(&result_bits, &result, sizeof(result_bits));
  printf("%016" PRIx64 "\n", result_bits);
  return 0;
}
