#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern double derivedCounter(double start, double step);

int main(int argc, char **argv) {
  if (argc != 3 || strlen(argv[1]) != 16 || strlen(argv[2]) != 16) return 2;
  char *end = NULL;
  uint64_t start_bits = strtoull(argv[1], &end, 16);
  if (end == NULL || *end != 0) return 2;
  uint64_t step_bits = strtoull(argv[2], &end, 16);
  if (end == NULL || *end != 0) return 2;
  double start, step, result;
  memcpy(&start, &start_bits, sizeof(start));
  memcpy(&step, &step_bits, sizeof(step));
  result = derivedCounter(start, step);
  uint64_t result_bits;
  memcpy(&result_bits, &result, sizeof(result_bits));
  printf("%016" PRIx64 "\n", result_bits);
  return 0;
}
