#!/bin/sh

# Build challenge
cd src
make
cd ../initramfs
cp ../src/ringbus.ko .
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
cd ..
cp initramfs.cpio.gz deploy/

