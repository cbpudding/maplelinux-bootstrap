# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995"
SRC_NAME="flex"
SRC_URL="https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
SRC_VERSION="2.6.4"

build() {
    tar xf ../$SRC_FILENAME
    cd flex-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}