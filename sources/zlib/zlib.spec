# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="38ef96b8dfe510d42707d9c781877914792541133e1870841463bfa73f883e32"
SRC_NAME="zlib"
SRC_REVISION=1
SRC_URL="https://www.zlib.net/zlib-1.3.1.tar.xz"
SRC_VERSION="1.3.1"

build() {
    tar xf ../$SRC_FILENAME
    cd zlib-$SRC_VERSION/
    # NOTE: The prefix is set to /usr because man pages are stored under the
    #       prefix whether you like it or not. ~ahill
    # NOTE: Zlib refuses to build a shared library if it can't pass the test.
    #       Rather than stopping the build, it simply proceeds to build a static
    #       library, which causes issues when building libarchive. The test is
    #       failing due to it relying on undefined symbols that are referenced
    #       in the linker script, which LLVM doesn't like at all. To tell LLVM
    #       to ignore it, we pass --undefined-version to the linker. ~ahill
    CFLAGS="-Wl,--undefined-version $CFLAGS" \
    ./configure \
        --eprefix=$TT_PREFIX \
        --includedir=$TT_INCLUDEDIR \
        --libdir=$TT_LIBDIR \
        --prefix=/usr \
        --shared
    make -O -j $TT_PROCS
}

package() {
    cd zlib-$SRC_VERSION/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}