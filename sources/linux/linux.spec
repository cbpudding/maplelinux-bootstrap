# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f850139ca5f79c1bf6bb8b32f92e212aadca97bdaef8a83a7cf4ac4d6a525fab"
SRC_NAME="linux"
SRC_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.4.tar.xz"
SRC_VERSION="6.18.4"

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

package() {
    cd linux-$SRC_VERSION/
    make -j $TT_PROCS install INSTALL_PATH=$TT_INSTALLDIR/boot
    make -j $TT_PROCS modules_install INSTALL_MOD_PATH=$TT_INSTALLDIR
    # TODO: Run dtbs_install on non-x86 systems ~ahill
}
