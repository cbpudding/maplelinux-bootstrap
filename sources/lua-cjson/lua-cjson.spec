# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9e1fd46eced543b149f2b08703b0c0165619524f92d350a453e8c11e4fd089b0"
SRC_NAME="lua-cjson"
SRC_URL="https://github.com/openresty/lua-cjson/archive/refs/tags/2.1.0.9.tar.gz"
SRC_VERSION="2.1.0.9"

SRC_FILENAME="lua-cjson-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
    cd lua-cjson-$SRC_VERSION/
    make -j $TT_PROCS
    mkdir -p $TT_INSTALLDIR$TT_LIBDIR/lua/5.5
    cp cjson.so $TT_INSTALLDIR$TT_LIBDIR/lua/5.5/
}
