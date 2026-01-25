# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f3a3082a23b37c293a4fcd1053147b371f2ff91fa7ea1b2a52e335676bac82dc"
SRC_NAME="libffi"
SRC_URL="https://github.com/libffi/libffi/releases/download/v3.5.2/libffi-3.5.2.tar.gz"
SRC_VERSION="3.5.2"

build() {
    tar xf ../$SRC_FILENAME
    cd libffi-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}