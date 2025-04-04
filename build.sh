#!/bin/sh -e
export CC=clang
export CXX=clang++
export LD=ld.lld
export MAPLE=$(pwd)/maple
export THREADS=$(nproc)
export HOST=x86_64-unknown-linux-musl

# A simplified FHS variant with symlinks for backwards compatibility ~ahill
# TODO: Where does /usr/com fit into all of this (shared state directory)? ~ahill
mkdir -p $MAPLE/bin
mkdir -p $MAPLE/boot
mkdir -p $MAPLE/dev
mkdir -p $MAPLE/etc
mkdir -p $MAPLE/home/root
mkdir -p $MAPLE/lib
# TODO: Does it make sense to have this long-term? Anything that depends on
#       libc++ fails to link without it, but this should be fixed via a
#       configuration change in LLVM. ~ahill
ln -s . $MAPLE/lib/$HOST
mkdir -p $MAPLE/maple/sources
mkdir -p $MAPLE/mnt
mkdir -p $MAPLE/proc
ln -s home/root $MAPLE/root
ln -s var/run $MAPLE/run
mkdir -p $MAPLE/sbin
mkdir -p $MAPLE/sys
mkdir -p $MAPLE/tmp
mkdir -p $MAPLE/usr
ln -s ../bin $MAPLE/usr/bin
mkdir -p $MAPLE/usr/include
ln -s ../lib $MAPLE/usr/lib
ln -s ../sbin $MAPLE/usr/sbin
mkdir -p $MAPLE/usr/share
mkdir -p $MAPLE/var
mkdir -p $MAPLE/var/cache
mkdir -p $MAPLE/var/lib
mkdir -p $MAPLE/var/lock
mkdir -p $MAPLE/var/log
mkdir -p $MAPLE/var/run
mkdir -p $MAPLE/var/spool
mkdir -p $MAPLE/var/tmp

mkdir -p build
cd build

# LLVM Build
tar xf ../sources/llvm-project-*.tar*
cd llvm-project-*/
cmake -B build -G Ninja -S llvm \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=$MAPLE/maple/tools \
	-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	-DCLANG_DEFAULT_RTLIB=compiler-rt \
	-DCLANG_DEFAULT_UNWINDLIB=libunwind \
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
	-DLLVM_ENABLE_PROJECTS="clang;lld;llvm" \
	-DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx" \
	-DLLVM_HOST_TRIPLE=$HOST \
	-DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
	-DLLVM_INSTALL_UTILS=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DLLVM_TARGETS_TO_BUILD=X86
cmake --build build
cmake --install build
cd ..

export CC=$MAPLE/maple/tools/bin/clang
export CXX=$MAPLE/maple/tools/bin/clang++
export LD=$MAPLE/maple/tools/bin/ld.lld
export PATH="$MAPLE/maple/tools/bin:$PATH"

# Linux Headers
tar xf ../sources/linux-*.tar*
cd linux-*/
LLVM=1 make -j $THREADS mrproper
LLVM=1 make -j $THREADS headers_install INSTALL_HDR_PATH=$MAPLE/usr
cd ..

# musl Build
tar xf ../sources/musl-*.tar*
cd musl-*/
./configure --disable-static --includedir=/usr/include --prefix=""
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# dash Build
tar xf ../sources/dash-*.tar*
cd dash-*/
./configure \
	--datarootdir=/usr/share \
	--exec-prefix="" \
	--includedir=/usr/include \
	--libexecdir=/bin \
	--prefix="" \
	--sharedstatedir=/usr/com
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
ln -s dash $MAPLE/bin/sh
cd ..

# m4 Build
tar xf ../sources/m4-*.tar*
cd m4-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--enable-c++ \
	--includedir=/usr/include \
	--libexecdir=/usr/bin \
	--prefix="" \
	--sharedstatedir=/usr/com
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# ncurses Build
tar xf ../sources/ncurses.tar.gz
cd ncurses-*/
./configure \
	--enable-ext-colors \
	--enable-widec \
	--exec-prefix="" \
	--libexecdir=/usr/bin \
	--prefix=/usr \
	--with-shared \
	--with-cxx-binding \
	--with-cxx-shared \
	--without-ada \
	--without-manpages \
	--without-normal
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# Coreutils Build
tar xf ../sources/coreutils-*.tar*
cd coreutils-*/
./configure \
	--datarootdir=/usr/share \
	--disable-nls \
	--includedir=/usr/include \
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
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
	--libexecdir=/usr/bin \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREAD
make -j $THREAD install DESTDIR=$MAPLE
cd ..

# LLVM Build (Stage 2)
rm -rf llvm-project-*/
tar xf ../sources/llvm-project-*.tar*
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
cmake -B build -G Ninja -S llvm \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX=$MAPLE/usr \
	-DCMAKE_TOOLCHAIN_FILE=$(pwd)/$TOOLCHAIN_FILE \
	-DCLANG_DEFAULT_CXX_STDLIB=libc++ \
	-DCLANG_DEFAULT_RTLIB=compiler-rt \
	-DCLANG_DEFAULT_UNWINDLIB=libunwind \
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
	-DLLVM_ENABLE_PROJECTS="clang;lld;llvm" \
	-DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx" \
	-DLLVM_ENABLE_ZSTD=OFF \
	-DLLVM_HOST_TRIPLE=$HOST \
	-DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
	-DLLVM_INSTALL_UTILS=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON
cmake --build build
cmake --install build
ln -s clang $MAPLE/bin/cc
ln -s ld.lld $MAPLE/bin/ld
cd ..

# CMake Build
tar xf ../sources/cmake-*.tar*
cd cmake-*/
# NOTE: Tests are disabled because they attempt to run on the system responsible
#       for the build, not the system being built. ~ahill
cmake -B build -G Ninja \
	-DBUILD_TESTING=OFF \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_COMPILER=$CC \
	-DCMAKE_CXX_COMPILER=$CXX \
	-DCMAKE_INSTALL_PREFIX=$MAPLE/usr \
	-DCMAKE_SYSROOT=$MAPLE \
	-DCMAKE_USE_OPENSSL=OFF
cmake --build build
cmake --install build
cd ..

# Samurai Build
tar xf ../sources/samurai-*.tar*
cd samurai-*/
# NOTE: Unfortunately, there is no way to change the prefix without modifying
#       the Makefile. ~ahill
sed -i "s/^PREFIX=.*/PREFIX=\/usr/" Makefile
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..

# Muon Build
tar xf ../sources/muon-*.tar*
cd muon-*/
# TODO: Am I doing this right? ~ahill
echo "[host_machine]" > cross-maple.txt
echo "cpu_family='x86_64'" >> cross-maple.txt
echo "cpu='skylake'" >> cross-maple.txt
echo "endian='little'" >> cross-maple.txt
echo "system='linux'" >> cross-maple.txt
echo "" >> cross-maple.txt
echo "[properties]" >> cross-maple.txt
echo "sys_root='$MAPLE'" >> cross-maple.txt
# FIXME: Alpine doesn't package Muon so we're using Meson instead. ~ahill
meson setup build --prefix /usr --cross-file cross-maple.txt
meson compile -C build
DESTDIR=$MAPLE meson install -C build
cd ..

# Gawk Build
tar xf ../sources/gawk-*.tar*
cd gawk-*/
./configure \
	--disable-mpfr \
	--disable-nls \
	--exec-prefix="" \
	--libexecdir=/bin \
	--localstatedir=/var \
	--prefix=/usr \
	--sysconfdir=/etc
make -j $THREADS
make -j $THREADS install DESTDIR=$MAPLE
cd ..