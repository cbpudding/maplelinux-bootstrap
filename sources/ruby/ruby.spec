# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="23815a6d095696f7919090fdc3e2f9459b2c83d57224b2e446ce1f5f7333ef36"
SRC_NAME="ruby"
SRC_URL="https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.7.tar.gz"
SRC_VERSION="3.4.7"

build() {
    tar xf ../$SRC_FILENAME
    cd ruby-*/
    ./autogen.sh
    ./configure $TT_AUTOCONF_COMMON \
        --disable-install-static-library \
        --enable-shared \
        --enable-year2038 \
        --with-destdir=$TT_INSTALLDIR \
        --without-gcc
    make -O -j $TT_PROCS
}

clean() {
    rm -rf ruby-*/
}

package() {
    cd ruby-*/
    make -O -j $TT_PROCS install
}
