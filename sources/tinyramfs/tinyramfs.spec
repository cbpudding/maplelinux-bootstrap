# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e4d4780d48c97e5b86235327c9867685d1f63d1babe6ee30e3e05d9f94b31786"
SRC_NAME="tinyramfs"
SRC_PATCHES="
4750b92e3d8014cd4b04d54a950812b4632f64d79f40fd4627856efbcd386020  config
"
SRC_URL="https://github.com/illiliti/tinyramfs/archive/refs/tags/0.3.0.tar.gz"
SRC_VERSION="0.3.0"

SRC_FILENAME="tinyramfs-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
    cd tinyramfs-$SRC_VERSION/
    make -j $TT_PROCS install \
        BINDIR=$TT_BINDIR \
        DESTDIR=$TT_INSTALLDIR \
        MANDIR=$TT_DATADIR/man \
        LIBDIR=$TT_LIBDIR \
        PREFIX=$TT_PREFIX
    mkdir -p $TT_INSTALLDIR/usr/share/mapleconf/etc/tinyramfs
    cp ../config $TT_INSTALLDIR/usr/share/mapleconf/etc/tinyramfs/
}
