# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="510062d471fc9c4cd87b367a7b879c7a5f2af70513d97708842d097614d96188"
SRC_NAME="lua-cjson"
SRC_URL="https://github.com/openresty/lua-cjson/archive/refs/tags/2.1.0.17.tar.gz"
SRC_VERSION="2.1.0.17"

SRC_FILENAME="lua-cjson-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd lua-cjson/
    make -j $TT_PROCS
    mkdir -p $TT_INSTALLDIR$TT_LIBDIR/lua/5.5
    cp cjson.so $TT_INSTALLDIR$TT_LIBDIR/lua/5.5/
}
