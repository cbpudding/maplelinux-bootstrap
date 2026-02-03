# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="2c6a21fbc30191c94a40549cb8dda2623c3a4457ae92370b0e6be827ea6845b0"
SRC_NAME="lua-date"
SRC_URL="https://github.com/Tieske/date/archive/refs/tags/version_2.2.1.tar.gz"
SRC_VERSION="2.2.1"

SRC_FILENAME="lua-date-$SRC_VERSION.tar.gz"

# TODO: What is the best way to include documentation? ~ahill

build() {
    tar xf ../$SRC_FILENAME
    cd date-version_$SRC_VERSION/
    mkdir -p $TT_INSTALLDIR$TT_DATADIR/lua/5.5
    cp src/date.lua $TT_INSTALLDIR$TT_DATADIR/lua/5.5/
}
