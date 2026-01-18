# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="40df79166e74aa20149365e11ee4c798a46ad57c34e4f68fd13100e2c9a91946"
SRC_NAME="curl"
SRC_URL="https://curl.se/download/curl-8.18.0.tar.xz"
SRC_VERSION="8.18.0"

build() {
    tar xf ../$SRC_FILENAME
    cd curl-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON \
        --disable-libgcc \
        --disable-static \
        --enable-optimize \
        --with-openssl \
        --without-libpsl
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}