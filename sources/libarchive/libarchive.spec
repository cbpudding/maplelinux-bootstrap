# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="d68068e74beee3a0ec0dd04aee9037d5757fcc651591a6dcf1b6d542fb15a703"
SRC_NAME="libarchive"
SRC_URL="https://libarchive.org/downloads/libarchive-3.8.5.tar.xz"
SRC_VERSION="3.8.5"

build() {
    tar xf ../$SRC_FILENAME
    cd libarchive-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
