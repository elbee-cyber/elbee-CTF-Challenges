#!/bin/sh

qemu-system-x86_64 \
    -m 128M \
    -nographic \
    -kernel "./bzImage" \
    -append "console=ttyS0 loglevel=3 oops=panic panic=-1 pti=on kaslr" \
    -no-reboot \
    -monitor none \
    -cpu qemu64,+smep,+smap \
    -initrd "./initramfs.cpio.gz" \
    -fsdev local,security_model=passthrough,id=fsdev0,path=./src \
    -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \
    -s
