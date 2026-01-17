# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="afd287aa672c48b8e1a93fdb6c6588453d527510d966822b687f2835f0d986e9"
SRC_NAME="nano"
SRC_URL="https://www.nano-editor.org/dist/v8/nano-8.7.tar.xz"
SRC_VERSION="8.7"

build() {
    tar xf ../$SRC_FILENAME
    cd nano-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --enable-utf8 --enable-year2038
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}