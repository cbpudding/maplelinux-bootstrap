# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="6b9757f592b7518b4902eb6af7e54570bdccba37a871fddb2d30ae3863511c13"
SRC_NAME="groff"
SRC_URL="https://ftp.gnu.org/gnu/groff/groff-1.23.0.tar.gz"
SRC_VERSION="1.23.0"

build() {
    tar xf ../$SRC_FILENAME
    cd groff-*/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}