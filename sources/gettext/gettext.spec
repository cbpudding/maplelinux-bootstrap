# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="71132a3fb71e68245b8f2ac4e9e97137d3e5c02f415636eb508ae607bc01add7"
SRC_NAME="gettext"
SRC_URL="https://ftp.gnu.org/gnu/gettext/gettext-1.0.tar.xz"
SRC_VERSION="1.0"

build() {
    tar xJf ../$SRC_FILENAME
    cd gettext-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
