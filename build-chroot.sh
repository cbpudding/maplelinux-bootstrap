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

# CMake Build
tar xf ../sources/cmake-*.tar*
cd cmake-*/
./bootstrap \
	--bindir=/bin \
	--datadir=/usr/share/cmake-4.0 \
	--parallel=$THREADS \
	--prefix=/usr \
	--system-bzip2 \
	--system-curl \
	--system-expat \
	--system-libarchive \
	--system-liblzma \
	--system-zlib
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

# libsodium Build
tar xf ../sources/libsodium-*.tar*
cd libsodium-*/
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
	--disable-static \
	--enable-cxx \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install
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

# rustc Build With mrustc Bootstrap (Thank you Mutabah for all of your help!)
tar xf ../sources/mrustc-*.tar*
cd mrustc-*/
# NOTE: Using types such as uint8_t without stdint.h is not portable. ~ahill
sed -i "1i #include <cstdint>" src/debug.cpp
sed -i "1i #include <cstdint>" src/ast/lifetime_ref.hpp
sed -i "1i #include <cstdint>" src/hir/generic_ref.hpp
sed -i "1i #include <cstdint>" src/hir/type_ref.hpp
sed -i "1i #include <cstdint>" tools/minicargo/build.cpp
# NOTE: LLVM loves yelling about unqualified std calls, so we'll just fix them
#       so we can properly troubleshoot why this doesn't work. ~ahill
sed -i -r "s/ move\(([a-z_]+)\)/ std::move\(\1\)/g" src/ast/ast.cpp
sed -i -r "s/ move\(([a-z_]+)\)/ std::move\(\1\)/g" src/ast/ast.hpp
sed -i -r "s/ move\(([a-z_]+)\)/ std::move\(\1\)/g" src/ast/expr.hpp
sed -i -r "s/ move\(([a-z_]+)\)/ std::move\(\1\)/g" src/macro_rules/macro_rules.hpp
sed -i -r "s/ move\(([a-z_]+)\)/ std::move\(\1\)/g" src/hir/expr.hpp
# NOTE: mrustc passes -fno-tree-sra to the GCC to work around a bug that is
#       present when it comes to linking, however clang has no idea what that
#       means. ~ahill
sed -i "s/-fno-tree-sra//" src/trans/codegen_c.cpp
# NOTE: mrustc converts Rust's asm! macro into inline Assembly in C, which seems
#       to work on GCC, but is broken on LLVM. Using the input constraint "0"
#       with the output constraint prefix "+" causes an error. Substituting "+"
#       with "=" seems to fix this problem. ~ahill
sed -i "s/m_of << \"+\";/m_of << \"=\";/" src/trans/codegen_c.cpp
sed -i "s/m_of << \(p\.input \? \"+\" : \"=\"\);/m_of << \"=\";/" src/trans/codegen_c.cpp
# NOTE: mrustc forces the system to link with libatomic because it's assuming
#       that libgcc exists, even though it doesn't in this case. compiler-rt
#       supplies the functionality we need, so this is not required. ~ahill
sed -i "/#define BACKEND_C_OPTS_GNU/s/, \"-l\", \"atomic\"//" src/trans/target.cpp
# NOTE: Rust's unwind crate attempts to link with libgcc_s, even on a musl-based
#       system. Enabling the "system-llvm-unwind" feature fixes this. ~ahill
echo "[add.'library/panic_unwind'.dependencies.unwind]" >> rustc-$RUST_VERSION-overrides.toml
echo "features = [\"system-llvm-libunwind\"]" >> rustc-$RUST_VERSION-overrides.toml
echo "[add.'library/std'.dependencies.unwind]" >> rustc-$RUST_VERSION-overrides.toml
echo "features = [\"system-llvm-libunwind\"]" >> rustc-$RUST_VERSION-overrides.toml
# FIXME: I have no idea how, but this script somehow invokes the now
#        non-existent version of clang++ from /maple/tools. Will need to look
#        into this further. CXX=clang++ exists to fix this temporarily. ~ahill
make -j $THREADS CXX=clang++
make -C tools/minicargo/ -j $THREADS CXX=clang++
tar xf ../../sources/rustc-*.tar*
# NOTE: minicargo.mk makes a *lot* of assumptions about the build environment
#       and most of them are incorrect in our case. As a result, we're stuck
#       with building rustc ourselves. ~ahill
cd rustc-*-src/
RUST_VERSION=$(pwd | sed -r "s/.*rustc-(.*)-src/\1/")
patch -p0 < ../rustc-$RUST_VERSION-src.patch
cd ..
# NOTE: mrustc defaults to 1.29, which means macros such as asm! do not function
#       correctly unless you manually define MRUSTC_TARGET_VER. ~ahill
export MRUSTC_TARGET_VER=$(echo $RUST_VERSION | sed "s/\.[^.]*$//")
# NOTE: We are creating a dummy crate to build the standard library since we're
#       doing a bit of trickery with dependencies. This should prevent conflicts
#       later on. ~ahill
MRUSTC_STDLIB=$(pwd)/rustc-$RUST_VERSION-src/mrustc-stdlib
mkdir -p $MRUSTC_STDLIB
echo "#![no_core]" > $MRUSTC_STDLIB/lib.rs
echo "[package]" > $MRUSTC_STDLIB/Cargo.toml
echo "name = \"mrustc_standard_library\"" >> $MRUSTC_STDLIB/Cargo.toml
echo "version = \"0.0.0\"" >> $MRUSTC_STDLIB/Cargo.toml
echo "[lib]" >> $MRUSTC_STDLIB/Cargo.toml
echo "path = \"lib.rs\"" >> $MRUSTC_STDLIB/Cargo.toml
echo "[dependencies]" >> $MRUSTC_STDLIB/Cargo.toml
echo "std = { path = \"../library/std\" }" >> $MRUSTC_STDLIB/Cargo.toml
echo "panic_unwind = { path = \"../library/panic_unwind\" }" >> $MRUSTC_STDLIB/Cargo.toml
echo "test = { path = \"../library/test\" }" >> $MRUSTC_STDLIB/Cargo.toml
./bin/minicargo \
	--vendor-dir rustc-$RUST_VERSION-src/vendor \
	--script-overrides script-overrides/stable-$RUST_VERSION-linux \
	--output-dir $(pwd)/build-std \
	--manifest-overrides rustc-$RUST_VERSION-overrides.toml \
	-j $THREADS \
	$MRUSTC_STDLIB
./bin/minicargo \
	--output-dir $(pwd)/build-std \
	--manifest-overrides rustc-$RUST_VERSION-overrides.toml \
	-j $THREADS \
	lib/libproc_macro
# NOTE: rustc and cargo will pull dependencies from build-std, but will still
#       attempt to build their own anyways. To prevent dependencies from being
#       clobbered, rustc and cargo get their own build directories. ~ahill
# NOTE: CFG_RELEASE is required to build rustc_attr. ~ahill
# NOTE: CFG_RELEASE_CHANNEL is required to build rustc_metadata. ~ahill
# NOTE: RUSTC_INSTALL_BINDIR is required to build rustc_interface. ~ahill
CFG_RELEASE=$RUST_VERSION \
CFG_RELEASE_CHANNEL=stable \
RUSTC_INSTALL_BINDIR=bin \
./bin/minicargo \
	--vendor-dir rustc-$RUST_VERSION-src/vendor \
	--output-dir $(pwd)/build-rustc \
	-L $(pwd)/build-std \
	--manifest-overrides rustc-$RUST_VERSION-overrides.toml \
	-j $THREADS \
	rustc-$RUST_VERSION-src/compiler/rustc
# NOTE: openssl-sys supports LibreSSL, but the version shipped with this version
#       of rustc only supports up to LibreSSL 3.8.0. We are manually updating
#       this crate so cargo can be built without downgrading LibreSSL. ~ahill
cd rustc-$RUST_VERSION-src/vendor
rm -rf openssl-sys*
tar xf ../../../../sources/openssl-sys-*.crate
cd ../..
./bin/minicargo \
	--vendor-dir rustc-$RUST_VERSION-src/vendor \
	--output-dir $(pwd)/build-cargo \
	-L $(pwd)/build-std \
	--manifest-overrides rustc-$RUST_VERSION-overrides.toml \
	-j $THREADS \
	rustc-$RUST_VERSION-src/src/tools/cargo
cp build-rustc/rustc_main /bin/rustc
cp build-cargo/cargo /bin/
cd ..

# Basic Configuration
echo "root::0:0::/:/bin/zsh" > /etc/passwd
echo "root:x:0:root" > /etc/group
echo "maple" > /etc/hostname
echo "NAME=Maple Linux" > /etc/os-release
echo "VERSION=2025" >> /etc/os-release
echo "ID=maple" >> /etc/os-release
echo "VERSION_ID=2025" >> /etc/os-release
echo "PRETTY_NAME=\"Maple Linux\"" >> /etc/os-release

# Finally, make the image bootable.
cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/
ln -s agetty /etc/init.d/agetty.tty1
cp /etc/conf.d/agetty /etc/conf.d/agetty.tty1
rc-update add agetty.tty1 default

cd ..
