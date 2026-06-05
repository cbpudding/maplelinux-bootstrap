# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="833a816906d7b94ca766c8730e33ea3315edd2c105bcee0fae279bb1298067a4"
SRC_NAME="skalibs"
SRC_URL="https://git.sr.ht/~skarnet/skalibs/archive/v2.15.0.0.tar.gz"
SRC_VERSION="2.15.0.0"

SRC_FILENAME="skalibs-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd skalibs-v$SRC_VERSION/
    # NOTE: This is another autoconf-like configure script, but it probably
    #       isn't safe to use TT_AUTOCONF_COMMON here. ~ahill
    ./configure \
        --disable-shared \
        --dynlibdir=$TT_LIBDIR \
        --enable-pkgconfig \
        --includedir=$TT_INCLUDEDIR \
        --libdir=$TT_LIBDIR \
        --pkgconfdir=$TT_LIBDIR/pkgconfig \
        --prefix=$TT_PREFIX \
        --sysconfdir=$TT_CONFDIR
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
