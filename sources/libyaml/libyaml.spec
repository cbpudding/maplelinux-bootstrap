# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="c642ae9b75fee120b2d96c712538bd2cf283228d2337df2cf2988e3c02678ef4"
SRC_NAME="libyaml"
SRC_URL="https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz"
SRC_VERSION="0.2.5"

build() {
    tar xf ../$SRC_FILENAME
    cd yaml-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}