# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="90e21f2b89f19391ce7b90f6e48ed9fde5394d23ad30ae256fb8236b38b99788"
SRC_NAME="libarchive"
SRC_URL="https://www.libarchive.org/downloads/libarchive-3.8.3.tar.xz"
SRC_VERSION="3.8.3"

build() {
    tar xf ../$SRC_FILENAME
    cd libarchive-*/
    # NOTE: bsdtar is disabled here because Busybox's implementation is complete
    #       enough to be useful and bootstrapping libarchive is a pain. ~ahill
    ./configure $TT_AUTOCONF_COMMON \
        --disable-bsdtar \
        --disable-static \
        --enable-year2038
    make -j $TT_PROCS
}

clean() {
    rm -rf libarchive-*/
}

package() {
    cd libarchive-*/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}