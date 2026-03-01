# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="d917804c03e3d8c27663cb5f6929a1ca0b20c382f7cf83e7b86bab9eb538af99"
SRC_NAME="ncurses"
SRC_URL="https://invisible-island.net/archives/ncurses/current/ncurses-6.6-20260103.tgz"
SRC_VERSION="6.6-20260221"

build() {
    tar xzf ../$SRC_FILENAME
    cd ncurses-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON \
        --with-cxx-shared \
        --without-debug \
        --without-normal \
        --with-shared
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    # NOTE: Some programs will look for ncurses instead of ncursesw, so I'm
    #       adding a symlink for compatibility. ~ahill
    ln -sf libncurses++w.so $TT_INSTALLDIR/lib/libncurses++.so
    ln -sf libncursesw.so $TT_INSTALLDIR/lib/libncurses.so
    ln -sf libncursesw.so $TT_INSTALLDIR/lib/libcurses.so
}
