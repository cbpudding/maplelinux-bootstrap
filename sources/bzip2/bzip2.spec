# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
SRC_NAME="bzip2"
SRC_URL="https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
SRC_VERSION="1.0.8"

build() {
    tar xf ../$SRC_FILENAME
    cd bzip2-*/
    # NOTE: bzip2 likes to hard-code CC, which won't work because gcc doesn't
    #       exist here. ~ahill
    # NOTE: -D_FILE_OFFSET_BITS is present because it's present in the Makefile
    #       and we're completely overriding its defaults. I don't actually know
    #       if this will cause any issues if it's missing. ~ahill
    make -O -j $TT_PROCS CC=$CC CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64" PREFIX=/
    # NOTE: I'm not sure if it's possible to build bzip2 without building a
    #       static library, since the executable links with the static library
    #       and the shared library is isolated in a separate Makefile. ~ahill
    make -O -f Makefile-libbz2_so -j $TT_PROCS CC=$CC CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64" PREFIX=/
}

clean() {
    rm -rf bzip2-*/
}

package() {
    cd bzip2-*/
    make -O -j $TT_PROCS install PREFIX=$TT_INSTALLDIR
    # NOTE: The second Makefile doesn't have an "install" target, so we just
    #       toss the shared object into /lib and call it a day! ~ahill
    cp libbz2.so* $TT_INSTALLDIR/lib/
}