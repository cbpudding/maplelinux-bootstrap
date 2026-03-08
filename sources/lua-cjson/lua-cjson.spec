# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="52967ea2bcb598fd8729517ff1f8124c63c357f76e3c0575b34ca1f663a87a85"
SRC_NAME="lua-cjson"
SRC_URL="https://linux.maple.camp/git/mirror/lua-cjson/archive/2.1.0.16.tar.gz"
SRC_VERSION="2.1.0.16"

SRC_FILENAME="lua-cjson-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd lua-cjson/
    make -j $TT_PROCS
    mkdir -p $TT_INSTALLDIR$TT_LIBDIR/lua/5.5
    cp cjson.so $TT_INSTALLDIR$TT_LIBDIR/lua/5.5/
}
