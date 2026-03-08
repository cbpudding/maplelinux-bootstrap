# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9e9cabb457c1e09de91db2706d8365645792638eb3be1f94dbb2149301086ac0"
SRC_NAME="expat"
SRC_URL="https://github.com/libexpat/libexpat/releases/download/R_2_7_4/expat-2.7.4.tar.xz"
SRC_VERSION="2.7.4"

build() {
    tar xJf ../$SRC_FILENAME
    cd expat-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
