# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="2649b27c0e90e632eadcd757be06c6e9a4f48d941de51e7c0f83ff76408a07b9"
SRC_NAME="grep"
SRC_URL="https://ftp.gnu.org/gnu/grep/grep-3.12.tar.xz"
SRC_VERSION="3.12"

build() {
    tar xf ../$SRC_FILENAME
    cd grep-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
}

package() {
    cd grep-$SRC_VERSION/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}