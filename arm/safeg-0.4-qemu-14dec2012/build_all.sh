rm -R -f build
mkdir -p build
cd build
tar zxvf ../src/fmp_vexpressa9_gcc-20121214.tar.gz
make -C ../fmp-app SRCDIR=../build/fmp realclean
make -C ../fmp-app TARGET=vexpressa9_gcc SAFEG=SECURE ENABLE_QEMU=true PRC_NUM=1 SRCDIR=../build/fmp/ GCC_TARGET=arm-none-eabi fmp.bin
tar jxvf ../src/linux-3.6.10.tar.bz2
cd linux-3.6.10/
cp ../../prebuilt/linux-3.6.6.config .config
make ARCH=arm CROSS_COMPILE=arm-none-eabi- silentoldconfig
make ARCH=arm CROSS_COMPILE=arm-none-eabi-
cp arch/arm/boot/Image ../../safeg/kernel-wrapper/
make -C ../../safeg/kernel-wrapper/ clean
make -C ../../safeg/kernel-wrapper/
cd ..
tar zxvf ../src/u-boot-linaro-2012.11.1.tar.gz
cd u-boot-linaro-stable-c5d34d0/
patch -p1 < ../fmp/target/vexpressa9_gcc/0001-UBOOT-multicore-and-safeg-support.patch
make CROSS_COMPILE=arm-none-eabi- vexpress_ca9x4_config
make CROSS_COMPILE=arm-none-eabi-
cd ..
unzip ../src/devel.zip
cd qemu-trustzone-devel/
patch -p1 < ../../prebuilt/0001-QEMU-fix-arm-gic-targets.patch
./configure --target-list="arm-softmmu" --disable-strip --disable-xen --disable-kvm --disable-user --disable-docs --enable-debug --enable-debug-tcg
make
cd ../../
make -C safeg TARGET=vexpress-a9



