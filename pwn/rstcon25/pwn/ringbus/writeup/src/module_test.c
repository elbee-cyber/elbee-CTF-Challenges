#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <signal.h>
#include <pthread.h>
#include <stdint.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/syscall.h>

#define RST 0x10
#define LEN_SET 0x20
#define DEV_SELECT 0x30
#define DEV_NEW 0x40

int fd;
typedef struct data{
	char * content;
    volatile size_t length;
};

void open_device(void) {
    puts("[*] Opening ringbus device...");
    fd = open("/dev/ringbus", O_RDWR);
    if (fd < 0) {
        puts("[!] Failed to open device");
        exit(-1);
    }
    printf("[+] Device opened successfully, fd: %d\n", fd);
}

void close_device(void) {
    if(close(fd) == -1) {
        puts("[!] Error closing the device");
        exit(-1);
    }
    puts("[+] Device closed");
}

void *rst(void *arg){
    ioctl(fd, RST);
}

long add_dev() {
    long code = ioctl(fd, DEV_NEW);
    if (code != 0) {
        puts("[!] Error creating new device");
    }
    return code;
}

long select_dev(unsigned long index){
    long code = ioctl(fd, DEV_SELECT, index);
    if(code != 0){
        puts("[!] Error selecting device");
    }
    return code;
}

long len_set(unsigned long arg){
    long code = ioctl(fd, LEN_SET, arg);
    if(code != 0){
        puts("[!] Error setting length");
    }
    return code;
}

void rst_leak(void){
    pthread_t t1;
    char buf[64];
    add_dev();
    select_dev(0);
    // Loop:
    // These two need to both be threaded
    read(fd, buf, 64);
    pthread_create(&t1, NULL, rst, NULL);
    // msgsnd spray
    // Check for leak
}

int main(){
    open_device();

    // Test dev_new
    long dev0 = add_dev();
    long dev1 = add_dev();
    long dev2 = add_dev();
    if (dev0 < 0 || dev1 < 0 || dev2< 0) {
        puts("[!] Error creating devices");
        close_device();
        return -1;
    }

    // Test dev_select
    if (select_dev(0) < 0 || select_dev(1) < 0 || select_dev(2) < 0) {
        puts("[!] Error selecting devices");
        close_device();
        return -1;
    }
    select_dev(500);

    // Test len_set
    if (len_set(64) < 0 || len_set(128) < 0 || len_set(256) < 0) {
        puts("[!] Error setting lengths");
        close_device();
        return -1;
    }
    select_dev(1);
    len_set(30); // 5368324604406717569
    select_dev(1);

    // Test tx_handle
    char buf[64] = "Yello, Ringbus!";
    ssize_t var0 = write(fd, buf, 0x50000);
    printf("[+] wrote %d bytes\n", var0);
    if (var0 < 0) {
        puts("[!] Error writing to device");
        close_device();
        return -1;
    }

    // Test rx_handle
    char read_buf[64];
    ssize_t var1 = read(fd, read_buf, 60);
    printf("[+] read %d bytes\n", var1);
    if (var1 < 0) {
        puts("[!] Error reading from device");
        close_device();
        return -1;
    }
    printf("[+] Read from device: %s\n", read_buf);

    // Test RST
    ioctl(fd, RST);
    char read_buf0[64];
    if (read(fd, read_buf0, 60) < 0) {
        puts("[!] Error reading from device");
        close_device();
        return -1;
    }
    printf("[+] Read from device: %s\n", read_buf0);
    return 0;
}