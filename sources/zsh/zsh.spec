# Maintainer: Alexander Hill
SRC_HASH="9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5"
SRC_NAME="zsh"
SRC_URL="https://www.zsh.org/pub/zsh-5.9.tar.xz"
SRC_VERSION="5.9"

build() {
    tar xf ../$SRC_FILENAME
    cd zsh-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --enable-multibyte --enable-libc-musl
    make -O -j $TT_PROCS
}

package() {
    cd zsh-$SRC_VERSION/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -sf zsh $TT_INSTALLDIR/bin/bash
}
