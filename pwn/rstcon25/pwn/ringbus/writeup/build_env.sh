#!/bin/bash

cp ../chal/deploy/initramfs.cpio.gz .
cp ../chal/deploy/bzImage .
cp ../chal/src/ringbus.ko .

#./extract-image.sh bzImage > vmlinux
cp ../chal/linux-*/vmlinux .
./utilities/decompress.sh

cp init ./initramfs
./utilities/rebuild-fs.sh
