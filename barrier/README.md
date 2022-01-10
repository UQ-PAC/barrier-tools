# BAP `barrier` plugin

This [BAP](https://github.com/BinaryAnalysisPlatform/bap) plugin
provides support for `dmb`, `dsb` and `isb` instructions in ARMv8
by representing them in BIL/BIR as calls to external functions.
For example, using `bap-mc` to lift `dmb ish;` into BIL gives 
```
$ bap-mc --arch=aarch64 --show-bil -- bf 3b 03 d5
{
  call(__arm_barrier_dmb_ish)
}
```
Similarly, for the following C file, running `bap disassemble` on
the ARM executable gives the following:
```c
// atomic_thread_fence.c
#include <stdatomic.h>

int main() {
    atomic_thread_fence(memory_order_release);
}
```
```
$ aarch64-linux-gnu-gcc atomic_thread_fence.c
$ bap disassemble a.out -d
<...>
000003e6:
000003e9: call @__arm_barrier_dmb_ish with noreturn
<...>
000003e7: sub __arm_barrier_dmb_ish(__arm_barrier_dmb_ish_result)
000005cb: __arm_barrier_dmb_ish_result :: out u32 = R0
```
This extraneous information about the function (`sub ...`) *should*™
be able to be removed without worry, leaving the user to extract the
location of the barriers by matching against
`__arm_barrier_<type>_<option>` in the output.
This will be confirmed soon.

## Installation
After BAP has been successfully installed, run `./autobuild.sh`.
Note that if the directory does not exist, the script will create
`${HOME}/.local/share/bap/primus/semantics` and copy `aarch64barrier.lisp`
in so BAP can see it.

**Note:** it *may* be necessary to also install BAP's dependencies through
`../build_bap.sh` to get `barrier.ml` to compile --- need to test this.