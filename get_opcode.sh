tmpbin="/tmp/getopcode_bin_"$USER
echo "$@" | aarch64-linux-gnu-as - -o "${tmpbin}" &&
objdump "${tmpbin}" -D | python3 get_opcode.py

rm "${tmpbin}"
