# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="76f0dcb248f2e2f1251d4ecd20fd30fb400a360a3a37c6c340e0a52c2d1cdedf"
SRC_NAME="nano"
SRC_URL="https://www.nano-editor.org/dist/v8/nano-8.7.1.tar.xz"
SRC_VERSION="8.7.1"

build() {
    tar xJf ../$SRC_FILENAME
    cd nano-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --enable-utf8 --enable-year2038
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
