# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f7aa64ea69f956a54efc6fd15ddfbaab5ee0cc63395955318fab11e427c88e75"
SRC_NAME="ncurses"
SRC_URL="https://invisible-island.net/archives/ncurses/current/ncurses-6.6-20260301.tgz"
SRC_VERSION="6.6-20260301"

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
