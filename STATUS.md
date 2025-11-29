This document tracks which packages can be built and packaged within the chroot.

Definitions:
- Can Build - The software can be both compiled via treetap on Maple Linux and run on Maple Linux
- Can Package - The software can be packaged by treetap under Maple Linux, while using none of the deprecated paths (/usr/bin, /usr/lib, /usr/libexec, /sbin, etc.) and without conflicting with another package

| Package      | Can Build? | Can Package? |
| ------------ | ---------- | ------------ |
| `autoconf`   | Yes        | Yes          |
| `automake`   | Yes        | Yes          |
| `bsdutils`   | Yes        | No           |
| `busybox`    | No         | No           |
| `byacc`      | Yes        | Yes          |
| `bzip2`      | Yes        | Yes          |
| `cmake`      | Yes        | No           |
| `editline`   | Yes        | Yes          |
| `flex`       | Yes        | Yes          |
| `libarchive` | Yes        | Yes          |
| `libressl`   | Yes        | Yes          |
| `libtool`    | Yes        | Yes          |
| `linux`      | No         | No           |
| `llvm`       | No         | No           |
| `m4`         | Yes        | Yes          |
| `make`       | Yes        | Yes          |
| `mold`       | Yes        | No           |
| `muon`       | Yes        | No           |
| `musl`       | Yes        | Yes          |
| `musl-fts`   | Yes        | Yes          |
| `ncurses`    | Yes        | No           |
| `perl`       | Yes        | Yes          |
| `pkgconf`    | Yes        | Yes          |
| `xz`         | Yes        | Yes          |
| `zlib`       | Yes        | Yes          |
