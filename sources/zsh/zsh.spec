# Maintainer: Alexander Hill
SRC_HASH="5d20bec03f981dc4e9a09ec245e7415388ff641f79c5c5c416b5042e58d8280d"
SRC_NAME="zsh"
SRC_URL="https://www.zsh.org/pub/zsh-5.9.1.tar.xz"
SRC_VERSION="5.9.1"

build() {
    tar xJf ../$SRC_FILENAME
    cd zsh-$SRC_VERSION/
    # NOTE: Zsh uses a lot of tests made of main functions that are missing a
    #       return type. Because of this, clang throws an error, causing the
    #       test to fail. The result is a binary where command substitution
    #       locks the shell up. To fix this, we pass -Wno-implicit-int to the
    #       configure script. ~ahill
    CFLAGS="$CFLAGS -Wno-implicit-int" \
    ./configure \
        $TT_AUTOCONF_COMMON \
        --enable-multibyte \
        --enable-libc-musl
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -sf zsh $TT_INSTALLDIR/bin/bash
}
