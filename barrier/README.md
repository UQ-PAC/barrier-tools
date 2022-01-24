# BAP `barrier` plugin

This [BAP](https://github.com/BinaryAnalysisPlatform/bap) plugin
provides support for `dmb`, `dsb` and `isb` instructions in ARMv8
by representing them in BIL/BIR as function calls.
For example, using `bap-mc` to lift the opcode of `dmb ish` into BIL gives 
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
The function stubs at the bottom (`sub ...`) can be ignored,
so to identify barriers in the output, search for function calls
with names matching `__arm_barrier_<type>_<option>`.

## Installation

### 1. Installing `bap`

To install **PAC's fork** of BAP (compile from source):
1. `cd` to the parent directory that `bap` will be cloned into.
2. Run `barrier-tools/bap-setup/all_in_one.sh`. This will install relevant
  dependencies, clone, configure and build PAC's fork of `bap`.

Alternatively, to install the **main version** of BAP from OPAM:
1. Change to your preferred OPAM switch (run `opam switch list` to list them).
  If there's only one switch, that's the system one -- create a new one with
  `opam switch create <switch-name> 4.09.0`.
2. Run `opam update`.
3. Run `opam install bap`.

This plugin does not require modifying `bap`'s source. 

### 2. Installing the `barrier` plugin

1. Just run `./autobuild.sh`. 

Note that if the directory `${HOME}/.local/share/bap/primus/semantics`
does not exist, the script will create it and copy `aarch64barrier.lisp`
in so `bap` can see it.

### Troubleshooting

When running `./autobuild.sh`, if you get an error complaining about function
signatures (like "applied to too many arguments"), run `opam update; opam upgrade`
to update BAP's cached interface files.
