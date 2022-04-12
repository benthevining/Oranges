#if (defined (__SSE__) || (defined __SSE2__) || (defined __SSE3__) || (defined __SSE4_1__))
#error ORANGES_SSE 1
#endif

#if (defined(_M_AMD64) || defined(_M_X64))
#error ORANGES_SSE 1
#endif

#if defined _M_IX86_FP
#if _M_IX86_FP == 1 || _M_IX86_FP == 2
#error ORANGES_SSE 1
#endif
#endif

#error ORANGES_SSE 0
