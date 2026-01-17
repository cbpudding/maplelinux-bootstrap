# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="6d5c2f58583588ea791f4c8645004071d00dfa554a5bf788a006ca1eb5abd70b"
SRC_NAME="libressl"
SRC_URL="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.2.1.tar.gz"
SRC_VERSION="4.2.1"

# TODO: Should the openssl command be a symlink? For the sake of transparency,
#       it may make sense to rename the command to "libressl" and make "openssl"
#       a symlink for compatibility's sake. ~ahill

build() {
    tar xf ../$SRC_FILENAME
    cd libressl-*/
    # TODO: What even is sharedstatedir and what should Maple Linux do with it?
    #       ~ahill
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}