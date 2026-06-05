# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ec53eb1c3ddcfce212a3a6ab77f73966fac9d3083ba122aba57cefb9a1e819b4"
SRC_NAME="mdevd"
SRC_URL="https://git.sr.ht/~skarnet/mdevd/archive/v0.1.8.2.tar.gz"
SRC_VERSION="0.1.8.2"

SRC_FILENAME="mdevd-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd mdevd-v$SRC_VERSION/
    # NOTE: Just like with skalibs, this probably isn't autoconf. ~ahill
    ./configure --bindir=$TT_BINDIR \
        --dynlibdir=$TT_LIBDIR \
        --enable-pkgconfig \
        --includedir=$TT_INCLUDEDIR \
        --libexecdir=$TT_LIBDIR \
        --libdir=$TT_LIBDIR \
        --pkgconfdir=$TT_LIBDIR/pkgconfig \
        --prefix=$TT_PREFIX \
        --sysconfdir=$TT_CONFDIR
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
