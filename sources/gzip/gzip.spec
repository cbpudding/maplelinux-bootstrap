# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="01a7b881bd220bfdf615f97b8718f80bdfd3f6add385b993dcf6efd14e8c0ac6"
SRC_NAME="gzip"
SRC_URL="https://ftp.gnu.org/gnu/gzip/gzip-1.14.tar.xz"
SRC_VERSION="1.14"

build() {
    tar xf ../$SRC_FILENAME
    cd gzip-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
}

package() {
    cd gzip-$SRC_VERSION/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}