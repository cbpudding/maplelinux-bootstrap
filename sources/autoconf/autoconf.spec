# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ba885c1319578d6c94d46e9b0dceb4014caafe2490e437a0dbca3f270a223f5a"
SRC_NAME="autoconf"
SRC_URL="https://linux.maple.camp/mirror/autoconf-2.72.tar.xz"
SRC_VERSION="2.72"

build() {
    tar xf ../$SRC_FILENAME
    cd autoconf-*/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
