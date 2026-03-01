# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e79bbcd8ff3ed0200e7ac55d3962a15e118c1229990213025f2fc8b264727570"
SRC_NAME="groff"
SRC_URL="https://ftp.gnu.org/gnu/groff/groff-1.24.0.tar.gz"
SRC_VERSION="1.24.0"

build() {
    tar xzf ../$SRC_FILENAME
    cd groff-*/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
