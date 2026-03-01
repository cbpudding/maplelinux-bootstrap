# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="6dc65251eaf7d0ecf41d9f58af01fc2fe0e01b329b035bc4e60f799fd388f8f8"
SRC_NAME="limine"
SRC_URL="https://codeberg.org/Limine/Limine/releases/download/v10.8.2/limine-10.8.2.tar.xz"
SRC_VERSION="10.8.2"

SRC_PATCHES="
e52e11abaded936c126247c02e6a0c66c8017a94c9df49a30832206d7094b5fb  limine.conf
"

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
