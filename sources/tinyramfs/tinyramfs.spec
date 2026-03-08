# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e4d4780d48c97e5b86235327c9867685d1f63d1babe6ee30e3e05d9f94b31786"
SRC_NAME="tinyramfs"
SRC_PATCHES="eea0d54594ace28cb53ffa76a70b153507d0aaacc1fcc528889ce769c36dcb70  config"
SRC_REVISION=1
SRC_URL="https://github.com/illiliti/tinyramfs/archive/refs/tags/0.3.0.tar.gz"
SRC_VERSION="0.3.0"

SRC_FILENAME="tinyramfs-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd tinyramfs-$SRC_VERSION/
    # NOTE: We need to patch init.sh to point to /bin/init by default since
    #       there is no /sbin on Maple Linux. ~ahill
    sed -i "s|init:-/sbin/init|init:-/bin/init|" lib/init.sh
    make -j $TT_PROCS install \
        BINDIR=$TT_BINDIR \
        DESTDIR=$TT_INSTALLDIR \
        MANDIR=$TT_DATADIR/man \
        LIBDIR=$TT_LIBDIR \
        PREFIX=$TT_PREFIX
    mkdir -p $TT_INSTALLDIR/usr/share/mapleconf/etc/tinyramfs
    cp ../config $TT_INSTALLDIR/usr/share/mapleconf/etc/tinyramfs/
}
