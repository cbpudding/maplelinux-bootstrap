# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="65681cb0d0f80ed95780e79cf03f93672d1c14e41e767efdcc826901ea214420"
SRC_NAME="ncurses"
SRC_URL="https://invisible-island.net/archives/ncurses/current/ncurses-6.6-20260103.tgz"
SRC_VERSION="6.6-20260103"

build() {
    tar xf ../$SRC_FILENAME
    cd ncurses-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON \
        --with-cxx-shared \
        --without-debug \
        --without-normal \
        --with-shared
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}