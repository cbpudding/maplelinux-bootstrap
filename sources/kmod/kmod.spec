# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="kmod-34.tar.gz"
SRC_HASH="cb47be49366b596e4554eeeb7595b128feb261619c7675603e004b07c5ebbd5b"
SRC_NAME="kmod"
SRC_URL="https://github.com/kmod-project/kmod/archive/refs/tags/v34.tar.gz"
SRC_VERSION="34"

# TODO: Fix pkgconfig directory (/usr/share/pkgconfig -> /lib/pkgconfig)

build() {
    tar xf ../$SRC_FILENAME
    cd kmod-$SRC_VERSION/
    ./autogen.sh
    # NOTE: Building man pages requires scdoc. In an attempt to reduce the total
    #       number of dependencies, documentation is temporarily disabled.
    #       ~ahill
    ./configure $TT_AUTOCONF_COMMON --disable-manpages --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
