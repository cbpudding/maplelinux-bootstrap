#!/bin/sh -e
THREADS=$(nproc)

# Zlib Build
tar xf ../zlib-*.tar*
cd zlib-*/
# The configure script refuses to build a shared library because the linker
# script attempts to modify symbols that do not exist. Passing CFLAGS fixes the
# issue. ~ahill
CFLAGS="-Wl,--undefined-version" ./configure --prefix=/usr --shared
make -j $THREADS
make -j $THREADS install
cd ..

# LibreSSL Build
tar xf ../libressl-*.tar*
cd libressl-*/
./configure \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/bin \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libarchive Build
tar xf ../libarchive-*.tar*
cd libarchive-*/
./configure \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/bin \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# pkgconf Build
tar xf ../pkgconf-*.tar*
cd pkgconf-*/
./configure \
	--disable-static \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/bin \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..