# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="64926eebf90092dca21b14259a5301b7b98e7b1943e8a201c7d726084809b527"
SRC_NAME="dosfstools"
SRC_URL="https://github.com/dosfstools/dosfstools/releases/download/v4.2/dosfstools-4.2.tar.gz"
SRC_VERSION="4.2"

build() {
    tar xzf ../$SRC_FILENAME
    cd dosfstools-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --enable-compat-symlinks
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
