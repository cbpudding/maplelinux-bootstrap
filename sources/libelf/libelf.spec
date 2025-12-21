# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="libelf-0.193.tar.gz"
SRC_HASH="6253395679c2bb2156d926b3d8b7e3b2bbeb40a56d2bea29e1c73e40ed9de4ba"
SRC_NAME="libelf"
SRC_URL="https://github.com/arachsys/libelf/archive/refs/tags/v0.193.tar.gz"
SRC_VERSION="0.193"

build() {
    tar xf ../$SRC_FILENAME
    cd libelf-$SRC_VERSION/
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
}

clean() {
    rm -rf libelf-$SRC_VERSION/
}

package() {
    cd libelf-$SRC_VERSION/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR INCDIR=/usr/include
}
