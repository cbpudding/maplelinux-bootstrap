# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="0b54f79df85912504de0b14aec7971e3f964491af1812d83447005807513cd9e"
SRC_NAME="xz"
SRC_URL="https://github.com/tukaani-project/xz/releases/download/v5.8.2/xz-5.8.2.tar.xz"
SRC_VERSION="5.8.2"

build() {
    tar xf ../$SRC_FILENAME
    cd xz-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static --enable-year2038
    make -O -j $TT_PROCS
}

clean() {
    rm -rf xz-*/
}

package() {
    cd xz-*/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
