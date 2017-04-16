                        README
           SafeG porting for the QEMU Vexpress-A9 target

                2012 (C) Daniel Sangorrin
                daniel.sangorrin@gmail.com

--------
Overview
--------

TOPPERS/SafeG (Safety Gate) is a dual-OS monitor designed to concurrently
execute an RTOS (Real-Time Operating System) and a GPOS (General-Purpose
Operating System) on the same hardware platform. SafeG's architecture takes
advantage of the ARM TrustZone security extensions which introduce the
concept of Trust and Non-Trust states

- Trust state provides similar behavior to existing privileged and user mode
levels in ARM processors.

- On the other hand, code running under Non-Trust state, even in privileged
mode, cannot access memory space (devices included) that was allocated for
Trust state usage, nor can it execute certain instructions that are
considered critical.

In order to control the TrustZone state, a new mode called "Secure Monitor"
mode has been added to the processor. Switching between Trust and Non-Trust
state is performed under Security Monitor mode by SafeG with interrupts
disabled.

THIS SOFTWARE IS PROVIDED "AS IS." THE ABOVE COPYRIGHT HOLDERS AND
THE TOPPERS PROJECT DISCLAIM ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, ITS APPLICABILITY TO A PARTICULAR
PURPOSE. IN NO EVENT SHALL THE ABOVE COPYRIGHT HOLDERS AND THE
TOPPERS PROJECT BE LIABLE FOR ANY TYPE OF DAMAGE DIRECTLY OR
INDIRECTLY CAUSED FROM THE USE OF THIS SOFTWARE.

----------------
Host environment
----------------

This target has been tested with Ubuntu 12.04 LTS. 
Applications and libraries that must be installed are:

- libboost libraries (>1.46) [for the TOPPERS configurator]
sudo apt-get install libboost-regex-dev libboost-system-dev \
libboost-filesystem-dev libboost-program-options-dev

- ARM cross-compiler [for compilation]
arm-none-eabi-gcc (Sourcery CodeBench Lite 2012.03-56) 4.6.3
(http://www.mentor.com/embedded-software/sourcery-tools/sourcery-codebench/editions/lite-edition/)
Note: other compilers or versions have not been tested and may not work.

- Other packages
sudo apt-get install build-essential libsdl-dev

------------------
Build instructions
------------------

FMP:

$ tar zxvf fmp_vexpressa9_gcc-20121210.tar.gz
$ cd safeg/fmp-app/
$ make realclean
$ make TARGET=vexpressa9_gcc SAFEG=SECURE ENABLE_QEMU=true PRC_NUM=1 fmp.bin &&
$ sudo cp fmp.bin /var/lib/tftpboot/t.bin

Linux:

$ tar jxvf linux-3.6.6-vanilla.tar.bz2
$ cd linux-3.6.6/
$ cp arch/arm/configs/vexpress_defconfig .config
$ make ARCH=arm menuconfig
    system type → select versatile express a9x4 board
$ make ARCH=arm CROSS_COMPILE=arm-none-eabi-
$ cd ../safeg/kernel-wrapper/
$ cp ../linux-3.6.6/arch/arm/boot/Image .
$ make
$ sudo cp nt-linux.bin /var/lib/tftpboot/nt.bin

Buildroot:

$ tar jxvf buildroot-2012.08.tar.bz2
$ sudo apt-get install ncurses-dev bison flex texinfo
$ make menuconfig
    Target → ARM little endian
    Target architecture → Cortex-A9
    Filesystem images → ext2 root filesystem + tar the root filesystem
$ make
$ cp buildroot/output/images/rootfs.ext2 .

U-BOOT:
$ tar zxvf u-boot-linaro-stable-5b752a1.tar.gz
$ cd u-boot-linaro-stable-5b752a1/
$ patch -p1 < ../fmp/target/vexpressa9_gcc/0001-UBOOT-multicore-and-safeg-support.patch
$ make vexpress_ca9x4_config
$ make

QEMU:
$ tar jxvf qemu-trustzone.tar.gz
$ cd qemu-trustzone/
$ patch -p1 < ../../prebuilt/0001-QEMU-fix-arm-gic-targets.patch
$ ./configure --target-list="arm-softmmu" --disable-strip --disable-xen --disable-kvm --disable-user --disable-docs --enable-debug --enable-debug-tcg
$ make

SafeG:
$ cd safeg/
$ make TARGET=vexpress-a9

--------------------
Loading instructions
--------------------

$ cd u-boot-linaro-stable-5b752a1/
$ ../qemu-trustzone/src/arm-softmmu/qemu-system-arm -cpu cortex-a9 -M vexpress-a9 -smp 1 -serial vc:80Cx40C -serial vc:80Cx40C -serial vc:80Cx40C -serial vc:80Cx40C -no-reboot -m 1024M -tftp /var/lib/tftpboot/  -drive if=sd,cache=writeback,file=../buildroot/rootfs.ext2 -kernel u-boot

u-boot# run loadsafeg

Use Ctrl+Alt+4,5 to see both world's output.

----------------------
Debugging instructions
----------------------

$ ../qemu-trustzone/src/arm-softmmu/qemu-system-arm -cpu cortex-a9 -M vexpress-a9 -smp 1 -serial vc:80Cx40C -serial vc:80Cx40C -serial vc:80Cx40C -serial vc:80Cx40C -no-reboot -m 1024M -tftp /var/lib/tftpboot/  -drive if=sd,cache=writeback,file=../buildroot/rootfs.ext2 -kernel u-boot -s -S

$ cd safeg/
$ ddd --debugger arm-none-eabi-gdb ./safeg.elf
$ target remote localhost:1234
$ c

u-boot# run loadsafeg

$ break smc_handler
$ cont / next / ..
