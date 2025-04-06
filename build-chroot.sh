#!/bin/sh -e
THREADS=$(nproc)

mkdir -p build
cd build

# Zlib Build
tar xf ../sources/zlib-*.tar*
cd zlib-*/
# The configure script refuses to build a shared library because the linker
# script attempts to modify symbols that do not exist. Passing CFLAGS fixes the
# issue. ~ahill
CFLAGS="-Wl,--undefined-version" ./configure --prefix=/usr --shared
make -j $THREADS
make -j $THREADS install
cd ..

# LibreSSL Build
tar xf ../sources/libressl-*.tar*
cd libressl-*/
./configure \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libarchive Build
tar xf ../sources/libarchive-*.tar*
cd libarchive-*/
./configure \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# pkgconf Build
tar xf ../sources/pkgconf-*.tar*
cd pkgconf-*/
./configure \
	--disable-static \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
# NOTE: pkg-config is a requirement for muon since it doesn't link with pkgconf
#       during the bootstrap process.
ln -s pkgconf /bin/pkg-config
cd ..

# ncurses Build
tar xf ../sources/ncurses-*.tar*
cd ncurses-*/
./configure \
	--enable-ext-colors \
	--enable-widec \
	--exec-prefix="" \
	--libexecdir=/lib \
	--prefix=/usr \
	--with-shared \
	--with-cxx-binding \
	--with-cxx-shared \
	--without-ada \
	--without-manpages \
	--without-normal
make -j $THREADS
make -j $THREADS install
cd ..

# zsh Build
tar xf ../sources/zsh-*.tar*
cd zsh-*/
# NOTE: The target triple is explicitly passed to the configure script since it
#       believes the host system is based on glibc rather than musl. ~ahill
# NOTE: Most of Autoconf's tests do not specify a type for the main function,
#       causing clang to get angry. Passing -Wno-implicit-int fixes this. ~ahill
CFLAGS="-Wno-implicit-int" ./configure \
	--build=$(clang -dumpmachine) \
	--disable-locale \
	--enable-libc-musl \
	--enable-multibyte \
	--exec-prefix="" \
	--libexecdir=/lib \
	--prefix=/usr
make -j $THREADS
make -j $THREADS install
# NOTE: While zsh isn't 100% compatible with bash, it can still be used as a
#       reliable replacement in this case. ~ahill
ln -s zsh /bin/bash
cd ..

# libcap Build
tar xf ../sources/libcap-*.tar*
cd libcap-*/
# NOTE: For some reason, libcap hardcodes gcc as the compiler, so we need to
#       modify the Makefile to set it to clang. ~ahill
sed -i "s/CC :=.*/CC := clang/" Make.Rules
# NOTE: When trying to figure out where to put libraries, libcap attempts to
#       invoke ldd, which is not a valid command at this point. As a result, it
#       dumps the libraries into the root of the filesystem. ~ahill
sed -i "s/^lib=.*/lib=\/lib/" Make.Rules
# FIXME: libcap's pkgconf file claims to be installed under / rather than /lib. ~ahill
make -j $THREADS
make -j $THREADS install
cd ..

# OpenRC Build
#tar xf ../sources/openrc-*.tar*
#cd openrc-*/
#muon setup build
# TODO: Build is currently unsuccessful due to an inability to find libcap.
#       Discussing with #muon via Libera Chat. ~ahill

# nasm Build
tar xf ../sources/nasm-*.tar*
cd nasm-*/
./configure \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Limine Build
tar xf ../sources/limine-*.tar*
cd limine-*/
./configure \
	--enable-uefi-x86-64 \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

cd ..