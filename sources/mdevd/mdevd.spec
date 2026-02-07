# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="44d3e0bc3d9b0cbcb3bdd3722dbe0d41d6ed1a30f62b87d4e01eb0649f2e8421"
SRC_NAME="mdevd"
SRC_URL="https://git.sr.ht/~skarnet/mdevd/archive/v0.1.8.1.tar.gz"
SRC_VERSION="0.1.8.1"

SRC_FILENAME="mdevd-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
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
