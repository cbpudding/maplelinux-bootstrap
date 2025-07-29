#!/bin/sh -e
export CC=clang
export CXX=clang++
export CFLAGS="-O3 -march=skylake -pipe"
export CXXFLAGS="$CFLAGS"
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
# NOTE: No need to hide what we're using. ~ahill
ln -s openssl /bin/libressl
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

# Autoconf Build
tar xf ../sources/autoconf-*.tar*
cd autoconf-*/
./configure \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Automake Build
tar xf ../sources/automake-*.tar*
cd automake-*/
./configure \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libtool Build
tar xf ../sources/libtool-*.tar*
cd libtool-*/
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

# CMake Build
tar xf ../sources/cmake-*.tar*
cd cmake-*/
# TODO: CMake automatically installs scripts for emacs and vim, which we don't
#       need by default on Maple Linux. ~ahill
./bootstrap \
	--datadir=usr/share/cmake-4.0 \
	--docdir=usr/share/doc/cmake-4.0 \
	--parallel=$THREADS \
	--prefix=/ \
	--system-bzip2 \
	--system-curl \
	--system-expat \
	--system-libarchive \
	--system-liblzma \
	--system-zlib \
	--xdgdatadir=usr/share
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
# FIXME: This is enough to get PAM authentication going, but this really should
#        be reviewed before it is put anywhere important. ~ahill
mkdir -p /etc/pam.d
echo "#%PAM-1.0" > /etc/pam.d/system-auth
echo "auth     required pam_unix.so nullok" >> /etc/pam.d/system-auth
echo "account  required pam_unix.so" >> /etc/pam.d/system-auth
echo "password required pam_unix.so nullok shadow" >> /etc/pam.d/system-auth
echo "session  required pam_unix.so" >> /etc/pam.d/system-auth
echo "#%PAM-1.0" > /etc/pam.d/sshd
echo "auth     include system-auth" >> /etc/pam.d/sshd
echo "account  include system-auth" >> /etc/pam.d/sshd
echo "password include system-auth" >> /etc/pam.d/sshd
echo "session  include system-auth" >> /etc/pam.d/sshd
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
	--libexecdir=/lib \
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
	--libexecdir=/lib \
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
	--libexecdir=/lib \
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
	--libexecdir=/lib \
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
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# xfsprogs Build
tar xf ../sources/xfsprogs-*.tar*
cd xfsprogs-*/
# NOTE: libxfs redefined PAGE_SIZE from the standard C library (limits.h), so
#       we simply undefine it to get it to play nice with musl. ~ahill
sed -i "/#define PAGE_SIZE/d" libxfs/libxfs_priv.h
# NOTE: io/stat.c relies on the internal STATX__RESERVED definition to function.
#       musl doesn't have STATX__RESERVED, so we replace it with STATX_ALL since
#       that's what we're actually trying to achieve here. ~ahill
sed -i "s/~STATX__RESERVED/STATX_ALL/" io/stat.c
# Overriding system statx fixes an issue with musl compatability.
# Gentoo bugzilla for reference: https://bugs.gentoo.org/948468
CFLAGS=-DOVERRIDE_SYSTEM_STATX ./configure \
	--disable-static \
	--enable-gettext=no \
	--exec-prefix="" \
	--libexecdir=/lib \
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
	--libexecdir=/lib \
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
# NOTE: INCDIR is manually set here because it defaults to $(PREFIX)/include,
#       which becomes /include. Setting this to /usr/include fixes installation.
#       ~ahill
make -j $THREADS install-headers INCDIR=/usr/include
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
# NOTE: kmod's meson script attempts to invoke sh via the add_install_script and
#       confuses muon, so it starts searching for sh in the current directory.
#       As a workaround, we will tweak the invocation to point directly to
#       /bin/sh. ~ahill
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
	--libexecdir=/lib \
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
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# iproute2 Build
tar xf ../sources/iproute2-*.tar*
cd iproute2-*/
./configure --color auto --include_dir /usr/include --libdir /lib
# NOTE: It seems that iproute2's configuration script isn't compatible with
#       musl, which means we need to manually define HAVE_HANDLE_AT and
#       HAVE_SETNS to make it work properly. ~ahill
CFLAGS="$(CFLAGS) -DHAVE_HANDLE_AT -DHAVE_SETNS" make -j $THREADS CC=clang
make -j $THREADS install
cd ..

# libmd Build
tar xf ../sources/libmd-*.tar*
cd libmd-*/
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

# libbsd Build
tar xf ../sources/libbsd-*.tar*
cd libbsd-*/
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

# Shadow Build
tar xf ../sources/shadow-*.tar*
cd shadow-*/
./configure \
	--disable-nls \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
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
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# dhcpcd Build
tar xf ../sources/dhcpcd-*.tar*
cd dhcpcd-*/
./configure \
	--bindir=/bin \
	--libdir=/lib \
	--libexecdir=/lib \
	--prefix=/usr \
	--sbindir=/sbin \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
# NOTE: dhcpcd doesn't come with OpenRC support, so we need to add the entry
#       under /etc/init.d. First time actually writing an OpenRC service, so
#       expect strangeness to occur. ~ahill
echo "#!/sbin/openrc-run" > /etc/init.d/dhcpcd
echo "description=\"DHCP Client Daemon\"" >> /etc/init.d/dhcpcd
echo "command=\"/sbin/dhcpcd\"" >> /etc/init.d/dhcpcd
echo "command_args=\"-M\"" >> /etc/init.d/dhcpcd
echo "command_args_background=\"-b\"" >> /etc/init.d/dhcpcd
# NOTE: dhcpcd forks itself to the background, meaning a custom PID file will
#       not function as intended. Instead, use dhcpcd's own /run/dhcpcd/pid to
#       tell OpenRC where to find the service. ~ahill
echo "pidfile=\"/run/dhcpcd/pid\"" >> /etc/init.d/dhcpcd
chmod +x /etc/init.d/dhcpcd
rc-update add dhcpcd default
cd ..

# Chrony Build
tar xf ../sources/chrony-*.tar*
cd chrony-*/
./configure --exec-prefix=/ --prefix=/usr
make -j $THREADS
make -j $THREADS install
echo "cmdport 0" > /etc/chrony.conf
echo "pool pool.ntp.org iburst maxsources 3" >> /etc/chrony.conf
echo "#!/sbin/openrc-run" > /etc/init.d/chronyd
echo "description=\"Network Time Protocol Daemon\"" >> /etc/init.d/chronyd
echo "command=\"/sbin/chronyd\"" >> /etc/init.d/chronyd
# I guess we should just point OpenRC to the existing PID file unless the daemon
# doesn't make its own? ~ahill
echo "pidfile=\"/run/chrony/chronyd.pid\"" >> /etc/init.d/chronyd
chmod +x /etc/init.d/chronyd
rc-update add chronyd default
cd ..

# libmnl Build
tar xf ../sources/libmnl-*.tar*
cd libmnl-*/
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

# libnftnl Build
tar xf ../sources/libnftnl-*.tar*
cd libnftnl-*/
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

# libgmp Build
tar xf ../sources/gmp-*.tar*
cd gmp-*/
./configure \
	--bindir=/bin \
	--disable-static \
	--enable-cxx \
	--exec-prefix=/ \
	--libdir=/lib \
	--libexecdir=/lib \
	--prefix=/usr \
	--sbindir=/bin \
	--sysconfdir=/etc \
	--localstatedir=/var
make -O -j $THREADS
make -O -j $THREADS install
# FIXME: For some reason, gmp.h keeps showing up under /include. This is a
#        temporary workaround while I figure out what's going on. ~ahill
cp /include/* /usr/include/
rm -rf /include
cd ..

# nftables Build
tar xf ../sources/nftables-*.tar*
cd nftables-*/
# NOTE: Building without the CLI will require fewer dependencies.
#       (No libreadline, editline, and linenoise) ~ahill
./configure \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc \
	--without-cli
make -j $THREADS
make -j $THREADS install
cd ..

# patch Build
tar xf ../sources/patch-*.tar*
cd patch-*/
./configure \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# X.Org Utility Macros Build
tar xf ../sources/macros-util-macros-*.tar*
cd macros-util-macros-*/
./autogen.sh \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
# NOTE: make claims that there's nothing to do for the build... so we just
#       don't. ~ahill
make -j $THREADS install
cd ..

# libxtrans Build
tar xf ../sources/libxtrans-xtrans-*.tar*
cd libxtrans-xtrans-*/
./autogen.sh \
	--disable-docs \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
# NOTE: Once again, make does nothing. ~ahill
make -j $THREADS install
cd ..

# xorgproto Build
tar xf ../sources/xorgproto-xorgproto-*.tar*
cd xorgproto-xorgproto-*/
muon setup -Dprefix=/usr build
muon -C build install
cd ..

# libffi Build
tar xf ../sources/libffi-*.tar*
cd libffi-*/
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

# Python Build
# NOTE: I don't like how we're using an old version of Python, but it'll have to
#       do because it's the last version that supports LibreSSL. ~ahill
# See also: https://peps.python.org/pep-0644/
# NOTE: Python will not build _ctypes if libffi is not present. ~ahill
tar xf ../sources/Python-*.tar*
cd Python-*/
# FIXME: Python copies its headers to /include rather than /usr/include. ~ahill
# TODO: Review Python's configuration to make sure the paths are configured
#       correctly. Setting exec-prefix to / instead of an empty string fixed
#       the need for PYTHONHOME. ~ahill
./configure \
	--enable-optimizations \
	--exec-prefix=/ \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# xcbproto Build
tar xf ../sources/xcbproto-xcb-proto-*.tar*
cd xcbproto-xcb-proto-*/
./autogen.sh \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libXau Build
tar xf ../sources/libxau-libXau-*.tar*
cd libxau-libXau-*/
muon setup -Dprefix=/usr build
muon samu -C build
muon -C build install
cd ..

# libxcb Build
tar xf ../sources/libxcb-libxcb-*.tar*
cd libxcb-libxcb-*/
./autogen.sh \
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

# libX11 Build
tar xf ../sources/libx11-*.tar*
cd libx11-*/
# NOTE: Disabling xsltproc and xmlto is the only way I've found to disable
#       documentation. ~ahill
# NOTE: For some reason, autoconf attempts to pipe C code into the preprocessor
#       without passing -, so setting ac_cv_path_RAWCPP fixes that. ~ahill
ac_cv_path_RAWCPP="clang -E -" ./autogen.sh \
	--disable-static \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc \
	--without-xsltproc \
	--without-xmlto
make -j $THREADS
make -j $THREADS install
cd ..

# Pixman Build
tar xf ../sources/pixman-*.tar*
cd pixman-*/
# NOTE: Pixman builds as a static library by default, but appears to be missing
#       the MMX, SSE2, and SSE3 symbols upon installation. Telling it to build a
#       shared library fixes the problem, but the question is why this happens
#       in the first place... ~ahill
muon setup \
	-Ddefault_library=shared \
	-Dprefix=/usr \
	build
muon samu -C build
muon -C build install
cd ..

# libxkbfile Build
tar xf ../sources/libxkbfile-libxkbfile-*.tar*
cd libxkbfile-libxkbfile-*/
muon setup \
	-Ddefault_library=shared \
	-Dprefix=/usr \
	build
muon samu -C build
muon -C build install
cd ..

# FreeType Build
tar xf ../sources/freetype-*.tar*
cd freetype-*/
muon setup -Dprefix=/usr build
muon samu -C build
muon -C build install
cd ..

# font-util Build
tar xf ../sources/util-font-util-*.tar*
cd util-font-util-*/
./autogen.sh \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libfontenc Build
tar xf ../sources/libfontenc-libfontenc-*.tar*
cd libfontenc-libfontenc-*/
./autogen.sh \
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

# libXfont2 Build
tar xf ../sources/libxfont-libXfont2-*.tar*
cd libxfont-libXfont2-*/
./autogen.sh \
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

# libxcvt Build
tar xf ../sources/libxcvt-libxcvt-*.tar*
cd libxcvt-libxcvt-*/
muon setup -Dprefix=/usr build
muon samu -C build
muon -C build install
cd ..

# skalibs Build
# TODO: Should skalibs/mdevd/libudev-zero be moved to earlier in the script to
#       benefit other software? ~ahill
tar xf ../sources/skalibs-*.tar*
cd skalibs-*/
# NOTE: We prefer a static library over a shared library in this instance since
#       this is only used by mdevd. ~ahill
./configure \
	--disable-shared \
	--enable-pkgconfig \
	--includedir=/usr/include \
	--prefix=/
make -j $THREADS
make -j $THREADS install
cd ..

# mdevd Build
tar xf ../sources/mdevd-*.tar*
cd mdevd-*/
./configure \
	--disable-static \
	--enable-pkgconfig \
	--enable-shared \
	--includedir=/usr/include \
	--libexecdir=/lib \
	--prefix=/
make -j $THREADS
make -j $THREADS install
echo "#!/sbin/openrc-run" > /etc/init.d/mdevd
echo "description=\"Mini Device Mapper Daemon\"" >> /etc/init.d/mdevd
echo "command=\"/bin/mdevd\"" >> /etc/init.d/mdevd
echo "command_args=\"-O4\"" >> /etc/init.d/mdevd
echo "command_background=\"yes\"" >> /etc/init.d/mdevd
echo "pidfile=\"/run/mdevd.pid\"" >> /etc/init.d/mdevd
chmod +x /etc/init.d/mdevd
cd ..

# libudev-zero Build
tar xf ../sources/libudev-zero-*.tar*
cd libudev-zero-*/
# FIXME: libudev-zero copies headers to /include instead of /usr/include. ~ahill
make -j $THREADS
make -j $THREADS install PREFIX=/
cd ..

# libXdmcp Build
tar xf ../sources/libxdmcp-libXdmcp-*.tar*
cd libxdmcp-libXdmcp-*/
./autogen.sh \
	--disable-docs \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Flit Core Build
# NOTE: Required to build Packaging
tar xf ../sources/flit_core-*.tar*
cd flit_core-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Packaging Build
# NOTE: Required by Build and MarkupSafe
# NOTE: Build isolation starts having problems here because pip isolates itself
#       from its dependencies. ~ahill
# See also: https://pip.pypa.io/en/latest/reference/build-system/pyproject-toml/#disabling-build-isolation
tar xf ../sources/packaging-*.tar*
cd packaging-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Tomli Build
# NOTE: Required by Build
tar xf ../sources/tomli-*.tar*
cd tomli-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Pyproject Hooks Build
# NOTE: Required by Build
tar xf ../sources/pyproject_hooks-*.tar*
cd pyproject_hooks-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Wheel Build
# NOTE: Required by ImportLib Metadata
tar xf ../sources/wheel-*.tar*
cd wheel-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# SetupTools Build
# NOTE: While not an explicit dependency of ImportLib Metadata, it produces an
#       UNKNOWN egg if this isn't installed. ~ahill
tar xf ../sources/setuptools-*.tar*
cd setuptools-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Typing Extensions Build
# NOTE: Required by SetupTools SCM
tar xf ../sources/typing_extensions-*.tar*
cd typing_extensions-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Zipp Build
# NOTE: Required by ImportLib Metadata
tar xf ../sources/zipp-*.tar*
cd zipp-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
# NOTE: For some reason, Zipp, which is a dependency of ImportLib Metadata,
#       requires SetupTools SCM to properly version the module. This doesn't
#       sound too bad until you realize that ImportLib Metadata is a dependency
#       of SetupTools SCM, which we can't install because Zipp is the dependency
#       of that! In other words, we have encountered a circular dependency for
#       this version of Python. The simple solution is to simply upgrade Python,
#       but you wouldn't be reading this if that was possible. Instead, we will
#       extract the version number from the name of the tarball, and inject that
#       into the egg info for Zipp after installing. ~ahill
ZIPP_VERSION=$(pwd | cut -d"-" -f2)
ZIPP_PACKAGE=/lib/python3.9/site-packages/zipp-$ZIPP_VERSION.dist-info
mv /lib/python3.9/site-packages/zipp-0.0.0.dist-info $ZIPP_PACKAGE
sed -i "s/Version: 0.0.0/Version: $ZIPP_VERSION/" $ZIPP_PACKAGE/METADATA
sed -i "s/zipp-0.0.0/zipp-$ZIPP_VERSION/" $ZIPP_PACKAGE/RECORD
ZIPP_METADATA_HASH=$(cat $ZIPP_PACKAGE/METADATA | libressl sha256 -binary | base64 -w 0)
sed -i "s|METADATA,sha256=.*,|METADATA,sha256=$ZIPP_METADATA_HASH,|" $ZIPP_PACKAGE/RECORD
cd ..

# ImportLib Metadata Build
# NOTE: Required by Build
tar xf ../sources/importlib_metadata-*.tar*
cd importlib_metadata-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
# NOTE: Applying the same hack from Zipp to ImportLib Metadata because both rely
#       on SetupTools SCM, which we can't install due to a circular dependency.
IMPORTLIB_METADATA_VERSION=$(pwd | cut -d"-" -f2)
IMPORTLIB_METADATA_PACKAGE=/lib/python3.9/site-packages/importlib_metadata-$IMPORTLIB_METADATA_VERSION.dist-info
mv /lib/python3.9/site-packages/importlib_metadata-0.0.0.dist-info $IMPORTLIB_METADATA_PACKAGE
sed -i "s/Version: 0.0.0/Version: $IMPORTLIB_METADATA_VERSION/" $IMPORTLIB_METADATA_PACKAGE/METADATA
sed -i "s/importlib_metadata-0.0.0/importlib_metadata-$IMPORTLIB_METADATA_VERSION/" $IMPORTLIB_METADATA_PACKAGE/RECORD
# I refuse to call this IMPORTLIB_METADATA_METADATA_HASH. ~ahill
IMPORTLIB_METADATA_HASH=$(cat $IMPORTLIB_METADATA_PACKAGE/METADATA | libressl sha256 -binary | base64 -w 0)
sed -i "s|METADATA,sha256=.*,|METADATA,sha256=$IMPORTLIB_METADATA_HASH,|" $IMPORTLIB_METADATA_PACKAGE/RECORD
cd ..

# SetupTools SCM Build
# NOTE: Technically required by Zipp and ImportLib Metadata, but not needed at
#       this point. This is just here for future-proofing. ~ahill
tar xf ../sources/setuptools_scm-*.tar*
cd setuptools_scm-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# "Build" Build
# NOTE: The above line makes me question my sanity. ~ahill
# NOTE: Required by MarkupSafe
tar xf ../sources/build-*.tar*
cd build-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# MarkupSafe Build
# NOTE: Required by Mako
tar xf ../sources/markupsafe-*.tar*
cd markupsafe-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Babel Build
# NOTE: Required by Mako
tar xf ../sources/babel-*.tar*
cd babel-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Click Build
# NOTE: Required by Lingua
tar xf ../sources/click-*.tar*
cd click-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Polib Build
# NOTE: Required by Lingua
tar xf ../sources/polib-*.tar*
cd polib-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Lingua Build
# NOTE: Required by Mako
tar xf ../sources/lingua-*.tar*
cd lingua-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# Mako Build
# NOTE: This is a Python library that is required to build Mesa. ~ahill
tar xf ../sources/mako-*.tar*
cd mako-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# PyYAML Build
# NOTE: Another Python library for Mesa. ~ahill
tar xf ../sources/pyyaml-*.tar*
cd pyyaml-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# libpciaccess Build
tar xf ../sources/libpciaccess-libpciaccess-*.tar*
cd libpciaccess-libpciaccess-*/
muon setup \
	-Dprefix=/usr \
	-Dzlib=enabled \
	build
muon samu -C build
muon -C build install
cd ..

# libdrm Build
tar xf ../sources/libdrm-*.tar*
cd libdrm-*/
muon setup \
	-Dintel=enabled \
	-Dprefix=/usr \
	-Dudev=true \
	build
muon samu -C build
muon -C build install
cd ..

# LLVM pkgconf hack
# NOTE: Not proud of this, but I guess LLVM doesn't support pkg-config at all.
#       This is here to allow muon to detect LLVM when building Mesa. ~ahill
# See also: https://github.com/llvm/llvm-project/issues/9777#issuecomment-980893725
echo "Name: LLVM" > /lib/pkgconfig/llvm.pc
echo "Description: Low-Level Virtual Machine" >> /lib/pkgconfig/llvm.pc
echo "Version: $(llvm-config --version)" >> /lib/pkgconfig/llvm.pc
echo "URL: https://www.llvm.org/" >> /lib/pkgconfig/llvm.pc
echo "Requires:" >> /lib/pkgconfig/llvm.pc
echo "Conflicts:" >> /lib/pkgconfig/llvm.pc
echo "Libs: -L$(llvm-config --libdir) -lLLVM" >> /lib/pkgconfig/llvm.pc
echo "Cflags: -I$(llvm-config --includedir)" >> /lib/pkgconfig/llvm.pc

# LLVMConfig.cmake hack
# FIXME: I'm not sure why, but LLVMConfig.cmake *assumes* that the LLVM install
#        prefix is exactly three directories up from itself. This means that it
#        believes the install prefix is /lib rather than /, which results in it
#        failing to locate the other CMake files. This hack forcefully sets the
#        LLVM install prefix to the proper location. ~ahill
sed -i "/get_filename_component(LLVM_INSTALL_PREFIX \"\${CMAKE_CURRENT_LIST_FILE/a set(LLVM_INSTALL_PREFIX \"/\")" /lib/cmake/llvm/LLVMConfig.cmake
sed -i "/get_filename_component(LLVM_INSTALL_PREFIX/d" /lib/cmake/llvm/LLVMConfig.cmake

# SPIR-V Tools Build
tar xf ../sources/spirv-tools-*.tar*
cd SPIRV-Tools-*/
# NOTE: In an effort to avoid Python and access to the Internet for the duration
#       of the build, "python3 utils/git-sync-deps" has been replaced with the
#       SPIR-V headers we used earlier. ~ahill
cd external
tar xf ../../../sources/SPIRV-Headers-vulkan-sdk-1.4.309.0.tar*
mv SPIRV-Headers-*/ spirv-headers
cd ..
cmake -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_LIBDIR=/lib \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DSPIRV_SKIP_TESTS=ON
# FIXME: Having "stable" releases that rely on very specific commits to function
#        is terrible practice. If updates are going to be that unstable, make
#        the headers, tools, and translator all part of a single source tree!
#        ~ahill
# See also: https://github.com/KhronosGroup/SPIRV-Headers/issues/515
#           https://github.com/KhronosGroup/SPIRV-LLVM-Translator/issues/3048
#           https://bugs.gentoo.org/951062
make -C build -j $THREADS
make -C build -j $THREADS install
cd ..

# SPIR-V LLVM Translator Build
tar xf ../sources/spirv-llvm-translator-*.tar*
cd SPIRV-LLVM-Translator-*/
# NOTE: CMAKE_INSTALL_LIBDIR explicitly defined due to /usr/lib64 usage that
#       breaks pkgconf. ~ahill
# NOTE: SPIR-V headers need to be imported from the source. ~ahill
tar xf ../../sources/SPIRV-Headers-vulkan-sdk-1.4.321.0.tar*
mv SPIRV-Headers-*/ SPIRV-Headers/
cmake -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_LIBDIR=/lib \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DLLVM_DIR=/lib/cmake/llvm \
	-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=$(pwd)/SPIRV-Headers
make -C build -j $THREADS
make -C build -j $THREADS install
cd ..

# Glslang Build
tar xf ../sources/glslang-*.tar*
cd glslang-*/
cmake -B build \
	-DALLOW_EXTERNAL_SPIRV_TOOLS=true \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_LIBDIR=/lib \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DGLSLANG_TESTS=false
make -C build -j $THREADS
make -C build -j $THREADS install
cd ..

# libXext Build
tar xf ../sources/libxext-libXext-*.tar*
cd libxext-libXext-*/
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc \
	--without-fop \
	--without-xmlto \
	--without-xsltproc
make -j $THREADS
make -j $THREADS install
cd ..

# libXfixes Build
tar xf ../sources/libxfixes-libXfixes-*.tar*
cd libxfixes-libXfixes-*/
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libxshmfence Build
tar xf ../sources/libxshmfence-libxshmfence-*.tar*
cd libxshmfence-libxshmfence-*/
./autogen.sh \
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

# libXxf86vm Build
tar xf ../sources/libxxf86vm-libXxf86vm-*.tar*
cd libxxf86vm-libXxf86vm-*/
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libXrender Build
tar xf ../sources/libxrender-libXrender-*.tar*
cd libxrender-libXrender-*/
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libXrandr Build
tar xf ../sources/libxrandr-libXrandr-*.tar*
cd libxrandr-libXrandr-*/
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Mesa Build
tar xf ../sources/mesa-mesa-*.tar*
cd mesa-mesa-*/
# NOTE: Mesa apparently contains Rust code now. To avoid the dependency, we make
#       sure gallium-rusticl, with_nouveau_vk, and etnaviv are all disabled.
#       gallium-rusticl is a feature, with_nouveau_vk is part of nouveau itself,
#       and etnaviv is part of the tools included with Mesa. ~ahill
# NOTE: Despite not building Rust, rust_std and build.rust_std are included in
#       the project definition. We'll patch these out with sed before
#       proceeding. ~ahill
sed -i "/rust_std=.*/d" meson.build
# NOTE: muon doesn't support configtool, so we patch meson.build to use the
#       llvm-config command instead. RTTI detection is necessary for ABI-level
#       compatibility with LLVM. ~ahill
sed -i "s/_llvm_rtti = \[.*/_llvm_rtti = ['ON', 'YES'].contains(run_command('llvm-config', '--has-rtti').stdout().strip())/" meson.build
sed -i "s/llvm_libdir = dep_llvm.*/llvm_libdir = run_command('llvm-config', '--libdir').stdout().strip()/" meson.build
LLVM_HASRTTI=$(llvm-config --has-rtti)
if [ "$LLVM_HASRTTI" = "YES" ] || [ "$LLVM_HASRTTI" = "ON" ]; then
	LLVM_HASRTTI=true
else
	LLVM_HASRTTI=false
fi
# NOTE: egl-native-platform and platforms are manually defined so we don't build
#       Wayland support, which reduces the number of dependencies even further.
#       ~ahill
# TODO: Have Mesa use the system-built Lua library rather than pulling one in
#       from the web to use with Mesa and Mesa alone. ~ahill
# NOTE: intel-ui is temporary disabled due to a lack of libepoxy, which we can't
#       build due to a muon bug. ~ahill
# See also: https://todo.sr.ht/~lattis/muon/141
# NOTE: Dropping intel tools for now because it conflicting definitions with
#       musl. ~ahill
# NOTE: Mesa and musl do not seem to get along, so I have patched the shim out
#       from the 64-bit syscall variants since they're just aliased in musl,
#       preventing a re-definition error. ~ahill
sed -i "1i #define off64_t off_t" src/drm-shim/drm_shim.h
patch -p0 < /maple/patches/mesa-drm-maple.patch
muon setup \
	-Dcpp_rtti=$LLVM_HASRTTI \
	-Degl-native-platform=x11 \
	-Dgallium-rusticl=false \
	-Dllvm=true \
	-Dplatforms=x11 \
	-Dprefix=/usr \
	-Dtools=drm-shim,dlclose-skip,freedreno,glsl,lima,nir,nouveau,asahi,imagination \
	-Dvulkan-drivers=amd,intel,intel_hasvk,swrast \
	build
muon samu -C build
muon -C build install
cd ..

# XCB Util Build
tar xf ../sources/libxcb-util-xcb-util-*.tar*
cd libxcb-util-xcb-util-*/
# NOTE: For some reason, configure.ac attempts to use LIBTOOL without invoking
#       LT_INIT anywhere. The following line adds the line to the file so it can
#       build properly. ~ahill
sed -i "/AM_INIT_AUTOMAKE/a LT_INIT" configure.ac
# NOTE: Makefile.am can't be built because pkgconfig_DATA and xcbinclude_HEADERS
#       are used without having pkgconfigdir or xcbincludedir defined. This
#       patches the files. ~ahill
sed -i "/pkgconfig_DATA/i pkgconfigdir=/lib/pkgconfig" Makefile.am
sed -i "/xcbinclude_HEADERS/i xcbincludedir=/usr/include/xcb" src/Makefile.am
# NOTE: XCB Util requires XCB Util M4 to build, which is software without a
#       release tag and is only ever referred to by the commit hash. It fails to
#       configure if this isn't present. ~ahill
tar xf ../../sources/xcb-util-m4-*.tar*
rm -rf m4/
mv xcb-util-m4-*/ m4
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# XCB Util WM Build
tar xf ../sources/libxcb-wm-xcb-util-wm-*.tar*
cd libxcb-wm-xcb-util-wm-*/
# NOTE: XCB Util WM requires XCB Util M4 to build. We went over this with XCB
#       Util already, and thankfully, it uses the same commit hash. ~ahill
tar xf ../../sources/xcb-util-m4-*.tar*
rm -rf m4/
mv xcb-util-m4-*/ m4
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Xlibre Build
tar xf ../sources/xlibre-xserver-*.tar*
cd xserver-xlibre-xserver-*/
# NOTE: Once again, muon doesn't like a simple "sh" so we need to replace it
#       with /bin/sh to make it happy. ~ahill
sed -i "s|'sh'|'/bin/sh'|" hw/xfree86/meson.build
muon setup \
	-Dglamor=false \
	-Dprefix=/usr \
	build
# FIXME: For some reason, "muon setup" defines HAVE_ARC4RANDOM_BUF in
#        build/dix-config.h, despite musl not having the function available. To
#        fix this, we simply undef the symbol in the configuration file that was
#        just generated. ~ahill
sed -i "s/#define HAVE_ARC4RANDOM_BUF.*/#undef HAVE_ARC4RANDOM_BUF/" build/dix-config.h
muon samu -C build
muon -C build install
cd ..

# XFree86 VESA Driver Build
tar xf ../sources/xlibre-xf86-video-vesa-*.tar*
cd xf86-video-vesa-xlibre-xf86-video-vesa-*/
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Dropbear Build
tar xf ../sources/dropbear-*.tar*
cd dropbear-*/
./configure \
	--enable-pam \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
# NOTE: Creating an ssh alias here for convenience's sake. ~ahill
ln -s dbclient /bin/ssh
# NOTE: Dropbear doesn't come with OpenRC support, but that's simple enough to
#       fix. ~ahill
echo "#!/bin/openrc-run" > /etc/init.d/dropbear
echo "command=\"/bin/dropbear\"" >> /etc/init.d/dropbear
echo "command_args=\"-R\"" >> /etc/init.d/dropbear
echo "pidfile=\"/run/dropbear.pid\"" >> /etc/init.d/dropbear
chmod +x /etc/init.d/dropbear
# NOTE: Dropbear won't make keys if the directory doesn't exist. ~ahill
mkdir -p /etc/dropbear
cd ..

# mtdev Build
tar xf ../sources/mtdev-*.tar*
cd mtdev-*/
# TODO: Should this be static or shared? As far as I know, libinput is the only
#       thing that will need this dependency, but I'll withhold judgement until
#       I have a fully functional copy of Maple Linux. ~ahill
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

# evdev Build
tar xf ../sources/libevdev-*.tar*
cd libevdev-*/
# TODO: Once again, unsure whether this is used for anything but libinput at
#       this point. ~ahill
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# libinput Build
tar xf ../sources/libinput-*.tar*
cd libinput-*/
# NOTE: We're not building libwacom here so we don't have to bootstrap another
#       dependency. Once we have a self-sufficient version, this should probably
#       be re-enabled. ~ahill
muon setup \
	-Ddebug-gui=false \
	-Dlibwacom=false \
	-Dprefix=/usr \
	build
muon samu -C build
muon -C build install
cd ..

# XFree86 libinput Driver Build
tar xf ../sources/xlibre-xf86-input-libinput-*.tar*
cd xf86-input-libinput-*/
./autogen.sh \
	--disable-static \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Pytest Runner Build
tar xf ../sources/pytest-runner-*.tar*
cd pytest-runner-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# StrEnum Build
tar xf ../sources/StrEnum-*.tar*
cd StrEnum-*/
python3 -m pip install --no-build-isolation --root-user-action=ignore .
cd ..

# XKeyboardConfig Build
tar xf ../sources/xkeyboard-config-*.tar*
cd xkeyboard-config-*/
# TODO: The configuration portion requires Python to function, but unfortunately
#       introspection via pymod in Muon appears to rely on the path Python is
#       located under. Muon is likely finding /bin/python3 before it finds
#       /usr/bin/python3, which makes it think / is the prefix and fails to
#       locate the other Python directories. Modifying meson.build to point
#       straight to /usr/bin/python3 does the trick. ~ahill
sed -i "s|'python3|'/usr/bin/python3|" rules/meson.build
muon setup -Dprefix=/usr build
muon samu -C build
muon -C build install
cd ..

# xkbcomp Build
tar xf ../sources/xkbcomp-*.tar*
cd xkbcomp-*/
./autogen.sh \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
cd ..

# Basic Configuration
echo "root:x:0:0::/:/bin/zsh" > /etc/passwd
echo "root:x:0:root" > /etc/group
echo "root::20295::::::" > /etc/shadow
echo "/bin/sh" > /etc/shells
echo "/bin/zsh" >> /etc/shells
echo "maple" > /etc/hostname
echo "NAME=Maple Linux" > /etc/os-release
echo "VERSION=2025" >> /etc/os-release
echo "ID=maple" >> /etc/os-release
echo "VERSION_ID=2025" >> /etc/os-release
echo "PRETTY_NAME=\"Maple Linux\"" >> /etc/os-release
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

# Finally, make the image bootable.
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/
ln -s agetty /etc/init.d/agetty.tty1
cp /etc/conf.d/agetty /etc/conf.d/agetty.tty1
rc-update add agetty.tty1 default
# NOTE: Dropbear currently included for troubleshooting purposes. Should be
#       disabled for desktop systems. ~ahill
rc-update add dropbear default
rc-update add mdevd sysinit

cd ..
