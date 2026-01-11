# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f87cee69eec2b4fcbf60a396b030ad6aa3415f192aa5f7ee84cad5e11f7f5ae3"
SRC_NAME="patch"
SRC_URL="https://ftp.gnu.org/gnu/patch/patch-2.8.tar.xz"
SRC_VERSION="2.8"

build() {
    tar xf ../$SRC_FILENAME
    cd patch-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
}

package() {
    cd patch-$SRC_VERSION/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}