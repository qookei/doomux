all: musl-src fbdoom-src linux-src limine-bin

.PHONY: clean

musl-src:
	wget https://musl.libc.org/releases/musl-1.2.3.tar.gz
	tar xzf musl-1.2.3.tar.gz
	mv musl-1.2.3 musl-src
	rm musl-1.2.3.tar.gz

fbdoom-src:
	git clone https://github.com/qookei/fbDOOM --depth=1 fbdoom-src
	sed -ie 's/-$$(CROSS_COMPILE)size/size/' fbdoom-src/fbdoom/Makefile

linux-src:
	wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.18.3.tar.xz
	tar xJf linux-5.18.3.tar.xz
	mv linux-5.18.3 linux-src
	cp linux-config linux-src/.config
	rm linux-5.18.3.tar.xz

limine-bin:
	git clone https://github.com/limine-bootloader/limine --branch=v3.0-branch-binary --depth=1 limine-bin
	$(MAKE) -C limine-bin

clean:
	-rm -rf musl-src
	-rm -rf fbdoom-src
	-rm -rf linux-src
	-rm -rf limine-bin
