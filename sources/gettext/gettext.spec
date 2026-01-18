# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="39acf4b0371e9b110b60005562aace5b3631fed9b1bb9ecccfc7f56e58bb1d7f"
SRC_NAME="gettext"
SRC_URL="https://ftp.gnu.org/pub/gnu/gettext/gettext-0.26.tar.gz"
SRC_VERSION="0.26"

build() {
    tar xf ../$SRC_FILENAME
    cd gettext-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}