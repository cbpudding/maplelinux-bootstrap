# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="baf5bcbe7b04042d84fb47035aaf3312800c6d36a65fc411a3f74aba1c48c3c6"
SRC_NAME="limine"
SRC_URL="https://github.com/limine-bootloader/limine/releases/download/v10.6.3/limine-10.6.3.tar.xz"
SRC_VERSION="10.6.3"

build() {
    tar xf ../$SRC_FILENAME
    cd limine-$SRC_VERSION/
    # TODO: How should other architectures be handled? ~ahill
    ./configure $TT_AUTOCONF_COMMON --enable-uefi-x86-64
    make -O -j $TT_PROCS
}

package() {
    cd limine-$SRC_VERSION/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
