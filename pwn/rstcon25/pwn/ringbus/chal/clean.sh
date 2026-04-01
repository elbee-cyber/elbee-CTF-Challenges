#!/bin/sh

cd src
make clean
cd ..
rm initramfs.cpio.gz
rm linux-5.17* -rf
rm deploy/bzImage
rm deploy/initramfs.cpio.gz
rm dist_files/bzImage
rm dist_files/ringbus.c
rm dist_files/initramfs.cpio.gz
rm ../dist/dist.tar
rm chalfs -rf
