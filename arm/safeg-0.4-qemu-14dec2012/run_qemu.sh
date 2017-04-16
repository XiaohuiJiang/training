cp fmp-app/fmp.bin build/t.bin
cp safeg/kernel-wrapper/nt-linux.bin build/nt.bin
cp safeg/safeg.bin build/
./build/qemu-trustzone-devel/arm-softmmu/qemu-system-arm -cpu cortex-a9 -M vexpress-a9 -smp 1 -serial vc:80Cx40C -serial vc:80Cx40C -serial vc:80Cx40C -serial vc:80Cx40C -no-reboot -m 1024M -tftp build/ -drive if=sd,cache=writeback,file=prebuilt/rootfs.ext2 -kernel build/u-boot-linaro-stable-c5d34d0/u-boot



