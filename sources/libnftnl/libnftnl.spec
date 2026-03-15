# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="607da28dba66fbdeccf8ef1395dded9077e8d19f2995f9a4d45a9c2f0bcffba8"
SRC_NAME="libnftnl"
SRC_URL="https://www.netfilter.org/pub/libnftnl/libnftnl-1.3.1.tar.xz"
SRC_VERSION="1.3.1"

build() {
    tar xJf ../$SRC_FILENAME
    cd libnftnl-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
