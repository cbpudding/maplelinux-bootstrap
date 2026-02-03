# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="11a8f358910712cf957dd4fd205063fce7e386b68fc7dfe3a0e1e53155ec53c5"
SRC_NAME="shadow"
SRC_URL="https://github.com/shadow-maint/shadow/releases/download/4.19.3/shadow-4.19.3.tar.xz"
SRC_VERSION="4.19.3"

build() {
    tar xf ../$SRC_FILENAME
    cd shadow-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-logind --enable-year2038
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    # NOTE: Unfortunately, shadow doesn't listen to --sbindir for some reason,
    #       so we manually move it. ~ahill
    mv $TT_INSTALLDIR/sbin/* $TT_INSTALLDIR/bin/
    rm -rf $TT_INSTALLDIR/sbin
}
