# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181"
SRC_NAME="sed"
SRC_URL="https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz"
SRC_VERSION="4.9"

build() {
    tar xf ../$SRC_FILENAME
    cd sed-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
}

package() {
    cd sed-$SRC_VERSION/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}