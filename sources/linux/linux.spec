# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="d0a78bf3f0d12aaa10af3b5adcaed5bc767b5b78705e5ef885d5e930b72e25d5"
SRC_NAME="linux"
SRC_PATCHES="
5a0616535b4c04d99a3db3e8ea528e6e658fd12b11161f9dcf56f5c21a3b0e62  linux-mold.patch
"
SRC_REVISION=1
SRC_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.1.tar.xz"
SRC_VERSION="6.18.1"

build() {
    tar xf ../$SRC_FILENAME
    cd linux-$SRC_VERSION/
    # NOTE: Linux doesn't officially support mold, so we have to patch a couple
    #       of scripts to allow the kernel to build. ~ahill
    patch -p1 < ../linux-mold.patch
    # NOTE: LLVM=1 is required for ALL invocations of the kernel's Makefile. GNU
    #       tools are still used by default in a lot of places and this will
    #       override them with LLVM tools wherever possible. ~ahill
    LLVM=1 make mrproper
    # NOTE: YACC defaults to bison, which doesn't exist here, so we tell it
    #       where to find the parser generator manually. ~ahill
    # NOTE: Similarly, since we aren't using LLVM's linker, we tell it to use
    #       mold manually. ~ahill
    LLVM=1 make -j $TT_PROCS defconfig LD=mold YACC=byacc
    LLVM=1 make -j $TT_PROCS HOSTLD=mold LD=mold YACC=byacc
}

clean() {
    rm -rf libelf-$SRC_VERSION/
}
