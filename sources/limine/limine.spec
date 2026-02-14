# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="4ec91681c4b0ade967138561ae8da5aa5bff83dd3b6be2e9fb7501eb9162e0ee"
SRC_NAME="limine"
SRC_REVISION=1
SRC_URL="https://github.com/limine-bootloader/limine/releases/download/v10.6.4/limine-10.6.4.tar.xz"
SRC_VERSION="10.6.4"

SRC_PATCHES="
e52e11abaded936c126247c02e6a0c66c8017a94c9df49a30832206d7094b5fb  limine.conf
"

build() {
    mkdir -p $TT_INSTALLDIR$TT_DATADIR/mapleconf/boot
    cp limine.conf $TT_INSTALLDIR$TT_DATADIR/mapleconf/boot/
    tar xf ../$SRC_FILENAME
    cd limine-$SRC_VERSION/
    # TODO: How should other architectures be handled? ~ahill
    ./configure $TT_AUTOCONF_COMMON --enable-uefi-x86-64
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
