# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="4d62ff37342ec7aed748535323930c7cf94acf71c3591882b26a7ea50f3edc16"
SRC_NAME="tar"
SRC_URL="https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz"
SRC_VERSION="1.35"

build() {
    tar xf ../$SRC_FILENAME
    cd tar-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
}

package() {
    cd tar-$SRC_VERSION/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}