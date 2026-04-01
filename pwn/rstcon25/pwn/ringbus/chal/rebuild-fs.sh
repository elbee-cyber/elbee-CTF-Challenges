#!/bin/bash

# LIFE SUCKS, DO NOT DISTRIBUTE!

pushd chalfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../dist_files/initramfs.cpio.gz
popd
