# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="7230aa671c991ab2576b9a7735b3bf6256185b0a23d3bb3fc1d44dd740a81343"
SRC_NAME="libelf"
SRC_URL="https://github.com/arachsys/libelf/archive/refs/tags/v0.195.tar.gz"
SRC_VERSION="0.195"

SRC_FILENAME="libelf-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd libelf/
    # NOTE: This version of libelf was extracted from elfutils, which means a
    #       good chunk of the project is missing. We use this version instead of
    #       elfutils since the original relies on libargp. Since Maple Linux is
    #       a musl-based system and it lacks an implementation of libargp, I
    #       chose this version. As a result, the source we are compiling is
    #       pre-configured and lacks a proper configuration script. Since our
    #       current configuration relies on libzstd, we need to manually modify
    #       the configuration to remove it as a dependency. ~ahill
    sed -i "s/-lzstd//" Makefile
    sed -i "/#define USE_ZSTD/d" src/config.h
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR INCDIR=$TT_INCLUDEDIR
}
