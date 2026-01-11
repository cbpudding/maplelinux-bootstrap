# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="51bcb82d577b141d896d9d9c3077d7aaa209490132e9f2b9573ba8511b3835be"
SRC_NAME="mawk"
SRC_REVISION=1
SRC_URL="https://invisible-island.net/archives/mawk/mawk-1.3.4-20250131.tgz"
SRC_VERSION="1.3.4-20250131"

build() {
    tar xf ../$SRC_FILENAME
    cd mawk-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
}

package() {
    cd mawk-$SRC_VERSION/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -s mawk $TT_INSTALLDIR/bin/awk
}