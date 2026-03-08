# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ac4c3f3cd01637a7196f68fb0b5b07ac0653312fe3da0e24130ebb5610b37f3b"
SRC_NAME="libelf"
SRC_URL="https://linux.maple.camp/git/mirror/libelf/archive/v0.194.tar.gz"
SRC_VERSION="0.194"

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
