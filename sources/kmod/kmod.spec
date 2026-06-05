# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="5a5d5073070cc7e0c7a7a3c6ec2a0e1780850c8b47b3e3892226b93ffcb9cb54"
SRC_NAME="kmod"
SRC_URL="https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-34.2.tar.xz"
SRC_VERSION="34.2"

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
