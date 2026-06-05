# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="856e742e331bb53176231e1eae3588ab044e5564c811df3138bd2f1c7b953682"
SRC_NAME="libcap2"
SRC_URL="https://git.kernel.org/pub/scm/libs/libcap/libcap.git/snapshot/libcap-2.78.tar.gz"
SRC_VERSION="2.78"

build() {
    tar xzf ../$SRC_FILENAME
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
