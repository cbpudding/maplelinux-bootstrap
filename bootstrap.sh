#!/bin/sh -e
export CC=clang
export CFLAGS="-O2 -march=skylake -pipe"
export CXX=clang++
export CXXFLAGS="-O2 -march=skylake -pipe"
export LD=ld.lld
MAPLEROOT=$(pwd)/root
mkdir -p $MAPLEROOT
cd $MAPLEROOT
mkdir -p config dev proc tools run sources sys tmp
cd sources
cp -v $MAPLEROOT/../sources/* .
cp -r $MAPLEROOT/../config/* $MAPLEROOT/config/
cp $MAPLEROOT/../basebuild.sh ..

tar xf llvm-project-*.tar.*
cd llvm-project-*
cmake -B build -G "Unix Makefiles" -S llvm \
    -DBOOTSTRAP_CLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DBOOTSTRAP_CLANG_DEFAULT_RTLIB=compiler-rt \
    -DBOOTSTRAP_CLANG_DEFAULT_UNWINDLIB=libunwind \
    -DBOOTSTRAP_CLANG_VENDOR=Maple \
    -DBOOTSTRAP_CMAKE_BUILD_TYPE=Release \
    -DBOOTSTRAP_CMAKE_INSTALL_PREFIX=$MAPLEROOT/usr \
    -DBOOTSTRAP_CMAKE_SYSROOT=$MAPLEROOT \
    -DBOOTSTRAP_LIBCXX_CXX_ABI=libcxxabi \
    -DBOOTSTRAP_LIBCXX_HAS_MUSL_LIBC=ON \
    -DBOOTSTRAP_LIBCXX_USE_COMPILER_RT=YES \
    -DBOOTSTRAP_LIBCXXABI_USE_COMPILER_RT=YES \
    -DBOOTSTRAP_LIBCXXABI_USE_LLVM_UNWINDER=YES \
    -DBOOTSTRAP_LIBUNWIND_USE_COMPILER_RT=ON \
    -DBOOTSTRAP_LLVM_BUILD_LLVM_DYLIB=ON \
    -DBOOTSTRAP_LLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-musl \
    -DBOOTSTRAP_LLVM_ENABLE_LIBCXX=ON \
    -DBOOTSTRAP_LLVM_ENABLE_LLD=ON \
    -DBOOTSTRAP_LLVM_INCLUDE_BENCHMARKS=OFF \
    -DBOOTSTRAP_LLVM_INCLUDE_EXAMPLES=OFF \
    -DBOOTSTRAP_LLVM_INCLUDE_TESTS=OFF \
    -DBOOTSTRAP_LLVM_INSTALL_BINUTILS_SYMLINKS=ON \
    -DBOOTSTRAP_LLVM_INSTALL_CCTOOLS_SYMLINKS=ON \
    -DBOOTSTRAP_LLVM_INSTALL_UTILS=ON \
    -DBOOTSTRAP_LLVM_LINK_LLVM_DYLIB=ON \
    -DBOOTSTRAP_LLVM_TARGETS_TO_BUILD=X86 \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
    -DCLANG_ENABLE_BOOTSTRAP=ON \
    -DCLANG_VENDOR=Maple \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$MAPLEROOT/tools \
    -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXX_HAS_MUSL_LIBC=ON \
    -DLIBCXX_USE_COMPILER_RT=YES \
    -DLIBCXXABI_USE_COMPILER_RT=YES \
    -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
    -DLIBUNWIND_USE_COMPILER_RT=YES \
    -DLLVM_DEFAULT_TARGET_TRIPLE=x86_64-unknown-linux-musl \
    -DLLVM_ENABLE_PROJECTS="clang;lld" \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi;libunwind" \
    -DLLVM_ENABLE_LLD=ON \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_TARGETS_TO_BUILD=X86
make -C build -j $(nproc) -l $(($(nproc) + 1))
make -C build install
export CC=$MAPLEROOT/tools/bin/clang
export CXX=$MAPLEROOT/tools/bin/clang++
export LD=$MAPLEROOT/tools/bin/ld.lld
cd ..

tar xf linux-*.tar.*
cd linux-*
LLVM=1 make mrproper
cp $MAPLEROOT/config/linux .config
LLVM=1 make -j $(nproc) -l $(($(nproc) + 1)) headers
LLVM=1 make headers_install INSTALL_HDR_PATH=$MAPLEROOT/usr
cd ..

tar xf musl-*.tar.*
cd musl-*
./configure --includedir=/usr/include --prefix=/
make -j $(nproc) -l $(($(nproc) + 1))
make install DESTDIR=$MAPLEROOT
cd ..

tar xf busybox-*.tar.*
cd busybox-*
cp $MAPLEROOT/config/busybox .config
make -j $(nproc) -l $(($(nproc) + 1))
make install CONFIG_PREFIX=$MAPLEROOT
cd ..

tar xf make-*.tar.*
cd make-*
./configure --disable-nls --enable-year2038 --prefix=/usr
make -j $(nproc) -l $(($(nproc) + 1))
make install DESTDIR=$MAPLEROOT
cd ..

tar xf zstd-*.tar.*
cd zstd-*
make -j $(nproc) -l $(($(nproc) + 1))
make install PREFIX=$MAPLEROOT/usr
cd ..

cd llvm-project-*
export LD_LIBRARY_PATH=$MAPLEROOT/tools/lib/x86_64-unknown-linux-musl
make -C build -j $(nproc) -l $(($(nproc) + 1)) stage2
make -C build stage2-install
cd ..

cd ..
# Patch so LLVM can find libc++ and libunwind
mv usr/lib/x86_64-unknown-linux-musl/* usr/lib/
rm -rf usr/lib/x86_64-unknown-linux-musl
# Patch so LLVM can work using "normal" commands
ln -s clang++ usr/bin/c++
ln -s clang usr/bin/cc
ln -s ld.lld usr/bin/ld

cd ..