#!/bin/bash

# This script installs all relevant dependencies for bap to function
# Something that should realistically be simple, but unfortunately was not

# make sure opam is setup
opam init
eval $(opam env) || source ~/.profile

# install dependencies
opam install bap --deps-only

# these dependencies are not installed by above, despite being required
opam install depext
opam install piqi ocurl yojson ezjsonm
opam install bitstring z3 bitstring.3.1.1

# update environment variables
eval $(opam env)
