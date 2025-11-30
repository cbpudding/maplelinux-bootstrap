# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="c642ae9b75fee120b2d96c712538bd2cf283228d2337df2cf2988e3c02678ef4"
SRC_NAME="libyaml"
SRC_URL="http://pyyaml.org/download/libyaml/yaml-0.2.5.tar.gz"
SRC_VERSION="0.2.5"

build() {
    tar xf ../$SRC_FILENAME
    cd yaml-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -O -j $TT_PROCS
}

clean() {
    rm -rf yaml-*/
}

package() {
    cd yaml-*/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
