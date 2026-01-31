# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="19bcb6ca867183c57d77155eae946c5eced88183143b45ca51ad7d26c628ca75"
SRC_NAME="coreutils"
SRC_URL="https://linux.maple.camp/mirror/coreutils-9.9.tar.xz"
SRC_VERSION="9.9"

build() {
    tar xf ../$SRC_FILENAME
    cd coreutils-*/
    ./configure $TT_AUTOCONF_COMMON --disable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
