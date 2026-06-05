# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="cba4bb7a44edf2877bb6f059932896383babe435b3a8c3b5df48b4aa41c9bb85"
SRC_NAME="cmake"
SRC_URL="https://github.com/Kitware/CMake/releases/download/v4.3.3/cmake-4.3.3.tar.gz"
SRC_VERSION="4.3.3"

build() {
    tar xzf ../$SRC_FILENAME
    cd cmake-*/
    # NOTE: CMake's bootstrap script is autoconf-like, but we shouldn't use
    #       TT_AUTOCONF_COMMON here because it would be incompatible. ~ahill
    ./bootstrap \
        --bindir=$TT_BINDIR \
        --datadir=$TT_DATADIR/cmake-$(echo $SRC_VERSION | cut -d"." -f1,2) \
        --docdir=$TT_DATADIR/doc/cmake-$(echo $SRC_VERSION | cut -d"." -f1,2) \
        --mandir=$TT_DATADIR/man \
        --parallel=$TT_PROCS \
        --prefix=$TT_PREFIX \
        --system-bzip2 \
        --system-libarchive \
        --system-liblzma \
        --system-zlib \
        --xdgdatadir=$TT_DATADIR
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
