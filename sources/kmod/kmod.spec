# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="cb47be49366b596e4554eeeb7595b128feb261619c7675603e004b07c5ebbd5b"
SRC_NAME="kmod"
SRC_URL="https://github.com/kmod-project/kmod/archive/refs/tags/v34.tar.gz"
SRC_VERSION="34"

SRC_FILENAME="kmod-$SRC_VERSION.tar.gz"

# TODO: Fix pkgconfig directory (/usr/share/pkgconfig -> /lib/pkgconfig)

build() {
    tar xzf ../$SRC_FILENAME
    cd kmod-$SRC_VERSION/
    ./autogen.sh
    # NOTE: Building man pages requires scdoc. In an attempt to reduce the total
    #       number of dependencies, documentation is temporarily disabled.
    #       ~ahill
    ./configure $TT_AUTOCONF_COMMON --disable-manpages --enable-year2038
    # NOTE: Toybox's implementation of ln doesn't support --force and --relative
    #       but we can use -f and -r instead. ~ahill
    sed -i "s/\$(LN_S) --force --relative/\$(LN_S) -rf/" Makefile
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
