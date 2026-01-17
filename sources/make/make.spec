# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3"
SRC_NAME="make"
SRC_URL="https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
SRC_VERSION="4.4.1"

build() {
    tar xf ../$SRC_FILENAME
    cd make-*/
    ./configure $TT_AUTOCONF_COMMON --enable-year2038
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}