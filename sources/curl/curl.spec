# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="63fe2dc148ba0ceae89922ef838f7e5c946272c2e78b7c59fab4b79d3ce2b896"
SRC_NAME="curl"
SRC_URL="https://curl.se/download/curl-8.20.0.tar.xz"
SRC_VERSION="8.20.0"

build() {
    tar xJf ../$SRC_FILENAME
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
