FROM ubuntu@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e

# Packages
RUN apt-get update
RUN apt-get install -y qemu qemu-system-x86 qemu-utils cpio gzip socat bzip2 flex
RUN rm -rf /var/lib/apt/lists/*

# Low priv user
RUN useradd -d /home/ctf -m -p ctf -s /bin/bash ctf
RUN echo "ctf:ctf" | chpasswd
RUN ulimit -c 0

# Copy challenge contents
COPY launch.sh /src/launch.sh
RUN chmod +x /src/launch.sh
COPY bzImage /src/bzImage
COPY initramfs.cpio.gz /src/initramfs.cpio.gz

EXPOSE 8888
CMD socat tcp-l:8888,reuseaddr,fork EXEC:"/src/launch.sh",pty,stderr
