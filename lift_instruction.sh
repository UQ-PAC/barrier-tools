# All arguments except the last are provided to bap-mc,
# and the last is the asm to be run through get_opcode.sh.
#
# Examples:
# ./lift_instruction "mov x0, x0"
# ./lift_instruction -show-knowledge "mov x0, x0"

# gets directory that this script is in
script_dir=$(dirname "$(readlink -f "$0")")
initial_dir=$(pwd)

# https://stackoverflow.com/a/3352015
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

# https://stackoverflow.com/a/33271194
instruction=$(trim ${@:$#}) # last parameter 
# https://stackoverflow.com/a/6968547
bap_mc_options="${@:(-$#):($#-1)}"  # all parameters except the last

cd "$script_dir"

opcode=$(./get_opcode.sh "$instruction")
opcode_return_code=$?
if [ "$opcode_return_code" -ne 0 ]; then
    cd "$initial_dir"
    exit "$opcode_return_code"
fi

opcode=$(trim "$opcode")

echo "Instruction: $instruction"
echo "Opcode: $opcode"

if [ -z "$bap_mc_options" ]; then
    bap mc --show-bil --target=armv8.6-a+le -- $opcode
else
    bap mc --show-bil --target=armv8.6-a+le "$bap_mc_options" -- $opcode
fi

cd "$initial_dir"
