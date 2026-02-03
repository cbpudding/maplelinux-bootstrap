# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="b88cc9163d0c652aaf39a99991d974ddba1c3a9711db8f1b5838af2a14731014"
SRC_NAME="libbsd"
SRC_URL="https://libbsd.freedesktop.org/releases/libbsd-0.12.2.tar.xz"
SRC_VERSION="0.12.2"

build() {
    tar xf ../$SRC_FILENAME
    cd libbsd-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
