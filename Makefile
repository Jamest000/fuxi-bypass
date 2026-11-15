obj-m += fuxi_unblank_bypass.o

all:
	make -C $(KDIR) M=$(PWD) ARCH=arm64 LLVM=1 LLVM_IAS=1 modules

clean:
	make -C $(KDIR) M=$(PWD) ARCH=arm64 LLVM=1 LLVM_IAS=1 clean
