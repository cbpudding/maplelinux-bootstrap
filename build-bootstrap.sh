#!/bin/sh -e
export MAPLE=$(pwd)/maple

export BUILD=$(clang -dumpmachine)
export CC=clang
export CFLAGS="-O3 -march=skylake -pipe"
export CXX=clang++
export CXXFLAGS="$CFLAGS"
export HOST=x86_64-maple-linux-musl
export LD=ld.lld
export THREADS=$(nproc)

# A simplified FHS variant with symlinks for backwards compatibility ~ahill
# TODO: Where does /usr/com fit into all of this (shared state directory)? ~ahill
mkdir -p $MAPLE/bin
mkdir -p $MAPLE/boot
mkdir -p $MAPLE/boot/EFI/BOOT/
mkdir -p $MAPLE/dev
mkdir -p $MAPLE/etc
mkdir -p $MAPLE/home
mkdir -p $MAPLE/lib
# TODO: Does it make sense to have this long-term? Anything that depends on
#       libc++ fails to link without it, but this should be fixed via a
#       configuration change in LLVM. ~ahill
ln -sf . $MAPLE/lib/$HOST
mkdir -p $MAPLE/maple/patches
mkdir -p $MAPLE/maple/sources
mkdir -p $MAPLE/proc
mkdir -p $MAPLE/run
ln -sf bin $MAPLE/sbin
mkdir -p $MAPLE/sys
mkdir -p $MAPLE/tmp
mkdir -p $MAPLE/usr
ln -sf ../bin $MAPLE/usr/bin
mkdir -p $MAPLE/usr/include
ln -sf . $MAPLE/usr/include/$HOST
ln -sf ../lib $MAPLE/usr/lib
ln -sf ../lib $MAPLE/usr/libexec
ln -sf ../bin $MAPLE/usr/sbin
mkdir -p $MAPLE/usr/share
mkdir -p $MAPLE/var
mkdir -p $MAPLE/var/cache
mkdir -p $MAPLE/var/lib
ln -sf ../run/lock $MAPLE/var/lock
mkdir -p $MAPLE/var/log
ln -sf ../run $MAPLE/var/run
mkdir -p $MAPLE/var/spool
mkdir -p $MAPLE/var/tmp

mkdir -p build
cd build

# LLVM Build
tar xf ../sources/llvm-project-*.tar*
cd llvm-project-*/
# TODO: Python is a required part of LLVM, but we can't include the latest
#       version due to conflicts with LibreSSL. Maybe we can piggyback off of
#       Python 3.9 for a while, but that's not a sustainable solution long-term.
#       ~ahill
# See also: https://peps.python.org/pep-0644/
cmake -B stage1 -G Ninja -S llvm \
	-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	-DCLANG_DEFAULT_RTLIB=compiler-rt \
	-DCLANG_DEFAULT_UNWINDLIB=libunwind \
	-DCLANG_VENDOR=Maple \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
	-DCMAKE_INSTALL_PREFIX=$MAPLE/maple/tools \
	-DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
	-DLIBCXX_CXX_ABI=libcxxabi \
	-DLIBCXX_HAS_MUSL_LIBC=ON \
	-DLIBCXX_USE_COMPILER_RT=ON \
	-DLIBCXXABI_USE_COMPILER_RT=ON \
	-DLIBCXXABI_USE_LLVM_UNWINDER=ON \
	-DLIBUNWIND_ENABLE_ASSERTIONS=OFF \
	-DLIBUNWIND_USE_COMPILER_RT=ON \
	-DLLVM_BUILD_LLVM_DYLIB=ON \
	-DLLVM_DEFAULT_TARGET_TRIPLE=$HOST \
	-DLLVM_ENABLE_LIBCXX=ON \
	-DLLVM_ENABLE_PROJECTS="clang;lld;llvm" \
	-DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx" \
	-DLLVM_HOST_TRIPLE=$BUILD \
	-DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
	-DLLVM_INSTALL_UTILS=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DLLVM_TARGETS_TO_BUILD=X86
cmake --build stage1
cmake --install stage1
cd ..

export CC="$MAPLE/maple/tools/bin/clang"
export CFLAGS="-O3 -march=skylake -pipe --sysroot=$MAPLE"
export CXX="$MAPLE/maple/tools/bin/clang++"
export CXXFLAGS="$CFLAGS"
export LD=$MAPLE/maple/tools/bin/ld.lld
export PATH="$MAPLE/maple/tools/bin:$PATH"
export RUSTFLAGS="-C target-feature=-crt-static"

# Linux Headers
tar xf ../sources/linux-*.tar*
cd linux-*/
LLVM=1 make -j $THREADS mrproper
# TODO: Why do we need rsync to install the Linux headers? ~ahill
LLVM=1 make -j $THREADS headers_install INSTALL_HDR_PATH=$MAPLE/usr
cd ..

# musl Build
# FIXME: CVE-2025-26519
tar xf ../sources/musl-*.tar*
cd musl-*/
./configure --includedir=/usr/include --prefix=""
make -O -j $THREADS
make -O -j $THREADS install DESTDIR=$MAPLE
# NOTE: musl provides static libraries for POSIX libraries such as libm, but
#       fails to provide shared versions which will breaks builds later on.
#       Granted, they are useless since libc.so contains all the functionality
#       we need, but it is needed for compatibility. As of April 5th, 2025, zsh
#       is known to be misconfigured as a result of missing libraries. ~ahill
for lib in $(grep "EMPTY_LIB_NAMES =" Makefile | sed "s/EMPTY_LIB_NAMES = //"); do
	ln -sf libc.so $MAPLE/lib/lib$lib.so
done
# NOTE: musl has some witchcraft associated with it that allows it to function
#       as an implementation of ldd. Honestly, the idea of a library with as an
#       entry point is something I have never thought of before, but I'm
#       interested in exploring the possibilities. ~ahill
ln -sf /lib/ld-musl-x86_64.so.1 $MAPLE/bin/ldd
cd ..

# dash Build
tar xf ../sources/dash-*.tar*
cd dash-*/
./configure \
	--datarootdir=/usr/share \
	--exec-prefix="" \
	--includedir=/usr/include \
	--libexecdir=/lib \
	--prefix="" \
	--sharedstatedir=/usr/com
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
ln -sf dash $MAPLE/bin/sh
cd ..

# m4 Build
tar xf ../sources/m4-*.tar*
cd m4-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--enable-c++ \
	--includedir=/usr/include \
	--libexecdir=/lib \
	--prefix="" \
	--sharedstatedir=/usr/com
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# Coreutils Build
tar xf ../sources/coreutils-*.tar*
cd coreutils-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--enable-install-program=hostname \
	--includedir=/usr/include \
	--libexecdir=/lib \
	--prefix="" \
	--sharedstatedir=/usr/com
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# Diffutils Build
tar xf ../sources/diffutils-*.tar*
cd diffutils-*/
./configure \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# Findutils Build
tar xf ../sources/findutils-*.tar*
cd findutils-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# Grep Build
tar xf ../sources/grep-*.tar*
cd grep-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# Gzip Build
tar xf ../sources/gzip-*.tar*
cd gzip-*/
./configure \
	--datarootdir=/usr/share \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREAD
make -j $THREAD install DESTDIR=$MAPLE
cd ..

# Make Build
tar xf ../sources/make-*.tar*
cd make-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREAD
make -j $THREAD install DESTDIR=$MAPLE
cd ..

# Sed Build
tar xf ../sources/sed-*.tar*
cd sed-*/
./configure \
	--datarootdir=/usr/share \
	--disable-i18n \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREAD
make -j $THREAD install DESTDIR=$MAPLE
cd ..

# Tar Build
tar xf ../sources/tar-*.tar*
cd tar-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREAD
make -j $THREAD install DESTDIR=$MAPLE
cd ..

# Xz Build
tar xf ../sources/xz-*.tar*
cd xz-*/
./configure \
	--datarootdir=/usr/share \
	--disable-doc \
	--disable-nls \
	--disable-static \
	--enable-year2038 \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREAD
make -j $THREAD install DESTDIR=$MAPLE
cd ..

# Gawk Build
tar xf ../sources/gawk-*.tar*
cd gawk-*/
./configure \
	--disable-mpfr \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/lib \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# LLVM Build (Stage 2)
# NOTE: We are removing the sysroot option from CFLAGS and CXXFLAGS to prevent a
#       potential conflict with CMake. Adapted from Nick's contribution. ~ahill
export CFLAGS=$(echo $CFLAGS | sed "s/--sysroot=\S*//")
export CXXFLAGS=$(echo $CXXFLAGS | sed "s/--sysroot=\S*//")
cd llvm-project-*/
TOOLCHAIN_FILE=$HOST-maple-clang.cmake
# NOTE: First time doing this. Did I do it right? ~ahill
echo "set(CMAKE_SYSTEM_NAME Linux)" > $TOOLCHAIN_FILE
echo "set(CMAKE_SYSROOT $MAPLE)" >> $TOOLCHAIN_FILE
echo "set(CMAKE_C_COMPILER_TARGET $HOST)" >> $TOOLCHAIN_FILE
echo "set(CMAKE_CXX_COMPILER_TARGET $HOST)" >> $TOOLCHAIN_FILE
echo "set(CMAKE_C_FLAGS_INIT \"$CFLAGS\")" >> $TOOLCHAIN_FILE
echo "set(CMAKE_CXX_FLAGS_INIT \"$CXXFLAGS\")" >> $TOOLCHAIN_FILE
echo "set(CMAKE_LINKER_TYPE LLD)" >> $TOOLCHAIN_FILE
echo "set(CMAKE_C_COMPILER \"$CC\")" >> $TOOLCHAIN_FILE
echo "set(CMAKE_CXX_COMPILER \"$CXX\")" >> $TOOLCHAIN_FILE
echo "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)" >> $TOOLCHAIN_FILE
echo "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" >> $TOOLCHAIN_FILE
echo "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" >> $TOOLCHAIN_FILE
echo "set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)" >> $TOOLCHAIN_FILE
# TODO: Is it possible to prevent CMake from building static libraries? ~ahill
# NOTE: compiler-rt fails to build on musl because execinfo.h is missing.
#       Disabling COMPILER_RT_BUILD_GWP_ASAN works. ~ahill
# See also: https://github.com/llvm/llvm-project/issues/60687
cmake -B stage2 -G Ninja -S llvm \
	-DCMAKE_BUILD_TYPE=Release \
	-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	-DCLANG_DEFAULT_RTLIB=compiler-rt \
	-DCLANG_DEFAULT_UNWINDLIB=libunwind \
	-DCMAKE_BUILD_PARALLEL_LEVEL=$THREADS \
	-DCMAKE_INSTALL_LIBDIR=$MAPLE/lib \
	-DCMAKE_INSTALL_PREFIX=$MAPLE/usr \
	-DCMAKE_INSTALL_RPATH=/lib \
	-DCMAKE_TOOLCHAIN_FILE=$(pwd)/$TOOLCHAIN_FILE \
	-DCLANG_VENDOR=Maple \
	-DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
	-DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
	-DLIBCXX_CXX_ABI=libcxxabi \
	-DLIBCXX_HAS_MUSL_LIBC=ON \
	-DLIBCXX_USE_COMPILER_RT=ON \
	-DLIBCXXABI_USE_COMPILER_RT=ON \
	-DLIBCXXABI_USE_LLVM_UNWINDER=ON \
	-DLIBUNWIND_ENABLE_ASSERTIONS=OFF \
	-DLIBUNWIND_USE_COMPILER_RT=ON \
	-DLLVM_BUILD_LLVM_DYLIB=ON \
	-DLLVM_ENABLE_LIBCXX=ON \
	-DLLVM_ENABLE_LLD=ON \
	-DLLVM_ENABLE_PROJECTS="clang;libclc;lld;lldb;llvm" \
	-DLLVM_ENABLE_RTTI=ON \
	-DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx" \
	-DLLVM_ENABLE_ZSTD=OFF \
	-DLLVM_HOST_TRIPLE=$HOST \
	-DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
	-DLLVM_INSTALL_UTILS=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
cmake --build stage2
cmake --install stage2
ln -sf clang $MAPLE/bin/cc
ln -sf clang++ $MAPLE/bin/c++
ln -sf ld.lld $MAPLE/bin/ld
# NOTE: Temporary workaround because builds that require __config fail
#       otherwise. Is there a better solution for this? ~ahill
mv $MAPLE/maple/tools/include/$HOST/c++/v1/__config_site $MAPLE/maple/tools/include/c++/v1/
cd ..

# Rust Build
tar xf ../sources/rustc-*.tar*
cd rustc-*/
./configure \
	--build=$BUILD \
	--enable-clang \
	--enable-extended \
	--enable-lld \
	--enable-local-rust \
	--enable-profiler \
	--enable-sanitizers \
	--enable-use-libcxx \
	--host=$HOST.json \
	--llvm-root=$MAPLE/maple/tools
# NOTE: The target for Alpine is missing musl-root, so we define it here. ~ahill
sed -i "/\[target.$BUILD\]/a musl-root='/usr'" bootstrap.toml
# NOTE: Next, we tell Rust to use our custom LLVM toolchain. ~ahill
sed -i "/\[target.'$HOST.json'\]/a ar = '$MAPLE/maple/tools/bin/llvm-ar'" bootstrap.toml
sed -i "/\[target.'$HOST.json'\]/a cc = '$CC'" bootstrap.toml
sed -i "/\[target.'$HOST.json'\]/a crt-static = false" bootstrap.toml
sed -i "/\[target.'$HOST.json'\]/a cxx = '$CXX'" bootstrap.toml
sed -i "/\[target.'$HOST.json'\]/a musl-root = '$MAPLE'" bootstrap.toml
sed -i "/\[target.'$HOST.json'\]/a linker = '$CC'" bootstrap.toml
sed -i "/\[target.'$HOST.json'\]/a llvm-config = '$MAPLE/maple/tools/bin/llvm-config'" bootstrap.toml
# TODO: Do we need to define llvm-has-rust-patches here? ~ahill
sed -i "/\[target.'$HOST.json'\]/a ranlib = '$MAPLE/maple/tools/bin/llvm-ranlib'" bootstrap.toml
# NOTE: Setting change-id to "ignore" doesn't really have any special
#       significance here. I just got tired of it complaining about the lack of
#       a change-id. ~ahill
sed -i "1i change-id = 'ignore'" bootstrap.toml
# NOTE: Rust requires a JSON specification in addition to the TOML specified
#       above. Since we're using x86_64-unknown-linux-musl as a template, we'll
#       use compiler/rustc_target/src/spec/targets/x86_64_unknown_linux_musl.rs
#       as a reference. ~ahill
# See also: https://doc.rust-lang.org/nightly/nightly-rustc/rustc_target/spec/struct.Target.html
echo "{" > $HOST.json
echo "\"arch\": \"$(echo $HOST | cut -d"-" -f0)\"," >> $HOST.json
# FIXME: How would we even automatically detect this one? ~ahill
echo "\"data-layout\": \"e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128\"," >> $HOST.json
echo "\"llvm-target\": \"$HOST\"," >> $HOST.json
echo "\"metadata\": {}," >> $HOST.json
echo "\"options\": {" >> $HOST.json
# TARGET OPTIONS BEGINS HERE
echo "\"crt-static-respected\": true," >> $HOST.json
echo "\"dynamic-linking\": true," >> $HOST.json
echo "\"env\": \"musl\"," >> $HOST.json
echo "\"families\": [\"unix\"]," >> $HOST.json
echo "\"has-rpath\": true," >> $HOST.json
echo "\"has-thread-local\": true," >> $HOST.json
echo "\"link-self-contained\": \"musl\"," >> $HOST.json
echo "\"os\": \"linux\"," >> $HOST.json
echo "\"position-independent-executables\": true," >> $HOST.json
echo "\"post-link-objects-self-contained\": {" >> $HOST.json
echo "\"dynamic-no-pic-exe\": [\"crt1.o\", \"crti.o\", \"crtbegin.o\"]," >> $HOST.json
echo "\"dynamic-pic-exe\": [\"Scrt1.o\", \"crti.o\", \"crtbeginS.o\"]," >> $HOST.json
echo "\"static-no-pic-exe\": [\"crt1.o\", \"crti.o\", \"crtbegin.o\"]," >> $HOST.json
echo "\"static-pic-exe\": [\"rcrt1.o\", \"crti.o\", \"crtbeginS.o\"]," >> $HOST.json
echo "\"dynamic-dylib\": [\"crti.o\", \"crtbeginS.o\"]," >> $HOST.json
echo "\"static-dylib\": [\"crti.o\", \"crtbeginS.o\"]" >> $HOST.json
echo "}," >> $HOST.json
echo "\"pre-link-objects-self-contained\": {" >> $HOST.json
echo "\"dynamic-no-pic-exe\": [\"crtend.o\", \"crtn.o\"]," >> $HOST.json
echo "\"dynamic-pic-exe\": [\"crtendS.o\", \"crtn.o\"]," >> $HOST.json
echo "\"static-no-pic-exe\": [\"crtend.o\", \"crtn.o\"]," >> $HOST.json
echo "\"static-pic-exe\": [\"crtendS.o\", \"crtn.o\"]," >> $HOST.json
echo "\"dynamic-dylib\": [\"crtendS.o\", \"crtn.o\"]," >> $HOST.json
echo "\"static-dylib\": [\"crtendS.o\", \"crtn.o\"]" >> $HOST.json
echo "}," >> $HOST.json
echo "\"relro-level\": \"full\"," >> $HOST.json
echo "\"supported-split-debuginfo\": [\"packed\", \"unpacked\", \"off\"]" >> $HOST.json
# END OF TARGET OPTIONS
echo "}," >> $HOST.json
# FIXME: How do we automatically detect the pointer width? ~ahill
echo "\"pointer-width\": 64" >> $HOST.json
echo "}" >> $HOST.json
# NOTE: Make sure we revert to Alpine's compiler because we're bootstrapping a
#       compiler again. ~ahill
export CC=clang
export CXX=clang++
./x.py build --stage 0
./x.py build --stage 1
./x.py build --stage 2
# ...
# DESTDIR on ./x.py install?
cd ..

cd ..

# Copy the necessary configuration files to the bootstrap
cp limine.conf $MAPLE/boot/
cp linux.$(uname -m).config $MAPLE/maple/