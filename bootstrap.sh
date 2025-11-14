#!/bin/zsh -e

MICROARCH="skylake"
TARGET=x86_64-maple-linux-musl

# Set the environment up
ARCH=$(echo $TARGET | cut -d"-" -f1)
BOOTSTRAP=$(pwd)/.bootstrap
PROCS=$(nproc)
SOURCES=$(pwd)/.treetap/sources
SPEC=$(pwd)/sources
export AR=llvm-ar
export CC=clang
export CFLAGS="-fuse-ld=lld -O3 -march=$MICROARCH -pipe --sysroot=$BOOTSTRAP/root -Wno-unused-command-line-argument"
export CXX=clang++
export CXXFLAGS=$CFLAGS
export RANLIB=llvm-ranlib
export LD=ld.lld
export LDFLAGS="--sysroot=$BOOTSTRAP/root"
export TT_SYSROOT=$BOOTSTRAP/root
export TT_TARGET=$TARGET

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
LINUX_VERSION=$(sed -En "s/SRC_VERSION=\"?(.+)\"/\1/p" $SPEC/linux.spec)
tar xf $SOURCES/linux/$LINUX_VERSION/linux-*.tar*
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
MUSL_VERSION=$(sed -En "s/SRC_VERSION=\"?(.+)\"/\1/p" $SPEC/musl.spec)
tar xf $SOURCES/musl/$MUSL_VERSION/musl-*.tar*
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
# NOTE: The build is skipped here because we only care about the header files at
#       this point. ~ahill
make -O -j $PROCS install-headers DESTDIR=$BOOTSTRAP/root
cd ..

# Build and install compiler-rt builtins
LLVM_VERSION=$(sed -En "s/SRC_VERSION=\"?(.+)\"/\1/p" $SPEC/llvm.spec)
tar xf $SOURCES/llvm/$LLVM_VERSION/llvm-project-*.tar*
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
# FIXME: Patch CVE-2025-26519 ~ahill
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
# NOTE: Not sure why this didn't show up before, but CMAKE_C_COMPILER_WORKS is
#       is manually set because the C compiler attempts to link with libgcc_s or
#       libunwind, even though it doesn't exist yet. ~ahill
cd llvm-project-*/
cmake -S runtimes -B build-runtimes \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER_WORKS=ON \
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

# Now we can introduce libunwind and libc++ into the environment
# NOTE: clang++ attempts to build with headers from the build system rather than
#       exclusively relying on the sysroot. Because of this, we must manually
#       define the proper include path. ~ahill
export CFLAGS="$CFLAGS -unwindlib=libunwind"
export CXXFLAGS="$CXXFLAGS -isystem $BOOTSTRAP/root/usr/include/c++/v1 -nostdinc++ -stdlib=libc++ -unwindlib=libunwind"

# Build clang/LLVM
# NOTE: LLVM_ENABLE_ZSTD is disabled because we don't have zstd in the sysroot,
#       and because I don't believe that a library created by Facebook should
#       be required for an operating system to function. ~ahill
# NOTE: If we don't do this, LLVM attempts to build its own copy of tblgen,
#       which will cause the build to fail since we're cross-compiling and can't
#       run programs built for another platform. LLVM_NATIVE_TOOL_DIR,
#       LLVM_TABLEGEN, and CLANG_TABLEGEN are set based on this variable. ~ahill
NATIVE_TOOL_DIR=$(dirname $(which llvm-tblgen))
cd llvm-project-*/
cmake -S llvm -B build-llvm \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
    -DCLANG_TABLEGEN=$NATIVE_TOOL_DIR/clang-tblgen \
    -DCLANG_VENDOR=Maple \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$BOOTSTRAP/root \
    -DCMAKE_TOOLCHAIN_FILE=$BOOTSTRAP/$TARGET.cmake \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_PROJECTS="clang;lld;llvm" \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_HOST_TRIPLE=$TARGET \
    -DLLVM_NATIVE_TOOL_DIR=$NATIVE_TOOL_DIR \
    -DLLVM_TABLEGEN=$NATIVE_TOOL_DIR/llvm-tblgen
cmake --build build-llvm --parallel $PROCS
cmake --install build-llvm --parallel $PROCS
cd ..

# Build Busybox
BUSYBOX_VERSION=$(sed -En "s/SRC_VERSION=\"?(.+)\"/\1/p" $SPEC/busybox.spec)
tar xf $SOURCES/busybox/$BUSYBOX_VERSION/busybox-*.tar*
cd busybox-*/
# NOTE: Like we did with musl before, we don't set CROSS_COMPILE because LLVM is
#       smart and doesn't need a compiler to cross-compile code. With that said,
#       Busybox uses Kbuild, which hard-codes variables like CC to GNU-based
#       tools, which is not what we want. The following sed hack should do the
#       trick, but I wonder if there's a better solution. ~ahill
sed -i "s/?*= \$(CROSS_COMPILE)/?= /" Makefile
make -O -j $PROCS defconfig
# NOTE: tc causes a LOT of issues due to undefined things. We don't really need
#       "traffic control" at this time, and when we eventually do, we will
#       likely use something else. ~ahill
sed -i "s/CONFIG_TC=.*/CONFIG_TC=n/" .config
make -O -j $PROCS
# NOTE: Busybox doesn't appear to have a proper DESTDIR, so we just set
#       CONFIG_PREFIX during the install step to work around this. ~ahill
make -O -j $PROCS install CONFIG_PREFIX=$BOOTSTRAP/root
cd ..

# Install Treetap
cp $BOOTSTRAP/../treetap $BOOTSTRAP/root/bin/