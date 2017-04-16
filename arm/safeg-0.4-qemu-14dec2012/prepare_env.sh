arm-none-eabi-gcc --version >/dev/null 2>&1 || { echo "SafeG requires arm-none-eabi-gcc (arm-2012.03-56-arm-none-eabi.bin) cross-compiler to be installed."; exit 1;}
sudo apt-get update || { echo "SafeG requires Internet to download source code."; exit 1;}
sudo apt-get install build-essential libsdl-dev libboost-regex-dev libboost-system-dev libboost-filesystem-dev libboost-program-options-dev

