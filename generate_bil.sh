aarch64-linux-gnu-gcc "$1" &&
aarch64-linux-gnu-gcc "$1" -S &&
bap a.out -d > output.bil
