# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="5e339f5ab434bf5b7979f65437ca24942ddcd6e6a3e57347370cd791bc0ea51c"
SRC_NAME="libcap2"
SRC_URL="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/libcap-2.77.tar.gz"
SRC_VERSION="2.77"

build() {
    tar xf ../$SRC_FILENAME
    cd libcap-$SRC_VERSION/
    # NOTE: This Makefile assumes that GCC exists, which it doesn't here, so we
    #       need to tell it to respect the CC environment variable to prevent
    #       any issues. ~ahill
    make -O \
        -j $TT_PROCS \
        CC=$CC \
        LIBDIR=$TT_LIBDIR \
        INCDIR=$TT_INCLUDEDIR \
        exec_prefix=$TT_PREFIX \
        prefix=$TT_PREFIX
}

package() {
    cd libcap-$SRC_VERSION/
    make -O \
        -C libcap \
        -j $TT_PROCS \
        install-shared \
        FAKEROOT=$TT_INSTALLDIR \
        LIBDIR=$TT_LIBDIR \
        INCDIR=$TT_INCLUDEDIR \
        exec_prefix=$TT_PREFIX \
        prefix=$TT_PREFIX
}
