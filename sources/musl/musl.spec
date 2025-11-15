# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="a9a118bbe84d8764da0ea0d28b3ab3fae8477fc7e4085d90102b8596fc7c75e4"
SRC_NAME="musl"
SRC_PATCHES="
c0ffd0493dcde91850e39428a31577892aad20e83bc4bf4a5c37350649ce7932  CVE-2025-26519.patch
"
SRC_URL="https://musl.libc.org/releases/musl-1.2.5.tar.gz"
SRC_VERSION="1.2.5r1"

build() {
    tar xf ../$SRC_FILENAME
    cd musl-*/
    # NOTE: CVE-2025-26519 patches are temporary and shouldn't be needed once
    #       1.2.6 or 1.3.0 is released. ~ahill
    # https://www.openwall.com/lists/musl/2025/02/13/1/1
    # https://www.openwall.com/lists/musl/2025/02/13/1/2
    patch -p1 < ../CVE-2025-26519.patch
    ./configure \
        --bindir=$TT_BINDIR \
        --build=$TT_BUILD \
        --includedir=$TT_INCLUDEDIR \
        --libdir=$TT_LIBDIR \
        --prefix=$TT_PREFIX \
        --target=$TT_TARGET
    make -O -j $TT_PROCS
}

clean() {
    rm -rf musl-*/
}

package() {
    cd musl-*/
    DESTDIR=$TT_INSTALLDIR make install
}
