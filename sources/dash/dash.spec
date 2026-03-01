# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="845fd61702ae5e53e09664faa450da82805958924b109b8c5b4777bd8551af00"
SRC_NAME="dash"
SRC_URL="https://salsa.debian.org/debian/dash/-/archive/debian/0.5.12-12/dash-debian-0.5.12-12.tar.gz"
SRC_VERSION="0.5.12-12"

SRC_FILENAME="dash-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd dash-*/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -s dash $TT_INSTALLDIR/bin/sh
}
