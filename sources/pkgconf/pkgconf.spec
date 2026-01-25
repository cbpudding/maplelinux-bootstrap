# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="cd05c9589b9f86ecf044c10a2269822bc9eb001eced2582cfffd658b0a50c243"
SRC_NAME="pkgconf"
SRC_URL="https://distfiles.dereferenced.org/pkgconf/pkgconf-2.5.1.tar.xz"
SRC_VERSION="2.5.1"

build() {
    tar xf ../$SRC_FILENAME
    cd pkgconf-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    # NOTE: Symlink for compatibility's sake. Currently being used by Muon.
    #       ~ahill
    ln -sf pkgconf $TT_INSTALLDIR/bin/pkg-config
}