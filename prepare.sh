#!/bin/sh
mkdir -p sources
cd sources

# A
wget https://ftpmirror.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz
wget https://ftpmirror.gnu.org/gnu/automake/automake-1.17.tar.xz

# B
wget https://ftpmirror.gnu.org/gnu/bison/bison-3.8.2.tar.xz
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2

# C
wget https://curl.se/ca/cacert.pem
wget https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5.tar.gz
wget https://curl.se/download/curl-8.10.1.tar.xz

# D
wget https://ftpmirror.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz
wget https://github.com/dosfstools/dosfstools/releases/download/v4.2/dosfstools-4.2.tar.gz

# F
wget https://ftpmirror.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz
wget https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz

# G
wget https://git.sr.ht/~kennylevinsen/greetd/archive/0.10.3.tar.gz -O greetd-0.10.3.tar.gz

# K
wget https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-2.6.4.tar.xz

# L
wget https://libbsd.freedesktop.org/releases/libbsd-0.12.2.tar.xz
wget https://github.com/arachsys/libelf/archive/refs/tags/v0.192.1.tar.gz -O libelf-0.192.1.tar.gz
wget https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz
wget https://libbsd.freedesktop.org/releases/libmd-1.1.0.tar.xz
wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-3.8.0.tar.gz
wget https://github.com/limine-bootloader/limine/releases/download/v8.1.2/limine-8.1.2.tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.4.tar.xz
wget https://github.com/linux-pam/linux-pam/releases/download/v1.6.1/Linux-PAM-1.6.1.tar.xz
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.2/llvm-project-19.1.2.src.tar.xz

# M
wget https://ftpmirror.gnu.org/gnu/m4/m4-1.4.19.tar.xz
wget https://ftpmirror.gnu.org/gnu/make/make-4.4.1.tar.lz
wget https://github.com/mesonbuild/meson/releases/download/1.5.2/meson-1.5.2.tar.gz
wget https://musl.libc.org/releases/musl-1.2.5.tar.gz

# N
wget https://nano-editor.org/dist/v8/nano-8.2.tar.xz
wget https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/nasm-2.16.03.tar.xz
wget https://invisible-mirror.net/archives/ncurses/ncurses-6.5.tar.gz
wget https://github.com/ninja-build/ninja/archive/refs/tags/v1.12.1.tar.gz -O ninja-1.12.1.tar.gz

# O
wget https://github.com/OpenRC/openrc/archive/refs/tags/0.55.1.tar.gz -O openrc-0.55.1.tar.gz

# P
wget https://www.cpan.org/src/5.0/perl-5.40.0.tar.gz
wget https://distfiles.dereferenced.org/pkgconf/pkgconf-2.3.0.tar.xz
wget https://www.python.org/ftp/python/3.9.20/Python-3.9.20.tar.xz

# R
wget https://static.rust-lang.org/dist/rustc-1.82.0-src.tar.xz

# S
wget https://github.com/shadow-maint/shadow/releases/download/4.16.0/shadow-4.16.0.tar.xz

# Z
wget https://zlib.net/zlib-1.3.1.tar.xz
wget https://github.com/facebook/zstd/releases/download/v1.5.6/zstd-1.5.6.tar.zst
