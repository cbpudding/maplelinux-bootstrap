# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="edf01aee24c65d69e6a9efcb9d44bcda682ff9d4f3bbbd95e794e1dfa90847b5"
SRC_NAME="libressl"
SRC_URL="https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-4.3.2.tar.gz"
SRC_VERSION="4.3.2"

# TODO: Should the openssl command be a symlink? For the sake of transparency,
#       it may make sense to rename the command to "libressl" and make "openssl"
#       a symlink for compatibility's sake. ~ahill

build() {
    tar xzf ../$SRC_FILENAME
    cd libressl-*/
    # TODO: What even is sharedstatedir and what should Maple Linux do with it?
    #       ~ahill
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
