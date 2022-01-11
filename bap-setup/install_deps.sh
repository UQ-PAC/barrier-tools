#!/bin/bash

# This script installs all relevant dependencies for bap to function
# Something that should realistically be simple, but unfortunately was not

opam install bap --deps-only

# these dependencies are not installed by above, despite being required
opam install depext
opam install piqi ocurl yojson qzjsonm
