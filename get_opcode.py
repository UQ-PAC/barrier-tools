"""
This code is used by `get_opcode.sh` to parse `objdump` output
and format the opcodes correctly.
"""

import sys
import re

# matches against text such as
#    8:   aa0003e0        mov     x0, x0
PATTERN = re.compile(r"\s*\d+:\s+([0-9a-f]+)\s+(.*)")

# assume opcodes come after "0000000000000000 <.text>:"
# in the objdump output
objdump_output = "".join(sys.stdin).strip() \
                   .partition("0000000000000000 <.text>:\n")[2] \
                   .split("\n")

for line in objdump_output:
    opcode, mnemonics = PATTERN.match(line).groups()
    bytes = [opcode[i:i+2] for i in range(0, len(opcode), 2)]
    bytes.reverse()  # little endian
    print(" ".join(bytes), end=" ")
    # verbose option - how to implement?
    # print(f"{' '.join(bytes)}  :  {mnemonics}")
print("")
