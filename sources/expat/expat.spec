# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="10b195ee78160a908388180a8fe3603d4e9a12f4755fbf5f3816b23a9d750da0"
SRC_NAME="expat"
SRC_URL="https://github.com/libexpat/libexpat/releases/download/R_2_8_1/expat-2.8.1.tar.xz"
SRC_VERSION="2.8.1"

build() {
    tar xJf ../$SRC_FILENAME
    cd expat-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
