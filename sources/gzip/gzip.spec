# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="01a7b881bd220bfdf615f97b8718f80bdfd3f6add385b993dcf6efd14e8c0ac6"
SRC_NAME="gzip"
SRC_REVISION=1
SRC_URL="https://linux.maple.camp/mirror/gzip-1.14.tar.xz"
SRC_VERSION="1.14"

build() {
    tar xJf ../$SRC_FILENAME
    cd gzip-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    # NOTE: For some reason, zcat requires /bin/bash, even though it doesn't
    #       need it to function. Replacing /bin/bash with /bin/sh works just as
    #       well. ~ahill
    sed -i "s|/bin/bash|/bin/sh|" $TT_INSTALLDIR$TT_BINDIR/zcat
}
