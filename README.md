# doomux

Linux "distro" that runs Doom from the initramfs.

## Details

This project is a minimal "distro", consisting of static builds of [musl](https://musl.libc.org) (used at compile-time only),
[fbDOOM](https://github.com/maximevince/fbDOOM/), a small custom `init` executable, and the [Linux](https://kernel.org/) kernel.

It then packs these into an initramfs archive, and builds a hybrid ISO (EFI + old BIOS) image using [Limine](https://github.com/limine-bootloader/limine).

Versions used:

 - Linux 5.18.3,
 - musl 1.2.3,
 - fbDOOM master (my personal fork for the time being, until a fix PR is merged).

The kernel configuration is the default config with networking disabled and framebuffer and GPU support enabled.

The custom `init` binary does the following steps:

 - Mount `/dev` as `devtmpfs`,
 - Set up a virtual terminal (`/dev/tty1`) and switch to it,
 - Fork and exec `fbdoom`,
 - Wait for it to exit,
 - Trigger a system reboot.

## Building

In order to compile this project, you will need the following tools:

 - git,
 - wget,
 - tar, gzip, xz,
 - coreutils,
 - sed,
 - gcc, binutils,
 - bc,
 - cpio,
 - GNU Make (others untested),
 - xorriso.

To compile this project, put your `doom.wad` into this directory, then run:

```
$ make
```

If you want to specify the amount of cores to use when building packages, specify `PARALLELISM=n`.
By default this is set to the value given by `nproc`.

Note that you currently need to build it on an x86\_64 machine due to lack of cross-compiling support when compiling the kernel.
