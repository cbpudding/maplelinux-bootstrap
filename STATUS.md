This document tracks which packages can be built and packaged within the chroot.

Definitions:
- Can Build - The software can be both compiled via treetap on Maple Linux and run on Maple Linux
- Can Package - The software can be packaged by treetap under Maple Linux, while using none of the deprecated paths (/usr/bin, /usr/lib, /usr/libexec, /sbin, etc.) and without conflicting with another package

| Package       | Can Build? | Can Package? |
| ------------- | ---------- | ------------ |
| `autoconf`    | Yes        | Yes          |
| `automake`    | Yes        | Yes          |
| `bc`          |
| `byacc`       | Yes        | Yes          |
| `bzip2`       | Yes        | Yes          |
| `chrony`      |
| `cmake`       | Yes        | Yes          |
| `coreutils`   |
| `dhcpcd`      |
| `diffutils`   |
| `findutils`   |
| `flex`        | Yes        | Yes          |
| `gettext`     |
| `grep`        |
| `groff`       | Yes        | Yes          |
| `gzip`        |
| `iproute2`    |
| `kbd`         |
| `kmod`        |
| `less`        |
| `libarchive`  | Yes        | Yes          |
| `libcap2`     |
| `libelf`      | Yes        | Yes          |
| `libmnl`      |
| `libnftnl`    |
| `libressl`    | Yes        | Yes          |
| `libtool`     | Yes        | Yes          |
| `limine`      |
| `linux`       | No         | No           |
| `llvm`        | No         | No           |
| `m4`          | Yes        | Yes          |
| `make`        | Yes        | Yes          |
| `mawk`        |
| `muon`        | Yes        | Yes          |
| `musl`        | Yes        | Yes          |
| `nano`        |
| `nasm`        | Yes        | Yes          |
| `ncurses`     |
| `nftables`    |
| `openrc`      |
| `patch`       |
| `perl`        | Yes        | Yes          |
| `pkgconf`     | Yes        | Yes          |
| `sed`         |
| `shadow`      |
| `tar`         |
| `xz`          | Yes        | Yes          |
| `zlib`        | Yes        | Yes          |
| `zsh`         |