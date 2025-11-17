# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="6d5c2f58583588ea791f4c8645004071d00dfa554a5bf788a006ca1eb5abd70b"
SRC_NAME="libressl"
SRC_URL="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.2.1.tar.gz"
SRC_VERSION="4.2.1"

build() {
    tar xf ../$SRC_FILENAME
    cd libressl-*/
    # TODO: What even is sharedstatedir and what should Maple Linux do with it?
    #       ~ahill
    ./configure \
        --bindir=$TT_BINDIR \
        --build=$TT_BUILD \
        --datarootdir=/usr/share \
        --disable-static \
        --host=$TT_TARGET \
        --includedir=$TT_INCLUDEDIR \
        --libdir=$TT_LIBDIR \
        --libexecdir=$TT_LIBDIR \
        --localstatedir=/var \
        --prefix=$TT_PREFIX \
        --runstatedir=/run \
        --sbindir=$TT_BINDIR \
        --sysconfdir=$TT_CONFDIR \
        --with-sysroot=$TT_SYSROOT
    make -j $TT_PROCS
}

clean() {
    rm -rf libressl-*/
}

package() {
    cd libressl-*/
    make -j $TT_PROCS install DESTDIR=$TT_SYSROOT
}