bapbuild -pkgs ppx_bap,core_kernel,bap,bap-primus,bap-knowledge,monads barrier.plugin
bapbundle install barrier.plugin
searched_directory="${HOME}/.local/share/bap/primus/semantics"
mkdir -p -v "$searched_directory"
cp aarch64barrier.lisp "$searched_directory"/aarch64barrier.lisp