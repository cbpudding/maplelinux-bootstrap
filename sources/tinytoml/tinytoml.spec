# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="b806637ce2f79f80cc7a1920a13ba3fe8e6ed51202bcf54f90738d0ce808b201"
SRC_NAME="tinytoml"
SRC_URL="https://github.com/FourierTransformer/tinytoml/archive/refs/tags/1.0.0.tar.gz"
SRC_VERSION="1.0.0"

SRC_FILENAME="tinytoml-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
    cd tinytoml-$SRC_VERSION/
    mkdir -p $TT_INSTALLDIR$TT_DATADIR/lua/5.5
    cp tinytoml.lua $TT_INSTALLDIR$TT_DATADIR/lua/5.5/
}
