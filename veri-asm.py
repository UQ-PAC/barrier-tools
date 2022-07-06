#!/usr/bin/python3


import os
from os import sys
import random

"""

1. assemble (static)
2. qemu and trace
3. objdump 
4. minify trace
5. bap-veri trace

"""

rprefix = random.randint(0, 0xffffffffffff) 

program = sys.argv[0]
usage = "Usage: " + program + " progname \n\techo 'asm' | " + program

if (len(sys.argv) > 2):
    print(usage)
    exit(1)

def onerr(status):
    if os.WIFSIGNALED(status):
        returncode = -os.WTERMSIG(status)
    elif os.WIFEXITED(status):
        returncode = os.WEXITSTATUS(status)
    elif os.WIFSTOPPED(status):
        returncode = -os.WSTOPSIG(status)
    else:
        returncode = -1

    if (returncode != 0):
        print("error", repr(returncode)) 
        exit(returncode)

filename = "standard-input"
source = []

if len(sys.argv) == 2:
    filename = sys.argv[1]

    with open(filename, "r") as f:
        source = f.readlines()
else:
    for line in sys.stdin:
        source.append(line)


c_stub = "int main(void) {\n"
c_stub += "    __asm__( \\\n"

for line in source:
    c_stub += "    \"" + line[:-1] + "\\n\"\\\n" 

c_stub += "    );\n"
c_stub += "    return 0;\n"
c_stub += "}\n"


dumpfile = f"/tmp/{program}{rprefix}.tmp"
cfile = f"/tmp/{program}{rprefix}.prog.c"
otracefile = f"/tmp/{program}{rprefix}-otrace.frames"
maintracefile = f"/tmp/{program}{rprefix}-maintrace.frames"
veri_out = f"/tmp/{program}{rprefix}-veri.txt"
binfile = f"/tmp/{program}{rprefix}.out"

print(c_stub)

with open(cfile, "w") as f:
    f.write(c_stub)

run = [f"aarch64-linux-gnu-gcc -static {cfile} -o {binfile}",
    f"objdump --disassemble=main {binfile} > {dumpfile}",
    f"qemu-aarch64 -tracefile {otracefile} {binfile}",
    f"slicetrace -i {otracefile} -o {maintracefile} -d {dumpfile}",
    f"bap-for-veri veri --show-errors --show-stat --rules /home/adriel/veri/bap-veri/rules/aarch64_qemu {maintracefile} > {veri_out}"]


for c in run:
    print(c)
    e = os.system(c)
    onerr(e)

for f in [dumpfile, veri_out]:
    with open(f, 'r') as fl:
        print(fl.read())

for f in [dumpfile, veri_out, cfile, otracefile,maintracefile,binfile]:
    os.system("rm " + f)

