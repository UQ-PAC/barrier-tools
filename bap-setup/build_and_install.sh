#!/bin/bash

# Makes and attempts to install bap

CURR_SWITCH=$(opam switch show)
CURR_DIR=${PWD##*/}

# First enter the bap directory (assumed to exist, run after `clone_and_configure.sh`)
if [ ! ${CURR_DIR} = "bap" ]; then
	cd bap;
fi

# compile and try to install
make && make reinstall

# In our testing, this often failed the first time around due to extraneous directories.
# If the above failed, then we can rectify that
if [ $? -ne 0 ]; then
	# rm our troubles away
	cd ~/.opam/${CURR_SWITCH}/lib;
	rm -rf text-tags regular ogre monads graphlib
	rm -rf bitvec*
	rm -rf bare
	rm -rf bap*
	rm -rf stublibs

	cd -; # go back to bap directory
	
	# try and remake
	make reinstall

	if [ $? -ne 0 ]; then
		# well we did our best...
		echo "Baaaaaaad things happened... Suggest restarting from scratch";
		exit 42;			   
	fi
fi

