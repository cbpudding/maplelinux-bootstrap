#!/bin/zsh -e

MICROARCH=skylake
TARGET=x86_64-maple-linux-musl

# Set the environment up
ARCH=$(echo $TARGET | cut -d"-" -f1)
BOOTSTRAP=$(pwd)/.bootstrap
PROCS=$(nproc)
SOURCES=$(pwd)/.treetap/sources
SPEC=$(pwd)/sources
export AR=llvm-ar
export AS=llvm-as
if [ ! -z "$CCACHE" ]; then
    export CC="$CCACHE clang"
    export CXX="$CCACHE clang++"
else
    export CC=clang
    export CXX=clang++
fi
export CFLAGS="-fuse-ld=mold -O3 -march=$MICROARCH -pipe --sysroot=$BOOTSTRAP/root -Wno-unused-command-line-argument"
export CXXFLAGS=$CFLAGS
export RANLIB=llvm-ranlib
export LD=mold
export LDFLAGS="--sysroot=$BOOTSTRAP/root"
export TREETAP=$(pwd)/treetap
export TT_DIR=$(pwd)/.treetap
export TT_MICROARCH=$MICROARCH
export TT_SYSROOT=$BOOTSTRAP/root
export TT_TARGET=$TARGET

# Fetch sources required for a bootstrap
$TREETAP fetch sources/linux/linux.spec
$TREETAP fetch sources/llvm/llvm.spec
$TREETAP fetch sources/musl/musl.spec

# Make sure both clang-tblgen and llvm-tblgen are in the PATH. ~ahill
which clang-tblgen > /dev/null
[ ! "$?" = "0" ] && (echo "Unable to find clang-tblgen"; exit 1)
which llvm-tblgen > /dev/null
[ ! "$?" = "0" ] && (echo "Unable to find llvm-tblgen"; exit 1)

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
# NOTE: We run cut on CC and CXX just in case ccache is in use. ~ahill
cat << EOF > $BOOTSTRAP/$TARGET.cmake
set(CMAKE_ASM_COMPILER_TARGET $TARGET)
set(CMAKE_C_COMPILER $(echo $CC | cut -d" " -f2))
set(CMAKE_C_COMPILER_TARGET $TARGET)
set(CMAKE_C_FLAGS_INIT "$CFLAGS")
set(CMAKE_CXX_COMPILER $(echo $CXX | cut -d" " -f2))
set(CMAKE_CXX_COMPILER_TARGET $TARGET)
set(CMAKE_CXX_FLAGS_INIT "$CXXFLAGS")
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_LINKER_TYPE MOLD)
set(CMAKE_SYSROOT "$BOOTSTRAP/root")
set(CMAKE_SYSTEM_NAME Linux)
EOF
# NOTE: CMake doesn't like dealing with ccache inside of CC/CXX, so we do this
#       instead. ~ahill
if [ ! -z "$CCACHE" ]; then
cat << EOF >> $BOOTSTRAP/$TARGET.cmake
set(CMAKE_C_COMPILER_LAUNCHER $CCACHE)
set(CMAKE_CXX_COMPILER_LAUNCHER $CCACHE)
EOF
fi

# Install headers for Linux
LINUX_VERSION=$(sed -En "s/SRC_VERSION=\"?(.+)\"/\1/p" $SPEC/linux/linux.spec)
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
MUSL_VERSION=$(sed -En "s/SRC_VERSION=\"?(.+)\"/\1/p" $SPEC/musl/musl.spec)
tar xf $SOURCES/musl/$MUSL_VERSION/musl-*.tar*
cd musl-*/
# NOTE: Patch for musl 1.2.5 to prevent a character encoding vulnerability. This
#       should be safe to remove after the next release. ~ahill
patch -p1 < $BOOTSTRAP/../sources/musl/CVE-2025-26519.patch
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
LLVM_VERSION=$(sed -En "s/SRC_VERSION=\"?(.+)\"/\1/p" $SPEC/llvm/llvm.spec)
LLVM_MAJOR_VERSION=$(echo $LLVM_VERSION | cut -d"." -f1)
tar xf $SOURCES/llvm/$LLVM_VERSION/llvm-project-*.tar*
cd llvm-project-*/
cmake -S compiler-rt/lib/builtins -B build-builtins \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$BOOTSTRAP/root/lib/clang/$LLVM_MAJOR_VERSION \
    -DCMAKE_TOOLCHAIN_FILE=$BOOTSTRAP/$TARGET.cmake \
    -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON
cmake --build build-builtins --parallel $PROCS
cmake --install build-builtins --parallel $PROCS
cd ..

# Build musl for real this time
# NOTE: LIBCC is required here because it will attempt to link with the build
#       system's runtime if this is not specified. ~ahill
LIBCC="$BOOTSTRAP/root/lib/clang/$LLVM_MAJOR_VERSION/lib/linux/libclang_rt.builtins-x86_64.a" \
$TREETAP build $SPEC/musl/musl.spec
$TREETAP package $SPEC/musl/musl.spec
$TREETAP install $TT_DIR/packages/$MICROARCH/musl-*.cpio.xz $BOOTSTRAP/root

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
    -DLIBCXX_CXX_ABI=libcxxabi \
    -DLIBCXX_HAS_MUSL_LIBC=ON \
    -DLIBCXX_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_COMPILER_RT=ON \
    -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
    -DLIBUNWIND_USE_COMPILER_RT=ON \
    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"
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
# NOTE: LLVM attempts to build its own copy of tblgen, which will cause the
#       build to fail since we're cross-compiling and can't run programs built
#       for another platform. LLVM_NATIVE_TOOL_DIR, LLVM_TABLEGEN, and
#       CLANG_TABLEGEN are set to remedy this issue. ~ahill
# NOTE: Without CLANG_DEFAULT_LINKER, clang attempts to invoke "ld" to link
#       programs, which doesn't exist on Maple Linux (at least not yet). ~ahill
# NOTE: We're using sed to remove newlines instead of dirname's own -z switch
#       because -z adds a null byte, which messes with the files generated by
#       LLVM's build process. ~ahill
# NOTE: Many build scripts still rely on the old Unix names for tools such as
#       cc and ld to function. Because of this, we enable
#       LLVM_INSTALL_BINUTILS_SYMLINKS and LLVM_INSTALL_CCTOOLS_SYMLINKS for
#       compatibility's sake. ~ahill
NATIVE_TOOL_DIR=$(dirname $(which llvm-tblgen) | sed -z "s/\n//g")
cd llvm-project-*/
cmake -S llvm -B build-llvm \
    -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
    -DCLANG_DEFAULT_LINKER=mold \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DCLANG_DEFAULT_UNWINDLIB=libunwind \
    -DCLANG_TABLEGEN=$NATIVE_TOOL_DIR/clang-tblgen \
    -DCLANG_VENDOR=Maple \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$BOOTSTRAP/root \
    -DCMAKE_TOOLCHAIN_FILE=$BOOTSTRAP/$TARGET.cmake \
    -DLLVM_ENABLE_LIBCXX=ON \
    -DLLVM_ENABLE_PROJECTS="clang;llvm" \
    -DLLVM_ENABLE_ZSTD=OFF \
    -DLLVM_HOST_TRIPLE=$TARGET \
    -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
    -DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON \
    -DLLVM_NATIVE_TOOL_DIR=$NATIVE_TOOL_DIR \
    -DLLVM_TABLEGEN=$NATIVE_TOOL_DIR/llvm-tblgen
cmake --build build-llvm --parallel $PROCS
cmake --install build-llvm --parallel $PROCS
# NOTE: LLVM doesn't add symlinks for clang, so we'll make them ourselves.
#       ~ahill
ln -s clang $BOOTSTRAP/root/bin/cc
ln -s clang++ $BOOTSTRAP/root/bin/c++
cd ..

# Build remaining software with treetap
SOURCES=(busybox make mold)
for name in $SOURCES; do
    $TREETAP fetch $SPEC/$name/$name.spec
    $TREETAP build $SPEC/$name/$name.spec
    $TREETAP package $SPEC/$name/$name.spec
    $TREETAP install $TT_DIR/packages/$MICROARCH/$name-*.cpio.xz $BOOTSTRAP/root
done

# Install Treetap
cp $TREETAP $BOOTSTRAP/root/bin/

# Prepare for chroot build
mkdir -p $BOOTSTRAP/root/maple/
cp rootbuild.sh $BOOTSTRAP/root/maple/
export TT_DIR=$BOOTSTRAP/root/maple/.treetap
SOURCES=(
    autoconf
    automake
    bsdutils
    busybox
    byacc
    bzip2
    cmake
    editline
    flex
    libarchive
    libressl
    libtool
    linux
    llvm
    m4
    make
    mold
    muon
    musl
    musl-fts
    ncurses
    perl
    pkgconf
    xz
    zlib
)
for name in $SOURCES; do
    $TREETAP fetch $SPEC/$name/$name.spec
done
cp -r $SPEC $BOOTSTRAP/root/maple/
