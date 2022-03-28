# gets directory that this script is in
script_dir=$(dirname "$(readlink -f "$0")")

initial_dir=$(pwd)
tmp_bin="/tmp/getopcode_bin_"$USER

cd "${script_dir}"

echo "$@" | aarch64-linux-gnu-as -march=armv8.5-a - -o "${tmp_bin}"
return_code=$?
if [ "$return_code" -ne 0 ]; then
    cd "${initial_dir}"
    exit "$return_code"
fi

objdump "${tmp_bin}" -D | python3 get_opcode.py &&
rm "${tmp_bin}"
cd "${initial_dir}"
