
#include <stdio.h>
#include "wizer.h"
#include "sightglass.h"

int initialized = 0;

static void init_func()
{
    initialized = 1;
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
