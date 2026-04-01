obj-m = ringbus.o

all:
	echo $(OBJECTS)
	make -C ../linux-5.17 M=$(PWD) modules
clean:
	make -C ../linux-5.17 M=$(PWD) clean
