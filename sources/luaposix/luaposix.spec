# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="82cd9a96c41a4a3205c050206f0564ff4456f773a8f9ffc9235ff8f1907ca5e6"
SRC_NAME="luaposix"
SRC_URL="https://github.com/luaposix/luaposix/archive/refs/tags/v36.3.tar.gz"
SRC_VERSION="36.3"

SRC_FILENAME="luaposix-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
    cd luaposix-$SRC_VERSION/
    ./build-aux/luke
    ./build-aux/luke install PREFIX=$TT_INSTALLDIR
    # NOTE: I may be wrong since I've never used it before, but it seems that
    #       "luke" doesn't install the library to the correct path, nor does it
    #       have an option to correct it. ~ahill
    mkdir -p $TT_INSTALLDIR/usr
    mv $TT_INSTALLDIR/share $TT_INSTALLDIR/usr/
}
