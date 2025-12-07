# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6"
SRC_NAME="ncurses"
SRC_REVISION=1
SRC_URL="https://invisible-island.net/archives/ncurses/ncurses-6.5.tar.gz"
SRC_VERSION="6.5"

# TODO: Remove the target triple prefix from all of ncurses' executables ~ahill

build() {
    tar xf ../$SRC_FILENAME
    cd ncurses-*/
    ./configure $TT_AUTOCONF_COMMON \
        --enable-pc-files \
        --program-prefix="" \
        --with-cxx-shared \
        --with-pkg-config-libdir=$TT_LIBDIR/pkgconfig \
        --with-shared \
        --without-ada \
        --without-debug \
        --without-normal \
        --without-tests
    make -O -j $TT_PROCS
}

clean() {
    rm -rf ncurses-*/
}

package() {
    cd ncurses-*/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    # NOTE: These symlinks exist for compatibility's sake, since some libraries
    #       will only look for "ncurses" and not "ncursesw". ~ahill
    ln -s libncursesw.so $TT_INSTALLDIR/lib/libncurses.so
    ln -s libncurses++w.so $TT_INSTALLDIR/lib/libncurses++.so
}
