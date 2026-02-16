# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="d1bd938a53653fa593291a1519f58ddf874d29c4af08a22a817c8b305d7f69a2"
SRC_NAME="limine"
SRC_URL="https://codeberg.org/Limine/Limine/releases/download/v10.7.0/limine-10.7.0.tar.xz"
SRC_VERSION="10.7.0"

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
