all:
	musl-gcc -O0 -static exploit.c -lpthread -o exploit -O0
	musl-gcc -O0 -static module_test.c -lpthread -o module_test
clean:
	rm exploit
	rm module_test
