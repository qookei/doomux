
.PHONY: all sources clean
all: doomux.iso

PARALLELISM ?= $(shell nproc)

# Rules to fetch sources

sources:
	$(MAKE) -C src

doom.wad:
	$(error Copy doom.wad into this directory and try again)

# Rules to build packages

ROOT = "$(shell realpath musl-root)"

musl-root: sources
	-mkdir musl-root
	-mkdir musl-build
	cd musl-build; \
	../src/musl-src/configure --prefix="$(ROOT)/usr" --enable-static --disable-shared
	$(MAKE) -C musl-build -j$(PARALLELISM) install

linux: sources musl-root
	$(MAKE) -j$(PARALLELISM) -C src/linux-src bzImage
	cp src/linux-src/arch/x86_64/boot/bzImage linux
	$(MAKE) -j$(PARALLELISM) -C src/linux-src headers_install INSTALL_HDR_PATH="$(ROOT)/usr"

fbdoom: sources linux musl-root
	PATH="$(ROOT)/usr/bin/:${PATH}" $(MAKE) -C src/fbdoom-src/fbdoom/ NOSDL=1 -j$(PARALLELISM) CROSS_COMPILE=musl- CFLAGS=-static
	cp src/fbdoom-src/fbdoom/fbdoom .

init: init.c musl-root linux
	PATH="$(ROOT)/usr/bin/:${PATH}" musl-gcc init.c -o init -static -O2

# Rules to build initramfs and image

initramfs.cpio: init fbdoom doom.wad
	echo $^ | tr ' ' '\n' | cpio -H newc -ov > initramfs.cpio

doomux.iso: sources linux initramfs.cpio limine.cfg
	-mkdir iso-root

	cp linux initramfs.cpio limine.cfg src/limine-bin/limine.sys src/limine-bin/limine-cd.bin src/limine-bin/limine-cd-efi.bin iso-root/

	xorriso -as mkisofs -b limine-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot limine-cd-efi.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso-root -o doomux.iso

	src/limine-bin/limine-deploy doomux.iso

	-rm -rf iso-root

# Misc

clean:
	-rm -rf musl-root
	-rm -rf musl-build
	-rm -rf iso-root
	-rm -rf linux
	-rm -rf fbdoom
	-rm -rf init
	-rm -rf initramfs.cpio
	-rm doomux.iso
	$(MAKE) -C src clean
