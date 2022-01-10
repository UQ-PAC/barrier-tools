#!/bin/bash

# This script builds bap entirely from scratch

opam install bap --deps-only

if [ $1 = "-c" ]; then
	git clone "https://github.com/UQ-PAC/bap.git"
fi


# opam doesn't install these dependencies first for some reason
# so do its job for it -.-
opam install depext
opam install piqi ocurl yojson ezjsonm

# enter sandman
cd bap
BAP_DIR=$(pwd)

# ready to configure!
./configure --enable-everything --enable-arm --disable-ghidra --prefix=`opam config var prefix` --with-llvm-version=9 --with-llvm-config=llvm-config-9

# compile and try install
make
make reinstall

RET=$?

# if make reinstall failed on the first time, it's likely because these exist. So destroy them
if [ ${RET} -ne 0 ]; then
	cd ~/.opam/$(opam switch info)/lib
	rm -rf text-tags regular ogre monads graphlib
	rm -rf bitvec*
	rm -rf bare
	rm -rf bap*
	rm -rf stublibs

	cd ${BAP_DIR}	
	make reinstall
fi

RET=$?

if [ ${RET} -ne 0 ]; then
	echo "Baaaaaad things happenin'";
	exit 42;	
fi
