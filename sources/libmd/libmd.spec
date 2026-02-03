# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="1bd6aa42275313af3141c7cf2e5b964e8b1fd488025caf2f971f43b00776b332"
SRC_NAME="libmd"
SRC_URL="https://libbsd.freedesktop.org/releases/libmd-1.1.0.tar.xz"
SRC_VERSION="1.1.0"

build() {
    tar xf ../$SRC_FILENAME
    cd libmd-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
