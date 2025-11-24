# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e4315fef49b08912b1d1db3774dd98f971397b2751c648512b6c8d852590dc50"
SRC_NAME="m4"
SRC_URL="http://haddonthethird.net/m4/m4-2.tar.bz2"
SRC_VERSION="2"

build() {
    tar xf ../$SRC_FILENAME
    cd m4-*/
    make -O -j $TT_PROCS
}

clean() {
    rm -rf m4-*/
}

package() {
    cd m4-*/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}