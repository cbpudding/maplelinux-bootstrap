# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="d585fd3b613c66151fc3249e8ed44f77020cb5e6c1e635a616d3f9f82460512a"
SRC_NAME="musl"
SRC_URL="https://musl.libc.org/releases/musl-1.2.6.tar.gz"
SRC_VERSION="1.2.6"

# TODO: CVE-2026-6042 (https://www.openwall.com/lists/musl/2026/04/03/2/1)
# TODO: CVE-2026-40200 (https://www.openwall.com/lists/musl/2026/04/10/3/1)

build() {
    tar xzf ../$SRC_FILENAME
    cd musl-*/
    ./configure $TT_AUTOCONF_COMMON
    make -O -j $TT_PROCS
    DESTDIR=$TT_INSTALLDIR make install
    # NOTE: Apparently, the linker library has an entry point that we can use as
    #       ldd. What kind of black magic is this? ~ahill
    mkdir -p $TT_INSTALLDIR/bin
    ln -sf /lib/ld-musl-$TT_ARCH.so.1 $TT_INSTALLDIR/bin/ldd
}
