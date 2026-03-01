# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="a71fb7efea5a63770d8fb71321ef6ae7afe0592f1aa7f7e2b496c26ccbb392a4"
SRC_NAME="mawk"
SRC_URL="https://invisible-island.net/archives/mawk/mawk-1.3.4-20260129.tgz"
SRC_VERSION="1.3.4-20260129"

build() {
    tar xzf ../$SRC_FILENAME
    cd mawk-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -s mawk $TT_INSTALLDIR/bin/awk
}
