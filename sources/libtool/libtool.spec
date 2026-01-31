# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f81f5860666b0bc7d84baddefa60d1cb9fa6fceb2398cc3baca6afaa60266675"
SRC_NAME="libtool"
SRC_URL="https://linux.maple.camp/mirror/libtool-2.5.4.tar.xz"
SRC_VERSION="2.5.4"

build() {
    tar xf ../$SRC_FILENAME
    cd libtool-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -j $TT_PROCS
    # NOTE: For some reason, libtoolize uses the env command to locate sh, but
    #       we don't have the env command yet, because env is part of bsdutils,
    #       which requires musl-fts to function, which we can't build without
    #       libtoolize. Strangely enough, libtool is hard-coded to /bin/sh, so
    #       I don't know why libtoolize uses /usr/bin/env. ~ahill
    sed -i "s|/usr/bin/env sh|/bin/sh|" libtoolize
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
