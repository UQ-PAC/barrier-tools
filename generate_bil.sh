#!/bin/bash

# takes a C source file, compiles it for armv8-aarch64, and produces bil output

aarch64-linux-gnu-gcc "$1" &&
aarch64-linux-gnu-gcc "$1" -S &&
bap a.out -d > output.bil
