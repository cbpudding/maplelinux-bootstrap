# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="c7b847b57feacf5e182f4d14dd6cae545ac6843d55cb725f58e107cdf1c9ad73"
SRC_NAME="libarchive"
SRC_URL="https://libarchive.org/downloads/libarchive-3.8.4.tar.xz"
SRC_VERSION="3.8.4"

build() {
    tar xf ../$SRC_FILENAME
    cd libarchive-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -j $TT_PROCS
}

clean() {
    rm -rf libarchive-*/
}

package() {
    cd libarchive-*/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
