#!/bin/zsh -e

BOOTSTRAP=$(pwd)/.bootstrap
MICROARCH="skylake"
PROCS=$(nproc)
SOURCES=$(pwd)/.treetap/sources
TARGET=x86_64-maple-linux-musl

# Fetch sources required for a bootstrap
./treetap fetch sources/busybox.spec
./treetap fetch sources/linux.spec
./treetap fetch sources/llvm.spec
./treetap fetch sources/musl.spec

# Simplified filesystem heirarchy with symlinks for compatibility
mkdir -p $BOOTSTRAP/root/{bin,boot/EFI/BOOT,dev,etc,home,lib,proc,run,sys,tmp,usr/{include,share},var/{cache,lib,log,spool,tmp}}
ln -sf bin $BOOTSTRAP/root/sbin
ln -sf ../bin $BOOTSTRAP/root/usr/bin
ln -sf ../bin $BOOTSTRAP/root/usr/sbin
ln -sf ../lib $BOOTSTRAP/root/usr/lib
ln -sf ../lib $BOOTSTRAP/root/usr/libexec
ln -sf ../run/lock $BOOTSTRAP/root/var/lock
ln -sf ../run $BOOTSTRAP/root/var/run

# Prepare for the build
ARCH=$(echo $TARGET | cut -d"-" -f1)
export AR=llvm-ar
export CC=clang
export CFLAGS="-fuse-ld=lld -O3 -march=$MICROARCH -pipe --sysroot=$BOOTSTRAP/root -Wno-unused-command-line-argument"
export CXX=clang++
export CXXFLAGS=$CFLAGS
export RANLIB=llvm-ranlib
export LD=ld.lld
export TREETAP_SYSROOT=$BOOTSTRAP/root
export TREETAP_TARGET=$TARGET
mkdir -p $BOOTSTRAP/build
cd $BOOTSTRAP/build

# Define the target for Maple Linux
cat << EOF > $BOOTSTRAP/$TARGET.cmake
set(CMAKE_ASM_COMPILER_TARGET $TARGET)
set(CMAKE_C_COMPILER $CC)
set(CMAKE_C_COMPILER_TARGET $TARGET)
set(CMAKE_C_FLAGS_INIT "$CFLAGS")
set(CMAKE_CXX_COMPILER $CXX)
set(CMAKE_CXX_COMPILER_TARGET $TARGET)
set(CMAKE_CXX_FLAGS_INIT "$CXXFLAGS")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_LINKER_TYPE LLD)
set(CMAKE_SYSROOT "$BOOTSTRAP/root")
set(CMAKE_SYSTEM_NAME Linux)
EOF

# Install headers for Linux
tar xf $SOURCES/linux/*/linux-*.tar*
cd linux-*/
# NOTE: LLVM=1 is required here because GCC and other GNU tools are required in
#       some places still. This allows us to use LLVM and bypass the parts that
#       haven't become portable yet. ~ahill
LLVM=1 make -j $PROCS mrproper
# NOTE: We don't use the built-in headers_install target because it requires
#       rsync for some reason. ~ahill
LLVM=1 make -j $PROCS headers ARCH=$ARCH
find usr/include -type f ! -name "*.h" -delete
cp -r usr/include $BOOTSTRAP/root/usr
cd ..

# Install headers for musl
tar xf $SOURCES/musl/*/musl-*.tar*
cd musl-*/
# NOTE: We are intentionally not passing --target here because musl follows the
#       GNU approach when it comes to cross-compiling. This means the build
#       script prefaces the name of every build tool with the target triple
#       we're compiling for. This is unnecessary for LLVM, because we can simply
#       pass -target <triple> to the compiler and have it generate machine code
#       for that target. ~ahill
./configure \
    --bindir=/bin \
    --includedir=/usr/include \
    --libdir=/lib \
    --prefix=/
make -O -j $PROCS
make -O -j $PROCS install-headers DESTDIR=$BOOTSTRAP/root
cd ..

# Build and install compiler-rt builtins
tar xf $SOURCES/llvm/*/llvm-project-*.tar*
cd llvm-project-*/
cmake -S compiler-rt/lib/builtins -B build-builtins \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$BOOTSTRAP/root \
    -DCMAKE_TOOLCHAIN_FILE=$BOOTSTRAP/$TARGET.cmake \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON
cmake --build build-builtins --parallel $PROCS
cmake --install build-builtins --parallel $PROCS
cd ..

# Build musl for real this time
cd musl-*/
# TODO: CVE-2025-26519
make clean
# NOTE: LIBCC is required here because it will attempt to link with the build
#       system's runtime if this is not specified. ~ahill
LIBCC="$BOOTSTRAP/root/lib/linux/libclang_rt.builtins-x86_64.a" \
./configure \
    --bindir=/bin \
    --includedir=/usr/include \
    --libdir=/lib \
    --prefix=/
make -O -j $PROCS
make -O -j $PROCS install DESTDIR=$BOOTSTRAP/root
cd ..

# Include compiler-rt and musl in our environment
export CFLAGS="$CFLAGS -Qunused-arguments -rtlib=compiler-rt -Wl,--dynamic-linker=/lib/ld-musl-$ARCH.so.1"
export CXXFLAGS="$CXXFLAGS -Qunused-arguments -rtlib=compiler-rt -Wl,--dynamic-linker=/lib/ld-musl-$ARCH.so.1"

# Build the LLVM runtimes
# NOTE: When CMake tests the C++ compiler, it attempts to link libstdc++/libc++
#       before it even exists, causing an error. We can bypass this by simply
#       setting CMAKE_CXX_COMPILER_WORKS, therefore tricking CMake into
#       performing a successful build. Yet another instance where the genie in
#       the bottle does exactly what we asked, and not what we wanted. ~ahill
cd llvm-project-*/
cmake -S runtimes -B build-runtimes \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_INSTALL_INCLUDEDIR=$BOOTSTRAP/root/usr/include \
    -DCMAKE_INSTALL_PREFIX=$BOOTSTRAP/root \
    -DCMAKE_TOOLCHAIN_FILE=$BOOTSTRAP/$TARGET.cmake \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
    -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXX_HAS_MUSL_LIBC=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt;libcxx;libcxxabi;libunwind"
cmake --build build-runtimes --parallel $PROCS
cmake --install build-runtimes --parallel $PROCS
cd ..

# Now we can introduce libc++ into the environment
# NOTE: clang++ attempts to build with headers from the build system rather than
#       exclusively relying on the sysroot. Because of this, we must manually
#       define the proper include path. ~ahill
export CXXFLAGS="$CXXFLAGS -isystem $BOOTSTRAP/root/usr/include/c++/v1 -nostdinc++ -stdlib=libc++"

# Build LLVM itself
# NOTE: LLVM_ENABLE_ZSTD is disabled because we don't have zstd in the sysroot,
#       and because I don't believe that a library created by Facebook should
#       be required for an operating system to function. ~ahill
cd llvm-project-*/
cmake -S llvm -B build-llvm \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
    -DCLANG_VENDOR=Maple \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$BOOTSTRAP/root \
    -DCMAKE_TOOLCHAIN_FILE=$BOOTSTRAP/$TARGET.cmake \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_PROJECTS="clang;lld;llvm" \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_HOST_TRIPLE=$TARGET
cmake --build build-llvm --parallel $PROCS
# ...
cd ..
