# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="558c6bbab749492b34f99827fe807b0039a744693c21d3a7e03b3a48edaab96a"
SRC_NAME="linux"
SRC_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.2.tar.xz"
SRC_VERSION="6.18.2"

build() {
    tar xf ../$SRC_FILENAME
    cd linux-$SRC_VERSION/
    # NOTE: LLVM=1 is required for ALL invocations of the kernel's Makefile. GNU
    #       tools are still used by default in a lot of places and this will
    #       override them with LLVM tools wherever possible. ~ahill
    LLVM=1 make mrproper
    # NOTE: YACC defaults to bison, which doesn't exist here, so we tell it
    #       where to find the parser generator manually. ~ahill
    LLVM=1 make -j $TT_PROCS defconfig YACC=byacc
    LLVM=1 make -j $TT_PROCS YACC=byacc
}

clean() {
    rm -rf libelf-$SRC_VERSION/
}
