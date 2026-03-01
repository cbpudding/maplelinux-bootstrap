# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16"
SRC_NAME="zlib"
SRC_URL="https://www.zlib.net/zlib-1.3.2.tar.gz"
SRC_VERSION="1.3.2"

build() {
    tar xzf ../$SRC_FILENAME
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
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
