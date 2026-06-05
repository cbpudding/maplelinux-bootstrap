# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9fd672b1c8425fac2fa67fa0477b990987268b90ff36d5f016dae57be0d6b52e"
SRC_NAME="autoconf"
SRC_URL="https://ftp.gnu.org/gnu/autoconf/autoconf-2.73.tar.xz"
SRC_VERSION="2.73"

build() {
    tar xJf ../$SRC_FILENAME
    cd autoconf-*/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
