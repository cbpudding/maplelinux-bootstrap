# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="1e7c9639f279794f14a16ffd47b95a1020a2c19bf4dfc611c68197055da07b23"
SRC_NAME="liquid-lua"
SRC_URL="https://github.com/3scale/liquid-lua/archive/refs/tags/v0.2.0.tar.gz"
SRC_VERSION="0.2.0"

SRC_FILENAME="liquid-lua-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
    cd liquid-lua-$SRC_VERSION/
    mkdir -p $TT_INSTALLDIR$TT_DATADIR/lua/5.5
    cp lib/liquid.lua $TT_INSTALLDIR$TT_DATADIR/lua/5.5/
}
