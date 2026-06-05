# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9f384374b496110a25b73ad5a5febb384783c6e3188b37063f677ac908013fde"
SRC_NAME="nano"
SRC_URL="https://www.nano-editor.org/dist/v9/nano-9.0.tar.xz"
SRC_VERSION="9.0"

build() {
    tar xJf ../$SRC_FILENAME
    cd nano-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --enable-utf8 --enable-year2038
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
