#!/bin/sh -e
export CC=clang
export CFLAGS="-march=skylake -O2 -pipe"
export CXX=clang++
export CXXFLAGS="-march=skylake -O2 -pipe"
export LD=ld.lld
export RUSTFLAGS="-C target-feature=-crt-static"
cd /sources

tar xf m4-*.tar.*
cd m4-*
./configure --disable-nls --enable-c++ --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf flex-*.tar.*
cd flex-*
# NOTE: Target triple manually defined here because flex sucks at guessing. ~ahill
./configure --build=x86_64-pc-linux-musl --disable-nls --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf bison-*.tar.*
cd bison-*
./configure --disable-nls --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf zlib-*.tar.*
cd zlib-*
# FIXME: For some reason, zlib's configure script doesn't think LLVM is capable
#        of building a shared library. I have created a workaround to allow it
#        to compile normally, but I am hoping this gets fixed soon. ~ahill
./configure --prefix=/usr
ZLIB_VERSION=$(sed -n -e '/VERSION "/s/.*"\(.*\)".*/\1/p' < zlib.h)
ZLIB_VERSION_MAJOR=$(echo $ZLIB_VERSION | cut -d "." -f 1)
sed "/^SHAREDLIB=/s/.*/SHAREDLIB=libz.so/" -i Makefile
sed "/^SHAREDLIBV=/s/.*/SHAREDLIBV=libz.${ZLIB_VERSION}.so/" -i Makefile
sed "/^SHAREDLIBM=/s/.*/SHAREDLIBM=libz.${ZLIB_VERSION_MAJOR}.so/" -i Makefile
make -j $(nproc) -l $(($(nproc) + 1)) shared LDFLAGS="-shared"
make install
cd ..

tar xf libressl-*.tar.*
cd libressl-*
# FIXME: The version of the openssl-sys crate used in rustc only supports
#        LibreSSL versions up to 3.8.0. Once dependencies have been updated,
#        we should be able to use a newer version of LibreSSL. ~ahill
./configure --prefix=/usr --with-openssldir=/etc/ssl
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

# NOTE: Not sure if this is the proper way to install root certificates, 
mkdir -p /etc/ssl/cert
cp cacert.pem /etc/ssl/certs/
openssl certhash /etc/ssl/certs

tar xf perl-*.tar.*
cd perl-*
# NOTE: Some of the functions Perl expects to exist are locked behind
#       _GNU_SOURCE on musl! (Example: eaccess) ~ahill
./Configure -des -A ccflags=-D_GNU_SOURCE -Dprefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf curl-*.tar.*
cd curl-*
./configure --prefix=/usr --without-libpsl --with-openssl
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf cmake-*.tar.*
cd cmake-*
./bootstrap --generator="Unix Makefiles" --parallel=$(nproc) --prefix=/usr --system-curl
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf libelf-*.tar.*
cd libelf-*
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf ncurses-*.tar.*
cd ncurses-*
./configure --prefix=/usr \
    --with-cxx-shared \
    --with-shared \
    --without-ada \
    --without-tests
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf nano-*.tar.*
cd nano-*
./configure --disable-nls --enable-utf8 --enable-year2038 --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf diffutils-*.tar.*
cd diffutils-*
./configure --disable-nls --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf findutils-*.tar.*
cd findutils-*
./configure --disable-nls --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

cd linux-*
LLVM=1 make mrproper
cp /config/linux .config
LLVM=1 make -j $(nproc) -l $(($(nproc) + 1))
LLVM=1 make install
LLVM=1 make modules_install
cd ..

tar xf autoconf-*.tar.*
cd autoconf-*
./configure --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf automake-*.tar.*
cd automake-*
./bootstrap
./configure --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf nasm-*.tar.*
cd nasm-*
./autogen.sh
./configure --enable-year2038 --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf limine-*.tar.*
cd limine-*
./bootstrap
./configure --enable-uefi-x86-64 --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf libffi-*.tar.*
cd libffi-*
./configure --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf Python-*.tar.*
cd Python-*
# FIXME: Python dropped support for LibreSSL, yet --without-openssl doesn't
#        work, causing the build to fail because it "detects" OpenSSL. The
#        current solution is to run an older version of Python, but I would like
#        to be able to run a newer version at some point. ~ahill
#
# See also: https://peps.python.org/pep-0644/
CC=cc ./configure --enable-optimizations --prefix=/usr --with-lto
# FIXME: For some reason, compiling Python with CC=clang fails. This may be an
#        LLVM issue since it's complaining about a missing compiler-rt library,
#        but it's worth pointing out that everything besides Python works with
#        CC=clang. ~ahill
CC=cc make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf meson-*.tar.*
cd meson-*
python3 setup.py build
python3 setup.py install
cd ..

tar xf ninja-*.tar.*
cd ninja-*
./configure.py --bootstrap
cp ./ninja /usr/bin/
cd ..

tar xf pkgconf-*.tar.*
cd pkgconf-*
./configure --enable-year2038 --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
ln -s pkgconf /usr/bin/pkg-config
cd ..

tar xf Linux-PAM-*.tar.*
cd Linux-PAM-*
# TODO: Does this replace the --without-systemdunitdir from the old ./configure
#       script, or does this simply assume systemd exists? ~ahill
LDFLAGS="-fuse-ld=lld" meson setup --prefix=/usr build
# FIXME: Ugly hack to fix the version script for PAM. ld.lld will not link this
#        otherwise, even with --allow-shlib-undefined. With that said, this MUST
#        be fixed at some point, as symbols that should not be global are now
#        global. ~ahill
echo -e "{\n  global:\n    pam_sm_*;\n  local: *;\n};" > modules/modules.map
meson compile -C build
meson install -C build
cd ..

tar xf openrc-*.tar.*
cd openrc-*
meson setup build
meson compile -C build
# NOTE: Meson fails the install process if DESTDIR is not set! ~ahill
DESTDIR=/usr meson install -C build
cd ..

tar xf dosfstools-*.tar.*
cd dosfstools-*
./configure --enable-compat-symlinks --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf libmd-*.tar.*
cd libmd-*
./configure --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf libbsd-*.tar.*
cd libbsd-*
./configure --enable-year2038 --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf shadow-*.tar.*
cd shadow-*
./configure --disable-nls --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

tar xf kbd-*.tar.*
cd kbd-*
./configure --disable-nls --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install
cd ..

# NOTE: Temporary patch for DNS resolution. ~ahill
echo "nameserver 1.1.1.1" > /etc/resolv.conf

tar xf rustc-*.tar.*
cd rustc-*
./configure --build=x86_64-unknown-linux-musl \
    --enable-llvm-link-shared \
    --llvm-root=/usr \
    --musl-root-x86_64=/ \
    --prefix=/usr \
    --release-channel=stable
# FIXME: The version of rustc used to bootstrap our new compiler is linked with
#        libgcc_s, which does not exist on Maple Linux because we're using
#        LLVM's compiler-rt and libunwind in its place. Symlinking the library
#        is enough to get it running for now, but I have a feeling that we might
#        need a separate target triple for Maple Linux in the future. ~ahill
ln -s libunwind.so.1.0 /usr/lib/libgcc_s.so
ln -s libunwind.so.1.0 /usr/lib/libgcc_s.so.1
./x.py build --jobs $(nproc)
./x.py install
# FIXME: Rust attempts to link with libgcc_s later on, even though it isn't
#        valid for Maple Linux. Does Maple Linux need its own target triple?
#        x86_64-maple-linux-musl? ~ahill
#rm /usr/lib/libgcc_s.so*
cd ..

tar xf greetd-*.tar.*
cd greetd-*
# FIXME: Why does cargo refuse to use the root CA in LibreSSL? ~ahill
# FIXME: Why doesn't Rust look under /lib for linking? ~ahill
RUSTFLAGS="-C target-feature=-crt-static -L /lib" cargo \
    --config http.cainfo=\"/etc/ssl/certs/cacert.pem\" \
    build \
    --release
# ...
cd ..

tar xf lua-*.tar.*
cd lua-*
# NOTE: Lua hard codes the C compiler as gcc, meaning clang cannot be used
#       without modifying the Makefile. ~ahill
sed "s/^CC=.*/CC=clang/" -i src/Makefile
# NOTE: Lua builds a static library rather than a shared library. The Makefile
#       needs to be modified to address this. Not sure how stable this patch
#       will be over time, but this will insert a line right after the static
#       library has been indexed by ranlib. ~ahill
sed "/\$(RANLIB) \$@/a \\$(echo -en "\t")\$(CC) -shared -ldl -Wl,-soname,liblua.so -o liblua.so \$? -lm" -i src/Makefile
# NOTE: Lua attempts to find modules under /usr/local initially, even though it
#       doesn't exist. To remedy this, we will need to change LUA_ROOT under
#       src/luaconf.h. ~ahill
sed "s|#define LUA_ROOT.*|#define LUA_ROOT \"/usr/\"|" -i src/luaconf.h
make -C src -j $(nproc) -l $(($(nproc) + 1)) MYCFLAGS=-fPIC
make install INSTALL_TOP=/usr
cp src/liblua.so /usr/lib/liblua.so.5.4
cd ..

tar xf lzlib-*.tar.*
cd lzlib-*
cmake -DCMAKE_INSTALL_PREFIX=/usr CMakeLists.txt
make -j $(nproc) -l $(($(nproc) + 1))
# NOTE: make install does not place the files in a path the Lua interpreter will
#       search. Therefore, a manual install is required. ~ahill
install -Dm755 zlib.so /usr/lib/lua/5.4/zlib.so
install -Dm644 gzip.lua /usr/share/lua/5.4/gzip.lua
cd ..

tar xf scdoc-*.tar.*
cd scdoc-*
make -j $(nproc) -l $(($(nproc) + 1)) PREFIX=/usr
make install PREFIX=/usr
cd ..

tar xf apk-tools-*.tar.*
cd apk-tools-*
# NOTE: apk-tools hard codes the C compiler as gcc, meaning clang cannot be used
#       without modifying the Makefile. ~ahill
sed "s/^CC\s*:=.*/CC := \$(CROSS_COMPILE)clang/" -i Make.rules
# NOTE: The Makefile is unable to find Lua as-is, so we pass the LUA environment
#       variable to help it out. A patch by necessary to prevent it from
#       complaining about the absence of Lua 5.3. ~ahill
LUA=$(which lua) make -j $(nproc) -l $(($(nproc) + 1))
LUA=$(which lua) make install
cd ..