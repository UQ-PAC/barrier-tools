echo "$@" | aarch64-linux-gnu-as - -o /tmp/getopcode_bin \
    && objdump /tmp/getopcode_bin -D | python3 get_opcode.py 
