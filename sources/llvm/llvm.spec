# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="4633a23617fa31a3ea51242586ea7fb1da7140e426bd62fc164261fe036aa142"
SRC_NAME="llvm"
SRC_PATCHES="
1e52d86c422498ed5d926ad90e0787e79b8a02cb33cc916b1897c2a6ebfef9fc  rtsan-127764.patch
"
SRC_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.8/llvm-project-21.1.8.src.tar.xz"
SRC_VERSION="21.1.8"

build() {
    tar xf ../$SRC_FILENAME
    cd llvm-project-$SRC_VERSION.src/
    # NOTE: This version of LLVM has an issue where compiler-rt attempts to use
    #       a header before it is has been built. This patch fixes it. ~ahill
    # See also: https://github.com/llvm/llvm-project/issues/127764
    patch -p1 < ../rtsan-127764.patch
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
    cmake -B build -S llvm \
        -DCLANG_DEFAULT_CXX_STDLIB=libc++ \
        -DCLANG_DEFAULT_LINKER=lld \
        -DCLANG_DEFAULT_RTLIB=compiler-rt \
        -DCLANG_DEFAULT_UNWINDLIB=libunwind \
        -DCLANG_VENDOR=Maple \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_DOCDIR=usr/share/doc \
        -DCMAKE_INSTALL_INCLUDEDIR=$(echo $TT_INCLUDEDIR | cut -c 2-) \
        -DCMAKE_INSTALL_LIBEXECDIR=$(echo $TT_LIBDIR | cut -c 2-) \
        -DCMAKE_INSTALL_MANDIR=usr/share/man \
        -DCMAKE_INSTALL_PREFIX=$TT_INSTALLDIR \
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
    cmake --install build --parallel $TT_PROCS
    # NOTE: LLVM doesn't add symlinks for clang or ld.lld, so I'll make them
    #       myself. ~ahill
    ln -sf clang $TT_INSTALLDIR/bin/cc
    ln -sf clang++ $TT_INSTALLDIR/bin/c++
    ln -sf ld.lld $TT_INSTALLDIR/bin/ld
}
