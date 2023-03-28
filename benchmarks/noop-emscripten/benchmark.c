
#include <stdio.h>
#include <stdbool.h>

#ifdef __EMSCRIPTEN__
static void __wasm_call_dtors() {}
#endif

#include "wizer.h"
#include "sightglass.h"

bool initialized = false;

static void init_func()
{
    for (int i = 0; i < 100000000; i++);

    initialized = true;
}

WIZER_INIT(init_func);

int main()
{
    printf("[noop] calls bench_start and bench_end with no intervening code\n");
    bench_start();
    if (!initialized)
        init_func();
    bench_end();
    printf("[noop] complete\n");
}
