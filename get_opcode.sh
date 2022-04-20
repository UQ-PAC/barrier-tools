#!/bin/bash

# takes an assembly string and outputs the hex opcode associated with said instruction

# example: 
# ```
# $ ./get_opcode "mov x0, #1"
# 20 00 80 d2
# ```

# this script is intended for use with bap-mc

# example:
# ```
# $ bap-mc --arch==aarch64 --show-bil -- $(./get_opcode "mov x0, #1")
# ... bap-mc output of 
# ```

INSN=$1

# make storage area
TMP_DIR=/tmp/${USER}/decomp
mkdir -p ${TMP_DIR}

# assemble instruction
echo ${INSN} | aarch64-linux-gnu-as -march=armv8.5-a - -o ${TMP_DIR}/tmp.o
return_code=$?
if [ "$return_code" -ne 0 ]; then
    exit "$return_code"
fi

# decompile into insns
objdump -D ${TMP_DIR}/tmp.o > ${TMP_DIR}/tmp.asm

# parsing into nice format that can be interpreted by bap-mc
cat ${TMP_DIR}/tmp.asm | grep -v "<\.[a-zA-Z0-9]*>" | grep -oP '(?<=\s)([0-9a-f]{8})' |  sed -r "s/([0-9a-f]{2})/\1 /g; s/([0-9a-f]{2}\s)([0-9a-f]{2}\s)([0-9a-f]{2}\s)([0-9a-f]{2}\s)/\4\3\2\1/"
