# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="192c2fae048d4e7f514ba451627f9c4e612765099f819c19191f9fde3e609673"
SRC_NAME="byacc"
SRC_URL="https://invisible-mirror.net/archives/byacc/byacc-20241231.tgz"
SRC_VERSION="20241231"

build() {
    tar xf ../$SRC_FILENAME
    cd byacc-*/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
}

clean() {
    rm -rf byacc-*/
}

package() {
    cd byacc-*/
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