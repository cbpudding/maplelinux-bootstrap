#!/bin/zsh -e
export BUILD=$(clang -dumpmachine)
export MAPLE=$(pwd)/maple
export MICROARCH="skylake"
export TARGET=x86_64-maple-linux-musl

export AR=llvm-ar
export CC=clang
export CFLAGS="-O3 -march=$MICROARCH -pipe"
export CXX=clang++
export CXXFLAGS="$CFLAGS"
export LD=ld.lld
export RANLIB=llvm-ranlib
export THREADS=$(nproc)

# A simplified version of the filesystem loosely based on FHS with symlinks for
# backwards compatibility. ~ahill
mkdir -p $MAPLE/{bin,boot/EFI/BOOT,dev,etc,home,lib,proc,run,sys,tmp,usr/{include,share},var/{cache,lib,log,spool,tmp}}
# TODO: Does it make sense to have this long-term? Anything that depends on
#       libc++ fails to link without it, but this should be fixed via a
#       configuration change in LLVM. ~ahill
ln -sf . $MAPLE/lib/$TARGET
ln -sf . $MAPLE/usr/include/$TARGET
# NOTE: Symlinks are for compatibility's sake. These shouldn't have to exist for
#       the base system to function. ~ahill
ln -sf bin $MAPLE/sbin
ln -sf ../bin $MAPLE/usr/bin
ln -sf ../bin $MAPLE/usr/sbin
ln -sf ../lib $MAPLE/usr/lib
ln -sf ../lib $MAPLE/usr/libexec
ln -sf ../run/lock $MAPLE/var/lock
ln -sf ../run $MAPLE/var/run

# NOTE: These are exclusively used for the bootstrapping process and can be
#       removed later. ~ahill
mkdir -p $MAPLE/maple/{patches,sources}

# Create the build directory and enter it so we can begin! ~ahill
mkdir build
cd build

# Linux Headers
tar xf ../sources/linux-*.tar*
cd linux-*/
LLVM=1 make -j $THREADS mrproper
# NOTE: We don't use the built-in headers_install here because it requires rsync
#       for some reason. ~ahill
LLVM=1 make -j $THREADS headers
find usr/include -type f ! -name "*.h" -delete
cp -r usr/include $MAPLE/usr
cd ..

# musl Build (Stage 1)
tar xf ../sources/musl-*.tar*
cd musl-*/
./configure \
    --bindir=/bin \
    --build=$BUILD \
    --includedir=/usr/include \
    --libdir=/lib \
    --prefix=/ \
    --target=$TARGET
make -O -j $THREADS
make -O install-headers DESTDIR=$MAPLE
cd ..

# LLVM Build
tar xf ../sources/llvm-project-*.tar*
cd llvm-project-*/

# Common flags used across all of the LLVM builds
COMMON_LLVM_CMAKE=(
    "-DCMAKE_ASM_COMPILER_TARGET=$TARGET"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
    "-DCMAKE_C_COMPILER=$CC"
    "-DCMAKE_C_COMPILER_TARGET=$TARGET"
    "-DCMAKE_CXX_COMPILER=$CXX"
    "-DCMAKE_CXX_COMPILER_TARGET=$TARGET"
    "-DCMAKE_FIND_ROOT_PATH=$MAPLE"
    "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY"
    "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY"
    "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY"
    "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER"
    "-DCMAKE_INSTALL_DATAROOTDIR=usr/share"
    "-DCMAKE_INSTALL_INCLUDEDIR=usr/include"
    "-DCMAKE_INSTALL_LIBEXECDIR=lib"
    "-DCMAKE_INSTALL_PREFIX=$MAPLE"
    "-DCMAKE_INSTALL_RPATH=/lib"
    "-DCMAKE_INSTALL_RUNSTATEDIR=run"
    "-DCMAKE_INSTALL_SHAREDSTATEDIR=usr/com"
    "-DCMAKE_SYSROOT=$MAPLE"
    "-DCMAKE_SYSTEM_NAME=Linux"
    "-DLLVM_HOST_TRIPLE=$TARGET"
    "-DLLVM_USE_LINKER=lld"
    "-DLLVM_TARGETS_TO_BUILD=X86"
    "-DLLVM_ENABLE_ZSTD=OFF"
)

# (LLVM) Builtins Build
# NOTE: For some reason, atomics are not built unless you... disable the thing
#       that disables it? Why was it implemented this way? ~ahill
cmake -S compiler-rt/lib/builtins -B build-builtins \
    $COMMON_LLVM_CMAKE \
    -DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=OFF
cmake --build build-builtins
cmake --install build-builtins

# musl Build (Stage 2)
# FIXME: CVE-2025-26519
cd ../musl-*/
make -O clean
CFLAGS="-fuse-ld=lld --sysroot=$MAPLE $CFLAGS" \
LIBCC="$MAPLE/lib/linux/libclang_rt.builtins-x86_64.a" \
./configure \
    --bindir=/bin \
    --build=$BUILD \
    --includedir=/usr/include \
    --libdir=/lib \
    --prefix=/ \
    --target=$TARGET
make -O -j $THREADS
make -O install DESTDIR=$MAPLE
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
cd ../llvm-project-*/

# (LLVM) Runtimes Build
# TODO: Is it possible to prevent CMake from building static libraries? ~ahill
# NOTE: We have to trick CMake because we don't have a copy of libunwind yet, so
#       CMAKE_C_COMPILER_WORKS and CMAKE_CXX_COMPILER_WORKS are manually set to
#       prevent it from trying to link with libunwind initially. ~ahill
cmake -S runtimes -B build-runtimes \
    $COMMON_LLVM_CMAKE \
    -DCMAKE_C_COMPILER_WORKS=ON \
    -DCMAKE_C_FLAGS="-fuse-ld=lld -Qunused-arguments -rtlib=compiler-rt -Wl,--dynamic-linker=/lib/ld-musl-x86_64.so.1" \
    -DCMAKE_CXX_COMPILER_WORKS=ON \
    -DCMAKE_CXX_FLAGS="-fuse-ld=lld -Qunused-arguments -rtlib=compiler-rt -Wl,--dynamic-linker=/lib/ld-musl-x86_64.so.1" \
    -DCOMPILER_RT_EXCLUDE_ATOMIC_BUILTIN=OFF \
    -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
    -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXX_HAS_MUSL_LIBC=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXXABI_HAS_CXA_THREAD_ATEXIT_IMPL=OFF \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLLVM_ENABLE_RUNTIMES="compiler-rt;libunwind;libcxxabi;libcxx"
cmake --build build-runtimes
cmake --install build-runtimes

# (LLVM) LLVM Build
# NOTE: For some reason, atomics cannot be found in compiler-rt, so we have to
#       help it by specifying HAVE_CXX_ATOMICS_WITHOUT_LIB and
#       HAVE_CXX_ATOMICS64_WITHOUT_LIB. ~ahill
cmake -S llvm -B build-llvm \
    $COMMON_LLVM_CMAKE \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
    -DCLANG_VENDOR=Maple \
    -DCMAKE_C_FLAGS="-fuse-ld=lld -Qunused-arguments -rtlib=compiler-rt -unwindlib=libunwind -Wl,--dynamic-linker=/lib/ld-musl-x86_64.so.1" \
    -DCMAKE_CXX_FLAGS="-fuse-ld=lld -Qunused-arguments -rtlib=compiler-rt -stdlib=libc++ -unwindlib=libunwind -Wl,--dynamic-linker=/lib/ld-musl-x86_64.so.1" \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCXX_SUPPORTS_CUSTOM_LINKER=ON \
    -DHAVE_CXX_ATOMICS_WITHOUT_LIB=ON \
    -DHAVE_CXX_ATOMICS64_WITHOUT_LIB=ON \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_PROJECTS="clang;libclc;lld;lldb;llvm" \
    -DLLVM_ENABLE_RTTI=ON \
    -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
    -DLLVM_INSTALL_UTILS=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON
cmake --build build-llvm
# ...

# Finally done with LLVM ~ahill
cd ..

# ...