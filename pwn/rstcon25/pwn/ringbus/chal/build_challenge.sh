#!/bin/sh
FLAG="rstcon{r1ngspr4y_1s_n0t0k}"

# Dependencies
read -p "Do you want to install dependencies (for solving/debugging/etc locally)? (y/n): " install_deps
if [ "$install_deps" = "y" ] || [ "$install_deps" = "Y" ]; then
    sudo apt update
    sudo apt-get install -y bison flex libelf-dev cpio pahole build-essential musl-tools libssl-dev qemu-system-x86
else
    echo "[*] Skipped dependency installation..."
fi

# Build kernel
## Stolen from https://github.com/ARESxCyber/pwnkernel
echo "[+] Downloading kernel..."
wget -q -c https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.17.tar.gz
[ -e linux-5.17 ] || tar xzf linux-5.17.tar.gz

echo "[+] Building kernel..."
cp chalconfig linux-5.17/.config

## Newer pahole versions incompatible
## https://unix.stackexchange.com/questions/754325/failed-load-btf-from-vmlinux-invalid-argument-make-on-config-debug-info-btf-y
sed -i 's/\bpahole\b/pahole --skip_encoding_btf_enum64/g' linux-5.17/Makefile
## Ignore warnings
make WERROR=0 -C linux-5.17 -j$(nproc)

# Build w this instead to use codeql to find good objects for spraying
#~/codeql/codeql database create cq-database --language=cpp --command="make WERROR=0 -C linux-5.17 -j16"

# Build challenge
echo "[+] Building challenge module"
cd src
make
cd ..

# Build initramfs
echo "[+] Building initramfs"
echo $FLAG > initramfs/flag
cp src/ringbus.ko initramfs/
cd initramfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
cd ..

# Prepare deploy
echo "[+] Configuring deploy/"
cp initramfs.cpio.gz deploy/
cp linux-5.17/arch/x86/boot/bzImage deploy/

# Build dist
echo "[+] Building ../dist/dist.tar"
cp linux-5.17/arch/x86/boot/bzImage dist_files/
cp src/ringbus.c dist_files
cp initramfs ./chalfs -r
echo "rstcon{000000000000000000}" > ./chalfs/flag
./rebuild-fs.sh
cd dist_files/ && tar -cvf ../../dist/dist.tar ./*
