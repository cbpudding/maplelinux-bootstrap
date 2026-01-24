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
| `initramfs-tools` | Yes        | Yes          |
| `iproute2`        |
| `kbd`             |
| `kmod`            | Yes        | Yes          |
| `less`            |
| `libarchive`      | Yes        | Yes          |
| `libcap2`         | Yes        | Yes          |
| `libelf`          | Yes        | Yes          |
| `libffi`          | Yes        | Yes          |
| `libmnl`          |
| `libnftnl`        |
| `libressl`        | Yes        | Yes          |
| `libtool`         | Yes        | Yes          |
| `libyaml`         | Yes        | Yes          |
| `limine`          | Yes        | Yes          |
| `linux`           | Yes        | Yes          |
| `liquid`          | Yes        | Yes          |
| `llvm`            | Yes        | No           |
| `m4`              | Yes        | Yes          |
| `make`            | Yes        | Yes          |
| `mawk`            | Yes        | Yes          |
| `muon`            | Yes        | Yes          |
| `musl`            | Yes        | Yes          |
| `nano`            | Yes        | Yes          |
| `nasm`            | Yes        | Yes          |
| `ncurses`         | Yes        | Yes          |
| `nftables`        |
| `nilfs-utils`     |
| `openrc`          | Yes        | Yes          |
| `patch`           | Yes        | Yes          |
| `perl`            | Yes        | Yes          |
| `pkgconf`         | Yes        | Yes          |
| `pipewire`        |
| `python`          | Yes        | Yes          |
| `ruby`            | Yes        | Yes          |
| `sed`             | Yes        | Yes          |
| `shadow`          |
| `tar`             | Yes        | Yes          |
| `xlibre-xserver`  |
| `xz`              | Yes        | Yes          |
| `zlib`            | Yes        | Yes          |
| `zsh`             | Yes        | Yes          |
