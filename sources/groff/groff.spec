# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="74e2819795b6aff431aeac983d63a9c8968eeaba2a2eba7df8ba4c7b41e7cfd8"
SRC_NAME="groff"
SRC_URL="https://ftp.gnu.org/gnu/groff/groff-1.24.1.tar.gz"
SRC_VERSION="1.24.1"

build() {
    tar xzf ../$SRC_FILENAME
    cd groff-*/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
