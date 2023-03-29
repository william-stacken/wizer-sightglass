
#include <stdio.h>
#include <stdbool.h>

//#ifdef __EMSCRIPTEN__
//static void __wasm_call_dtors() {}
//#endif

#include "wizer.h"
#include "sightglass.h"

class Test {
  public:
    Test() : value(1) {
        printf(
            "global constructor (should be the first printed line)\n");
    }
    ~Test() {
        printf("global destructor (should be the last printed line)\n");
    }
    int value;
};

bool initialized = false;
int orig_value = 0;
Test t;

static void init_func()
{
    printf("Initializing...\n");
    orig_value = t.value;
    t.value = 2;
    initialized = true;
}


WIZER_INIT(init_func);

int main()
{
    printf("[noop] calls bench_start and bench_end with no intervening code\n");
    bench_start();
    if (!initialized) {
        // Include calling the constructors in the initialization time for
        // the baseline Wasm module
        // Emscripten will call the constructor in _start regardless of whether we
        // call it here, but calling the constructors twice should hopefully not
        // cause any bad sideeffects
        __wasm_call_ctors();

        // Call the wizer initialize function
        init_func();

        // Stop the timer and manually call destructors since the compiler
        // does not insert a call automatically
        bench_end();
        printf("[noop] complete\n");
        __wasm_call_dtors();
    } else {
        // This module is pre-initialized, no need to call constructors or destructors
        // since wizer handles it automatically
        bench_end();
        printf("[noop] complete\n");
    }
}
