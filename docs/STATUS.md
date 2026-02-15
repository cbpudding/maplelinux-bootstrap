This document tracks which packages can be built and packaged within the chroot.

Definitions:
- Can Build - The software can be both compiled via treetap on Maple Linux and run on Maple Linux
- Can Package - The software can be packaged by treetap under Maple Linux, while using none of the deprecated paths (/usr/bin, /usr/lib, /usr/libexec, /sbin, etc.) and without conflicting with another package

| Package           | Can Build? | Can Package? |
| ----------------- | ---------- | ------------ |
| `autoconf`        | Yes        | Yes          |
| `automake`        | Yes        | Yes          |
| `bc`              | Yes        | Yes          |
| `byacc`           | Yes        | Yes          |
| `bzip2`           | Yes        | Yes          |
| `chrony`          |
| `cmake`           | Yes        | Yes          |
| `coreutils`       | Yes        | No           |
| `curl`            | Yes        | Yes          |
| `dash`            | Yes        | Yes          |
| `dhcpcd`          |
| `diffutils`       | Yes        | Yes          |
| `dosfstools`      |
| `efibootmgr`      |
| `expat`           | Yes        | Yes          |
| `findutils`       | Yes        | Yes          |
| `flatpak`         |
| `flex`            | Yes        | Yes          |
| `fortune-mod`     | Yes        | Yes          |
| `gettext`         | Yes        | Yes          |
| `git`             | Yes        | Yes          |
| `grep`            | Yes        | Yes          |
| `groff`           | Yes        | Yes          |
| `gzip`            | Yes        | Yes          |
| `iproute2`        |
| `kbd`             |
| `kmod`            | Yes        | No           |
| `less`            |
| `libarchive`      | Yes        | Yes          |
| `libcap2`         | Yes        | Yes          |
| `libelf`          | Yes        | Yes          |
| `libmnl`          |
| `libnftnl`        |
| `libressl`        | Yes        | Yes          |
| `libtool`         | Yes        | No           |
| `limine`          | Yes        | Yes          |
| `linux`           | Yes        | Yes          |
| `liquid-lua`      | Yes        | Yes          |
| `llvm`            | Yes        | No           |
| `lua`             | Yes        | Yes          |
| `lua-cjson`       | Yes        | Yes          |
| `lua-date`        | Yes        | Yes          |
| `luaposix`        | Yes        | Yes          |
| `m4`              | Yes        | Yes          |
| `make`            | Yes        | Yes          |
| `mawk`            | Yes        | Yes          |
| `mdevd`           | Yes        | Yes          |
| `muon`            | Yes        | Yes          |
| `musl`            | Yes        | Yes          |
| `nano`            | Yes        | Yes          |
| `nasm`            | Yes        | Yes          |
| `ncurses`         | Yes        | No           |
| `nftables`        |
| `nilfs-utils`     |
| `openrc`          | Yes        | Yes          |
| `parted`          |
| `patch`           | Yes        | Yes          |
| `perl`            | Yes        | Yes          |
| `pkgconf`         | Yes        | Yes          |
| `pipewire`        |
| `python`          | Yes        | Yes          |
| `sed`             | Yes        | Yes          |
| `skalibs`         | Yes        | Yes          |
| `tar`             | Yes        | Yes          |
| `tinyramfs`       | Yes        | Yes          |
| `tinytoml`        | Yes        | Yes          |
| `ubase`           | Yes        | No           |
| `xlibre-xserver`  |
| `xz`              | Yes        | Yes          |
| `zlib`            | Yes        | Yes          |
| `zsh`             | Yes        | Yes          |
