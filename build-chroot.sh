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

# libexpat Build
tar xf ../sources/expat-*.tar*
cd expat-*/
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
cd ..

# Perl Build
tar xf ../sources/perl-*.tar*
cd perl-*/
# NOTE: d_eaccess is manually undefined because of undeclared function use in
#       pp_sys.c ~ahill
./Configure -des \
	-Dprefix=/usr \
	-Dvendorprefix=/usr \
	-Duseshrplib \
	-Dusethreads \
	-Ud_eaccess
make -j $THREADS
make -j $THREADS install
cd ..

# cURL Build
tar xf ../sources/curl-*.tar*
cd curl-*/
./configure \
	--disable-ntlm \
	--disable-static \
	--enable-ipv6 \
	--enable-optimize \
	--enable-unix-sockets \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-ca-bundle=/etc/ssl/cert.pem \
	--with-ca-path=/etc/ssl/certs \
	--with-openssl \
	--with-zlib \
	--with-zsh-functions-dir \
	--without-libpsl
make -j $THREADS
make -j $THREADS install
cd ..

# Samurai Build
tar xf ../sources/samurai-*.tar*
cd samurai-*/
# NOTE: Unfortunately, there is no way to change the prefix without modifying
#       the Makefile. ~ahill
sed -i "s/^PREFIX=.*/PREFIX=\/usr/" Makefile
# NOTE: CC is manually defined due to the use of the c99 command. ~ahill
make -j $THREADS CC=clang
make -j $THREADS install
cd ..

# git Build
tar xf ../sources/git-*.tar*
cd git-*/
# NOTE: musl doesn't support REG_STARTEND, which git requires. Therefore, we
#       pass NO_REGEX=NeedsStartEnd so git will use its own implementation
#       instead. ~ahill
# NOTE: Passing NO_TCLTK disables the GUI and passing NO_GETTEXT disables locale
#       generation... unless it attempts to build the GUI, where it will attempt
#       to generate the locales anyways. ~ahill
make -j $THREADS all prefix=/usr NO_GETTEXT=YesUnfortunately NO_REGEX=NeedsStartEnd NO_TCLTK=YesPlease
make -j $THREADS install prefix=/usr NO_GETTEXT=YesUnfortunately NO_REGEX=NeedsStartEnd NO_TCLTK=YesPlease
cd ..

# muon Build
tar xf ../sources/muon-*.tar*
cd muon-*/
# NOTE: Muon's bootstrap script requires the "c99" command, which doesn't exist
#       on Maple Linux. Using sed to rewrite the command to clang -std=c99
#       instead. ~ahill
sed -i "s/c99/clang -std=c99/" bootstrap.sh
CFLAGS="-DBOOTSTRAP_NO_SAMU" ./bootstrap.sh build
./build/muon-bootstrap setup -Dprefix=/usr build
samu -C build
./build/muon-bootstrap -C build install
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
# NOTE: Review additional prefix settings for correctness
make CC=clang prefix=/usr lib=lib -j $THREADS
make prefix=/usr lib=lib -j $THREADS install
cd ..

# Linux PAM Build
tar xf ../sources/Linux-PAM-*.tar*
cd Linux-PAM-*/
# FIXME: Muon has an issue with system dependencies that lack a pkgconfig file.
#        We change the method we use for resolving dependencies as a workaround.
#        ~ahill
sed -i "s/^libdl = dependency('dl')/libdl = dependency('dl', method : 'system')/" meson.build
# NOTE: The version script associated with PAM attempts to modify symbols that
#       don't exist, so it fails to compile on LLVM. Passing
#       -Wl,--undefined-version fixes the problem. ~ahill
LDFLAGS="-Wl,--undefined-version" muon setup build
# NOTE: We are using Samurai directly because we don't have the ability to reach
#       the Internet to download meson's tests in our current state. ~ahill
samu -C build
muon -C build install
cd ..

# OpenRC Build
tar xf ../sources/openrc-*.tar*
cd openrc-*/
muon setup build
samu -C build
# NOTE: build/src/shared/version is never generated, which causes an error with
#       the install process. Deleting the last line as a workaround. ~ahill
sed -i "/^install.*\/src\/shared\/version\".*/d" ./tools/meson_final.sh
# NOTE: One of the shell scripts OpenRC uses to install requires a DESTDIR, so
#       we simply say the root is / in this case. ~ahill
DESTDIR=/ muon -C build install
cd ..

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

# dosfstools Build
tar xf ../sources/dosfstools-*.tar.gz
cd dosfstools-*/
./configure
	--prefix=/usr \
	--libexecdir=/usr/lib \
	--sbindir=/usr/bin \
	--mandir=/usr/share/man \
make -j $THREADS
make -j $THREADS install
cd ..

# bison Build
tar xf ../sources/bison-*
cd bison-*/
./configure \
	--prefix=/usr \
	--libexecdir=/usr/lib \
	--sbindir=/usr/bin

make -j $THREADS
make -j $THREADS install
cd ..

# flex Build
tar xf ../sources/flex-*
cd flex-*/
./configure \
	--prefix=/usr \
	--libexecdir=/usr/lib \
	--sbindir=/usr/bin
make -j $THREADS
make -j $THREADS install
cd ..

# util-linux Build
tar xf ../sources/util-linux-*
cd util-linux-*
# lastlog2 depends on sqlite, which we don't have
# groups and chown are disabled as we don't have either at this point
./configure \
	--prefix=/usr \
	--libexecdir=/usr/lib \
	--sbindir=/usr/bin \
	--without-python \
	--disable-liblastlog2 \
	--disable-pam-lastlog2 \
	--disable-use-tty-group \
	--disable-makeinstall-chown \
	--without-systemd
make -j $THREADS
make -j $THREADS install
cd ..

cd ..
