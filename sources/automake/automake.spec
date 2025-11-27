# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="168aa363278351b89af56684448f525a5bce5079d0b6842bd910fdd3f1646887"
SRC_NAME="automake"
SRC_URL="https://ftp.gnu.org/gnu/automake/automake-1.18.1.tar.xz"
SRC_VERSION="1.18.1"

build() {
    tar xf ../$SRC_FILENAME
    cd automake-*/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
}

clean() {
    rm -rf automake-*/
}

package() {
    cd automake-*/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}