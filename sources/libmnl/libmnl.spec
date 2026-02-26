# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="274b9b919ef3152bfb3da3a13c950dd60d6e2bcd54230ffeca298d03b40d0525"
SRC_NAME="libmnl"
SRC_URL="https://www.netfilter.org/pub/libmnl/libmnl-1.0.5.tar.bz2"
SRC_VERSION="1.0.5"

build() {
    tar xjf ../$SRC_FILENAME
    cd libmnl-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --enable-static
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
