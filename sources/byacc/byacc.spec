# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="b618c5fb44c2f5f048843db90f7d1b24f78f47b07913c8c7ba8c942d3eb24b00"
SRC_NAME="byacc"
SRC_URL="https://invisible-mirror.net/archives/byacc/byacc-20260126.tgz"
SRC_VERSION="20260126"

build() {
    tar xzf ../$SRC_FILENAME
    cd byacc-*/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
    # NOTE: byacc's "make install" calls diff -c, which is unsupported by
    #       Busybox. Unfortunately, our other implementation of diff requires
    #       byacc to build, meaning we'll need to do a manual install to prevent
    #       a circular dependency. ~ahill
    mkdir -p $TT_INSTALLDIR/bin
    cp yacc $TT_INSTALLDIR/bin/
    ln -s yacc $TT_INSTALLDIR/bin/byacc
    mkdir -p $TT_INSTALLDIR/usr/share/man/man1
    cp yacc.1 $TT_INSTALLDIR/usr/share/man/man1/
}
