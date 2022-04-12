#if defined (__AVX512CD__) || (defined __AVX512DQ__) || defined (__AVX512F__) || (defined __AVX512VL__)
#error ORANGES_AVX512 1
#endif

#error ORANGES_AVX512 0
