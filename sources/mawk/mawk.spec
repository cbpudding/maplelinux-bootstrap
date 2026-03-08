# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e2c08a77d0a84a01f9be454d1ca3872d4f103f9ada683d075198b0c6e965633d"
SRC_NAME="mawk"
SRC_URL="https://invisible-mirror.net/archives/mawk/mawk-1.3.4-20260302.tgz"
SRC_VERSION="1.3.4-20260302"

build() {
    tar xzf ../$SRC_FILENAME
    cd mawk-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -s mawk $TT_INSTALLDIR/bin/awk
}
