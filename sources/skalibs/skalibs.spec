# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="abfc5626fd0bf7bff71e9d926ef9eb36cd3e0f953047411dbe8d63ba642b42d7"
SRC_NAME="skalibs"
SRC_URL="https://git.sr.ht/~skarnet/skalibs/archive/v2.14.5.1.tar.gz"
SRC_VERSION="2.14.5.1"

SRC_FILENAME="skalibs-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
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
