# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="3d3a1b973af218114f4f889bbaa2f4c037deaae0c8e815eec381c3d546b974a0"
SRC_NAME="xz"
SRC_URL="https://github.com/tukaani-project/xz/releases/download/v5.8.3/xz-5.8.3.tar.gz"
SRC_VERSION="5.8.3"

# NOTE: It is important that the source tarball should remain gzip-compressed
#       rather than xz-compressed, because we are unable to extract
#       xz-compressed archives until this software is built. ~ahill

build() {
    tar xzf ../$SRC_FILENAME
    cd xz-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -O -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
