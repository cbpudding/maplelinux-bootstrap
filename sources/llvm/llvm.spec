# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="25d2e2adc4356d758405dd885fcfd6447bce82a90eb78b6b87ce0934bd077173"
SRC_NAME="llvm"
SRC_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.0/llvm-project-22.1.0.src.tar.xz"
SRC_VERSION="22.1.0"

# TODO: Figure out why libunwind installs headers at /include
# TODO: Figure out why libc++ installs headers at /include
# TODO: Fix data directory for libclc (/share/clc -> /usr/share/clc)
# TODO: Fix pkgconfig directory for libclc (/share/pkgconfig -> /lib/pkgconfig)
# TODO: Fix data directory for libc++ (/share/libc++ -> /usr/share/libc++)
# TODO: Should /lib/cmake be moved to /usr/share?
# TODO: Should /lib/$TT_TARGET simply be a symlink to /lib?
# TODO: Should /usr/include/$TT_TARGET simply be a symlink to /usr/include?

build() {
    tar xJf ../$SRC_FILENAME
    cd llvm-project-$SRC_VERSION.src/
    # NOTE: compiler-rt fails to build on musl because execinfo.h is missing.
    #       Disabling COMPILER_RT_BUILD_GWP_ASAN works. ~ahill
    # NOTE: LLVM_ENABLE_ZSTD is disabled because we don't have zstd in the
    #       sysroot, and because I don't believe that a library created by
    #       Facebook should be required for an operating system to function.
    #       ~ahill
    # NOTE: Many build scripts still rely on the old Unix names for tools such
    #       as cc and ld to function. Because of this, we enable
    #       LLVM_INSTALL_BINUTILS_SYMLINKS and LLVM_INSTALL_CCTOOLS_SYMLINKS for
    #       compatibility's sake. ~ahill
    # NOTE: LLVM uses the GNUInstallDirs module to determine where to write
    #       files. ~ahill
    # See also: https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html
    cmake -B build -S llvm \
        -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
        -DCLANG_DEFAULT_LINKER=lld \
        -DCLANG_DEFAULT_RTLIB=compiler-rt \
        -DCLANG_DEFAULT_UNWINDLIB=libunwind \
        -DCLANG_VENDOR=Maple \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_DATAROOTDIR=$(echo $TT_DATADIR | cut -c 2-) \
        -DCMAKE_INSTALL_INCLUDEDIR=$(echo $TT_INCLUDEDIR | cut -c 2-) \
        -DCMAKE_INSTALL_LIBEXECDIR=$(echo $TT_LIBDIR | cut -c 2-) \
        -DCMAKE_INSTALL_PREFIX=$TT_INSTALLDIR \
        -DCMAKE_INSTALL_RUNSTATEDIR=$(echo $TT_RUNDIR | cut -c 2-) \
        -DCMAKE_INSTALL_SBINDIR=$(echo $TT_BINDIR | cut -c 2-) \
        -DCOMPILER_RT_BUILD_GWP_ASAN=OFF \
        -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON \
        -DLIBCXX_CXX_ABI=libcxxabi \
        -DLIBCXX_HAS_MUSL_LIBC=ON \
        -DLIBCXX_USE_COMPILER_RT=ON \
        -DLIBCXXABI_USE_COMPILER_RT=ON \
        -DLIBCXXABI_USE_LLVM_UNWINDER=ON \
        -DLIBUNWIND_USE_COMPILER_RT=ON \
        -DLLVM_ENABLE_PROJECTS="clang;lld;llvm" \
        -DLLVM_ENABLE_RTTI=ON \
        -DLLVM_ENABLE_RUNTIMES="compiler-rt;libclc;libcxx;libcxxabi;libunwind" \
        -DLLVM_ENABLE_ZSTD=OFF \
        -DLLVM_HOST_TRIPLE=$TT_TARGET \
        -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
        -DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON
    cmake --build build --parallel $TT_PROCS
    # NOTE: From what I can tell, LLVM believes that it is cross-compiling, so
    #       it creates a /lib/$TT_TARGET directory, which prevents libc++ and
    #       libunwind from being found. The workaround is to symlink that
    #       directory to /lib, but there should be a better way to do this.
    #       ~ahill
    mkdir -p $TT_INSTALLDIR/lib
    ln -sf . $TT_INSTALLDIR/lib/$TT_TARGET
    cmake --install build --parallel $TT_PROCS
    # NOTE: LLVM doesn't add symlinks for clang or ld.lld, so I'll make them
    #       myself. ~ahill
    ln -sf clang $TT_INSTALLDIR/bin/cc
    ln -sf clang++ $TT_INSTALLDIR/bin/c++
    ln -sf ld.lld $TT_INSTALLDIR/bin/ld
    # NOTE: Finally, LLVM really doesn't play nice with its own rules. If I tell
    #       it to install in a certain directory, it *might* listen to me. This
    #       takes care of all the stuff it didn't install correctly. ~ahill
    mv $TT_INSTALLDIR/include/* $TT_INSTALLDIR/usr/include/
    rm -rf $TT_INSTALLDIR/include
    mv $TT_INSTALLDIR/share/* $TT_INSTALLDIR/usr/share/
    rm -rf $TT_INSTALLDIR/share
}
