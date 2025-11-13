SRC_HASH="a9a118bbe84d8764da0ea0d28b3ab3fae8477fc7e4085d90102b8596fc7c75e4"
SRC_NAME="musl"
SRC_URL="https://musl.libc.org/releases/musl-1.2.5.tar.gz"
SRC_VERSION="1.2.5"

# TODO: CVE-2025-26519

build() {
    tar xf ../musl-*.tar*
    cd musl-*/
    ./configure \
        --bindir=$TREETAP_BINDIR \
        --build=$TREETAP_BUILD \
        --includedir=$TREETAP_INCLUDEDIR \
        --libdir=$TREETAP_LIBDIR \
        --prefix=$TREETAP_PREFIX \
        --target=$TREETAP_TARGET
    make -j $TREETAP_PROCS
}

clean() {
    rm -rf musl-*/
}

package() {
    cd musl-*/
    DESTDIR=$TREETAP_INSTALLDIR make install
}
