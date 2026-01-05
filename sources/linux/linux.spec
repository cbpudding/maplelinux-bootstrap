# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="7a8879167b89c4bae077d6f39c4f2130769f05dbdad2aad914adab9afb7d7f9a"
SRC_NAME="linux"
SRC_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.3.tar.xz"
SRC_VERSION="6.18.3"

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
