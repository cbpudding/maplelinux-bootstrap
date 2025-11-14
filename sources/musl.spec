SRC_HASH="a9a118bbe84d8764da0ea0d28b3ab3fae8477fc7e4085d90102b8596fc7c75e4"
SRC_NAME="musl"
SRC_URL="https://musl.libc.org/releases/musl-1.2.5.tar.gz"
SRC_VERSION="1.2.5"

# TODO: CVE-2025-26519

build() {
    tar xf ../musl-*.tar*
    cd musl-*/
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
