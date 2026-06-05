# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="952d0f76cef83670a84ba03e05c61a9e18b1a6499d7b476bf8cc27d6d0ab5e88"
SRC_NAME="limine"
SRC_URL="https://github.com/Limine-Bootloader/Limine/releases/download/v12.3.2/limine-12.3.2.tar.xz"
SRC_VERSION="12.3.2"

SRC_PATCHES="e52e11abaded936c126247c02e6a0c66c8017a94c9df49a30832206d7094b5fb  limine.conf"

build() {
    mkdir -p $TT_INSTALLDIR$TT_DATADIR/mapleconf/boot
    cp limine.conf $TT_INSTALLDIR$TT_DATADIR/mapleconf/boot/
    tar xJf ../$SRC_FILENAME
    cd limine-$SRC_VERSION/
    # TODO: How should other architectures be handled? ~ahill
    ./configure $TT_AUTOCONF_COMMON --enable-uefi-x86-64
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
