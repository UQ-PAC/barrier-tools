#!/bin/bash

# gets the bap source and configures it for 

# configures bap for specific use with our lifter

# make sure we're inside bap directory (or grab it if not)
CURR=${PWD##*/} # get last name of dir

if [ -d "bap" ]; then
	cd bap
else
	echo "[!] Bap directory not found, either we're already inside or we need to clone";
	if [ ! ${CURR} = "bap" ]; then
		echo "[!] Assuming bap hasn't been cloned, so cloning and moving inside...";
	
		git clone "https://github.com/UQ-PAC/bap.git" && cd bap
	fi
fi

# configure bap installation for our use
llvm_params="--with-llvm-version=9 --with-llvm-config=llvm-config-9" # lifter needs llvm to function
location=$(opam config var prefix) # where to find opam information (dependencies, current switch, etc)

# we found that disabling everything didn't work... This is likely as the lifter, since
# being implemented in their primus machine, is highly integrated with the core bap 
# functionality as opposed to before, where it was effectively a plugin (see bap/lib/arm/arm_lifter.ml)
# NOTE: there are definitely further features that can be disabled (see ghidra below), and that
# will reduce the size of the end binary, but we decided this currently isn't a major detriment
# to the overall project at the cost of exhaustive hours deciding which features are crucial to execution
# and not.

#  ghidra is unneeded, and toplevel introduced `baptop` which was giving us compilation errors
features="--enable-everything --enable-arm --disable-toplevel --disable-ghidra"

./configure ${features} --prefix=${location} ${llvm_params}

if [ $? -ne 0 ]; then
	echo "[-] Something went wrong in configuration"
	exit 42
fi
