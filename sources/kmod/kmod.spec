# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f31d23fe9d79374e1556c8a25c41a2754cde1cffcb154a6296f8078894b831e9"
SRC_NAME="kmod"
SRC_URL="https://linux.maple.camp/git/mirror/kmod/archive/v34.2.tar.gz"
SRC_VERSION="34.2"

SRC_FILENAME="kmod-$SRC_VERSION.tar.gz"

# TODO: Fix pkgconfig directory (/usr/share/pkgconfig -> /lib/pkgconfig)

build() {
    tar xzf ../$SRC_FILENAME
    cd kmod/
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
