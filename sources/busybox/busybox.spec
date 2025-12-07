# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="b8cc24c9574d809e7279c3be349795c5d5ceb6fdf19ca709f80cde50e47de314"
SRC_NAME="busybox"
SRC_PATCHES="
59d4edffe7f191fa3c8ae519ca62ea6cff77e5c9ae0945fd381570e884065975  .config
"
SRC_REVISION=3
SRC_URL="https://busybox.net/downloads/busybox-1.36.1.tar.bz2"
SRC_VERSION="1.36.1"

build() {
    tar xf ../$SRC_FILENAME
    cd busybox-$SRC_VERSION/
    cp ../.config .
    # NOTE: Like we did with musl before, we don't set CROSS_COMPILE because
    #       LLVM is smart and doesn't need a compiler to cross-compile code.
    #       With that said, Busybox uses Kbuild, which hard-codes variables like
    #       CC to GNU-based tools, which is not what we want. The following sed
    #       hack should do the trick, but I wonder if there's a better solution.
    #       ~ahill
    sed -i "s/?*= \$(CROSS_COMPILE)/?= /" Makefile
    # NOTE: Apparently, Busybox fails to properly check for ncurses since the
    #       test compiles a main function without a return value type, causing
    #       the compilation to fail. This patch fixes the issue by making the
    #       returned type "void". This doesn't actually affect the build, but
    #       I'm not sure where else to put this. ~ahill
    sed -i "s/main()/void main()/" scripts/kconfig/lxdialog/check-lxdialog.sh
    # NOTE: AR, CC, and HOSTCC are required here due to GNU dependencies. ~ahill
    make -O -j $TT_PROCS AR=ar CC=clang HOSTCC=clang
}

clean() {
    rm -rf busybox-$SRC_VERSION/
}

package() {
    cd busybox-$SRC_VERSION/
    # NOTE: Busybox doesn't have a proper DESTDIR, so we just set CONFIG_PREFIX
    #       during the install to work around this limitation. ~ahill
    # NOTE: Once again, AR, CC, and HOSTCC are set because we're using LLVM and
    #       not GCC. ~ahill
    make -O -j $TT_PROCS install AR=ar CC=clang CONFIG_PREFIX=$TT_INSTALLDIR HOSTCC=$CC
}
