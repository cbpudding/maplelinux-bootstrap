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
| `coreutils`       | Yes        | Yes          |
| `dash`            | Yes        | Yes          |
| `dhcpcd`          |
| `diffutils`       | Yes        | Yes          |
| `findutils`       | Yes        | Yes          |
| `flex`            | Yes        | Yes          |
| `fortune-mod`     | Yes        | Yes          |
| `gettext`         |
| `grep`            | Yes        | Yes          |
| `groff`           | Yes        | Yes          |
| `gzip`            | Yes        | Yes          |
| `initramfs-tools` | Yes        | Yes          |
| `iproute2`        |
| `kbd`             |
| `kmod`            |
| `less`            |
| `libarchive`      | Yes        | Yes          |
| `libcap2`         |
| `libelf`          | Yes        | Yes          |
| `libmnl`          |
| `libnftnl`        |
| `libressl`        | Yes        | Yes          |
| `libtool`         | Yes        | Yes          |
| `limine`          |
| `linux`           | Yes        | Yes          |
| `llvm`            | No         | No           |
| `m4`              | Yes        | Yes          |
| `make`            | Yes        | Yes          |
| `mawk`            | Yes        | Yes          |
| `muon`            | Yes        | Yes          |
| `musl`            | Yes        | Yes          |
| `nano`            |
| `nasm`            | Yes        | Yes          |
| `ncurses`         |
| `nftables`        |
| `openrc`          |
| `patch`           | Yes        | Yes          |
| `perl`            | Yes        | Yes          |
| `pkgconf`         | Yes        | Yes          |
| `sed`             | Yes        | Yes          |
| `shadow`          |
| `tar`             | Yes        | Yes          |
| `xlibre-xserver`  |
| `xz`              | Yes        | Yes          |
| `zlib`            | Yes        | Yes          |
| `zsh`             |
