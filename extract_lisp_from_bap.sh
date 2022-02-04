# this updates the directory bap watches
# with the relevant lisp files from within the bap source directory.
# use it like: ./extract_lisp_from_bap.sh "${HOME}/bap"

CURR_SWITCH=$(opam switch show)
bap_src_dir=$1
searched_dir="${HOME}/.opam/${CURR_SWITCH}/share/bap/primus"

cp ${bap_src_dir}/plugins/arm/semantics/*.lisp ${searched_dir}/semantics
cp ${bap_src_dir}/plugins/primus_lisp/semantics/bits.lisp ${searched_dir}/semantics
cp ${bap_src_dir}/plugins/primus_lisp/lisp/*.lisp ${searched_dir}/lisp
