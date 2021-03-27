# tamago-build

Wrapping everything needed to build a go application to run on baremetal ARM devices, using [tamago](https://github.com/f-secure-foundry/tamago).

This Docker image takes the place of `go build` as you'd normally use it, running `tamago build` in an environment with the right cross compilation tools.

The files produced in the `build` directory should be added to a FAT formatted MicroSD card, which can be placed in your Raspberry Pi.

## Usage

```bash
$ cd /path/to/your/project
$ docker run -v $(pwd):/workdir jphastings/tamago-build
$ ls build
LICENCE.broadcom
bootcode.bin
config.txt
fixup.dat
start.elf
tamago-kernel.bin

# Or, if you want more control
$ docker run -v $(pwd):/workdir -v /mnt/sdcard:/workdir/build jphastings/tamago-build path-to-main-package name-of-kernel-file
$ ls /mnt/sdcard
LICENCE.broadcom
bootcode.bin
config.txt
fixup.dat
start.elf
name-of-kernel-file.bin
```