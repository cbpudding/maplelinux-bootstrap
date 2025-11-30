# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="4104e94657d247c811cb29985405a360b78130b5d51e7f6daceb2447830bd579"
SRC_NAME="cmake"
SRC_URL="https://github.com/Kitware/CMake/releases/download/v4.2.0/cmake-4.2.0.tar.gz"
SRC_VERSION="4.2.0r1"

build() {
    tar xf ../$SRC_FILENAME
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
}

clean() {
    rm -rf cmake-*/
}

package() {
    cd cmake-*/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
