#!/bin/sh -e
CFLAGS="-O3 -march=skylake -pipe"
CXXFLAGS="$CFLAGS"
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

# bzip2 Build
tar xf ../sources/bzip2-*.tar*
cd bzip2-*/
make CC=clang
make install CC=clang PREFIX=/usr
cd ..

# cpio Build
tar xf ../sources/cpio-*.tar*
cd cpio-*/
./configure \
	--disable-nls \
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
ln -s pkgconf /bin/pkg-config
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
# NOTE: These symbolic links are for backwards compatibility. Specifically, for
#       fixing "make menuconfig" for the Linux kernel, since it looks for the
#       non-wide version of the library. ~ahill
ln -s libncursesw.so /lib/libncurses.so
ln -s libncurses++w.so /lib/libncurses++.so
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
# FIXME: Not sure why, but OpenRC doesn't take over /sbin/init like it should.
#        As a workaround, let's create the symlinks manually. ~ahill
ln -s openrc-init /sbin/init
ln -s openrc-shutdown /sbin/shutdown
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
tar xf ../sources/dosfstools-*.tar*
cd dosfstools-*/
./configure \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# bison Build
tar xf ../sources/bison-*.tar*
cd bison-*/
./configure \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# flex Build
tar xf ../sources/flex-*.tar*
cd flex-*/
./configure \
	--disable-nls \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# util-linux Build
tar xf ../sources/util-linux-*.tar*
cd util-linux-*
# lastlog2 depends on sqlite, which we don't have
# groups and chown are disabled as we don't have either at this point
# TODO: Do we care about bash completion when we're using zsh? ~ahill
./configure \
	--disable-liblastlog2 \
	--disable-makeinstall-chown \
	--disable-nls \
	--disable-pam-lastlog2 \
	--disable-static \
	--disable-use-tty-group \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc \
	--without-python \
	--without-systemd
make -j $THREADS
make -j $THREADS install
cd ..

# libinih Build
tar xf ../sources/libinih-*.tar*
cd inih-*/
muon setup \
	-Ddefault_library=shared \
	-Dprefix=/usr \
	build
muon samu -C build
muon -C build install
cd ..

# liburcu Build
tar xf ../sources/userspace-rcu-*.tar*
cd userspace-rcu-*/
./configure \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# xfsprogs Build
tar xf ../sources/xfsprogs-*.tar*
cd xfsprogs-*/
# Overriding system statx fixes an issue with musl compatability.
# Gentoo bugzilla for reference: https://bugs.gentoo.org/948468
CFLAGS=-DOVERRIDE_SYSTEM_STATX ./configure \
	--disable-static \
	--enable-gettext=no \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# bc Build
tar xf ../sources/bc-*.tar*
cd bc-*/
./configure \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
# NOTE: Documentation is not properly built here,
# MAKEINFO=true replaces the makeinfo executable (which we don't have)
# with `/usr/bin/true`. This is fine for the bootstrap, but should
# not be done when properly packaged. ~nmcdaniel
make MAKEINFO=true -j $THREADS
make MAKEINFO=true -j $THREADS install
cd ..

# libelf Build
tar xf ../sources/libelf-*.tar*
cd libelf-*/
# NOTE: This distribution of libelf has been extracted from elfutils and lacks a
#       proper configuration script. The best we can do is modify src/config.h
#       to do what we need. Zstd does *not* belong in binaries. ~ahill
sed -i "/#define USE_ZSTD.*/d" src/config.h
# NOTE: Similarly, we need to modify the Makefile to prevent it from linking
#       with zstd. At the very least, we can use the proper target to only build
#       the shared library. ~ahill
sed -i "s/-lzstd//" Makefile
make -j $THREADS libelf.so
make -j $THREADS install-headers
make -j $THREADS install-shared
cd ..

# Linux Build
tar xf ../sources/linux-*.tar*
cd linux-*/
# NOTE: LLVM=1 is required for the Linux kernel Makefile. Otherwise, things will
#       not build properly. ~ahill
LLVM=1 make -j $THREADS mrproper
cp /maple/linux.$(uname -m).config .config
LLVM=1 make -j $THREADS
LLVM=1 make -j $THREADS install
LLVM=1 make -j $THREADS modules_install
cd ..

# kmod Build
tar xf ../sources/kmod-*.tar*
cd kmod-*/
# FIXME: kmod's meson script attempts to invoke sh via the add_install_script
#        and confuses muon, so it starts searching for sh in the current
#        directory. As a workaround, we will tweak the invocation to point
#        directly to /bin/sh. ~ahill
sed -i "s/add_install_script('sh'/add_install_script('\/bin\/sh'/" meson.build
# NOTE: Might enable zstd later, but I want to make sure that the lack of
#       Facebook's software doesn't negatively impact the open source world.
#       ~ahill
# TODO: Is this the correct zsh directory to use? ~ahill
muon setup \
	-Dbashcompletiondir=no \
	-Dfishcompletiondir=no \
	-Dmanpages=false \
	-Dzstd=disabled \
	build
muon samu -C build
muon -C build install
cd ..

# tinyramfs Build
tar xf ../sources/tinyramfs-*.tar*
cd tinyramfs-*/
make install PREFIX=/usr
cd ..

# procps-ng Build
tar xf ../sources/procps-ng-*.tar*
cd procps-ng-*/
# FIXME: Why does this not detect the ncurses we just built? Do we need a
#        pkgconf file for this? Why didn't ncurses build one? ~ahill
./configure \
	--disable-nls \
	--disable-static \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc \
	--without-ncurses
make -j $THREADS
# FIXME: For some reason, a -e sneaks its way into local/capnames.h, which
#        causes a syntax error to occur. This is an incredibly jank patch and I
#        don't know what causes this yet. ~ahill
sed -i "s/^-e//" local/capnames.h
make -j $THREADS install
cd ..

# kbd Build
tar xf ../sources/kbd-*.tar*
cd kbd-*/
# NOTE: The tests require a software called autom4te to function. Ignoring the
#       additional dependency for now. ~ahill
./configure \
	--disable-nls \
	--disable-static \
	--disable-tests \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# net-tools Build
tar xf ../sources/net-tools-*.tar*
cd net-tools-*/
# NOTE: We are passing BASH=1 because the configure script apparently relies on
#       some bashism and zsh doesn't set this environment variable. Nobody tell
#       it that we aren't actually using bash. :) ~ahill
# NOTE: zsh doesn't support set -h, so we'll just patch that out. ~ahill
sed -i "s/set -f -h/set -f/" configure.sh
BASH=1 make config
make -j $THREADS
make -j $THREADS install
cd ..

# libmd Build
tar xf ../sources/libmd-*.tar*
cd libmd-*/
./configure \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libbsd Build
tar xf ../sources/libbsd-*.tar*
cd libbsd-*/
./configure \
	--disable-static \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Shadow Build
tar xf ../sources/shadow-*.tar*
cd shadow-*/
./configure \
	--disable-nls \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# nano Build
tar xf ../sources/nano-*.tar*
cd nano-*/
./configure \
	--disable-nls \
	--enable-utf8 \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/usr/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Basic Configuration
echo "root::0:0::/home/root:/bin/zsh" > /etc/passwd
echo "root:x:0:root" > /etc/group
echo "maple" > /etc/hostname
# FIXME: This is enough to get PAM authentication going, but this really should
#        be reviewed before it is put anywhere important. ~ahill
echo "#%PAM-1.0" > /etc/pam.d/system-auth
echo "auth     required pam_unix.so nullok" >> /etc/pam.d/system-auth
echo "account  required pam_unix.so" >> /etc/pam.d/system-auth
echo "password required pam_unix.so nullok shadow" >> /etc/pam.d/system-auth
echo "session  required pam_unix.so" >> /etc/pam.d/system-auth

# Finally, make the image bootable.
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/
ln -s agetty /etc/init.d/agetty.tty1
cp /etc/conf.d/agetty /etc/conf.d/agetty.tty1
rc-update add agetty.tty1 default

cd ..
