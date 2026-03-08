# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="edf0be66bddb0570694ba96cf224ebbd47342581135894fc76895034fff0780e"
SRC_NAME="limine"
SRC_URL="https://codeberg.org/Limine/Limine/releases/download/v10.8.3/limine-10.8.3.tar.xz"
SRC_VERSION="10.8.3"

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
