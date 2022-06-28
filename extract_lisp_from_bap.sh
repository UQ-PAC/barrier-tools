# this updates the directory bap watches
# with the relevant lisp files from within the bap source directory.
# use it like: ./extract_lisp_from_bap.sh "${HOME}/bap"

if [ $# -ne 1 ]; then
    bap_src_dir=.
else
    bap_src_dir=$1
fi
searched_dir="${HOME}/.local/share/bap/primus"

mkdir -p ${searched_dir}/{semantics,lisp}

cp ${bap_src_dir}/plugins/arm/semantics/*.lisp ${searched_dir}/semantics
cp ${bap_src_dir}/plugins/primus_lisp/semantics/bits.lisp ${searched_dir}/semantics
cp ${bap_src_dir}/plugins/primus_lisp/lisp/*.lisp ${searched_dir}/lisp
