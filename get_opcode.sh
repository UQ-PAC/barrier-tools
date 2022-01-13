# gets directory that this script is in
script_dir=$(dirname "$(readlink -f "$0")")

initial_dir=$(pwd)
tmp_bin="/tmp/getopcode_bin_"$USER

cd "${script_dir}"
echo "$@" | aarch64-linux-gnu-as - -o "${tmp_bin}" &&
objdump "${tmp_bin}" -D | python3 get_opcode.py

rm "${tmp_bin}"
cd "${initial_dir}"
