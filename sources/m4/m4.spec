# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f25c6ab51548a73a75558742fb031e0625d6485fe5f9155949d6486a2408ab66"
SRC_NAME="m4"
SRC_URL="https://ftp.gnu.org/gnu/m4/m4-1.4.21.tar.xz"
SRC_VERSION="1.4.21"

build() {
    tar xJf ../$SRC_FILENAME
    cd m4-*/
    ./configure $TT_AUTOCONF_COMMON --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
