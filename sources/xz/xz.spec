# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ce09c50a5962786b83e5da389c90dd2c15ecd0980a258dd01f70f9e7ce58a8f1"
SRC_NAME="xz"
SRC_URL="https://github.com/tukaani-project/xz/releases/download/v5.8.2/xz-5.8.2.tar.gz"
SRC_VERSION="5.8.2"

# NOTE: It is important that the source tarball should remain gzip-compressed
#       rather than xz-compressed, because we are unable to extract
#       xz-compressed archives until this software is built. ~ahill

build() {
    tar xf ../$SRC_FILENAME
    cd xz-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -O -j $TT_PROCS
}

clean() {
    rm -rf xz-*/
}

package() {
    cd xz-*/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
