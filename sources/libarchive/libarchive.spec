# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="d3a8ba457ae25c27c84fd2830a2efdcc5b1d40bf585d4eb0d35f47e99e5d4774"
SRC_NAME="libarchive"
SRC_URL="https://libarchive.org/downloads/libarchive-3.8.7.tar.xz"
SRC_VERSION="3.8.7"

build() {
    tar xf ../$SRC_FILENAME
    cd libarchive-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
