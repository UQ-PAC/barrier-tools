# barrier-tools
[BAP](https://github.com/BinaryAnalysisPlatform/bap) plugin for lifting ARMv8 barriers, associated tools and examples.

## `barrier`
See README inside `barrier`.

## `bap-setup`
Shell scripts to automate installing BAP and building from source.

## `examples`
Examples to verify lifter behaviour.

## Other files
`get_opcode.sh` returns the opcodes of ARMv8 instructions. (-v WIP)
```
$ ./get_opcode.sh "mov x0, x12; cmp x20, x19"
e0 03 0c aa 9f 02 13 eb
$ ./get_opcode.sh -v "mov x0, x12; cmp x20, x19"
e0 03 0c aa  :  mov     x0, x12
9f 02 13 eb  :  cmp     x20, x19
```
This can be used in conjunction with `bap-mc` to check lifter behaviour:
```
$ bap-mc --arch=aarch64 --show-bil -- $(./get_opcode.sh "cmp x20, x19")
{
  #3 := 1 + ~R19 + R20
  NF := extract:63:63[#3]
  VF := extract:63:63[R20] & extract:63:63[~R19] & ~extract:63:63[#3] |
    ~extract:63:63[R20] & ~extract:63:63[~R19] & extract:63:63[#3]
  ZF := #3 = 0
  CF := extract:63:63[R20] & extract:63:63[~R19] | extract:63:63[~R19] &
    ~extract:63:63[#3] | extract:63:63[R20] & ~extract:63:63[#3]
}
```

`generate_bil.sh` takes in a `.c` file and runs `aarch64-gnu-gcc` and `bap -d`
to generate BIL from the compiler output. It also generates the corresponding
assembly in a `.s` file.
