#!/bin/bash

# just combines the other scripts

# install relevant dependencies
echo "[*] Installing dependencies now..."
./install_deps.sh

if [ $? -eq 0 ]; then
	echo "[+] Success"
else
	echo "[-] Uh oh...."
fi

# clone and set up environment
echo "[*] Setting up directories..."
./clone_and_configure.sh

if [ $? -eq 0 ]; then
	echo "[+] Success"
else
	echo "[-] Uh oh...."
fi

# install bap (or try at least -.-)
echo "[*] Attempting to install bap..."
./build_and_install.sh

if [ $? -eq 0 ]; then
	echo "[+] We should be done!"
else
	echo "[-] Uh oh...."
fi
