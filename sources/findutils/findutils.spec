# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="1387e0b67ff247d2abde998f90dfbf70c1491391a59ddfecb8ae698789f0a4f5"
SRC_NAME="findutils"
SRC_URL="https://linux.maple.camp/mirror/findutils-4.10.0.tar.xz"
SRC_VERSION="4.10.0"

build() {
    tar xf ../$SRC_FILENAME
    cd findutils-*/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
