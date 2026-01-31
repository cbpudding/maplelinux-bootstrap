# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e236ea3a1ccf5f6c270b1c4bb60726f371fa49459a8eaaebc90b216b328daf2b"
SRC_NAME="m4"
SRC_URL="https://linux.maple.camp/mirror/m4-1.4.20.tar.xz"
SRC_VERSION="1.4.20"

build() {
    tar xf ../$SRC_FILENAME
    cd m4-*/
    ./configure $TT_AUTOCONF_COMMON --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
