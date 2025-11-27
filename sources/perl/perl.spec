# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e093ef184d7f9a1b9797e2465296f55510adb6dab8842b0c3ed53329663096dc"
SRC_NAME="perl"
SRC_URL="https://www.cpan.org/src/5.0/perl-5.42.0.tar.gz"
SRC_VERSION="5.42.0"

build() {
    tar xf ../$SRC_FILENAME
    cd perl-*/
    ./Configure -des
    make -O -j $TT_PROCS
}

clean() {
    rm -rf perl-*/
}

package() {
    cd perl-*/
    make -O -j $TT_PROCS DESTDIR=$TT_INSTALLDIR
}