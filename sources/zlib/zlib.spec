# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32"
SRC_NAME="zlib"
SRC_URL="https://www.zlib.net/zlib-1.3.1.tar.xz"
SRC_VERSION="1.3.1"

build() {
    tar xf ../$SRC_FILENAME
    cd zlib-*/
    # NOTE: The prefix is set to /usr because man pages are stored under the
    #       prefix whether you like it or not. ~ahill
    ./configure \
        --eprefix=$TT_PREFIX \
        --includedir=$TT_INCLUDEDIR \
        --libdir=$TT_LIBDIR \
        --prefix=/usr \
        --shared
    make -O -j $TT_PROCS
}

clean() {
    rm -rf zlib-*/
}

package() {
    cd zlib-*/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}