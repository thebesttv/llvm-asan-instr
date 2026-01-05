// RUN: %clangxx_asan -O0 %s -o %t && %run %t 2>&1 | FileCheck %s

#include <sanitizer/asan_interface.h>

int global;

int main(int argc, char *argv[]) {
  int stack;
  int *heap = new int[100];
  __asan_describe_address(heap, 1);
  // CHECK: ID: 1
  // CHECK: {{.*}} is located 0 bytes inside of 400-byte region
  // CHECK: allocated by thread T{{.*}} here
  __asan_describe_address(&stack, 2);
  // CHECK: ID: 2
  // CHECK: Address {{.*}} is located in stack of thread T{{.*}} at offset {{.*}}
  __asan_describe_address(&global, 3);
  // CHECK: ID: 3
  // CHECK: {{.*}} is located 0 bytes inside of global variable '{{.*}}global{{.*}}'
  delete[] heap;
  return 0;
}
