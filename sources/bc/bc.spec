# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ae470fec429775653e042015edc928d07c8c3b2fc59765172a330d3d87785f86"
SRC_NAME="bc"
SRC_URL="https://linux.maple.camp/mirror/bc-1.08.2.tar.gz"
SRC_VERSION="1.08.2"

build() {
    tar xf ../$SRC_FILENAME
    cd bc-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON
    # NOTE: We are setting MAKEINFO to true here because it is impossible to
    #       build bc without Texinfo otherwise. Texinfo is not used by any other
    #       package on Maple Linux, so it doesn't make sense to include it for
    #       the sole purpose of building bc. ~ahill
    make -O -j $TT_PROCS MAKEINFO=true
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR MAKEINFO=true
}
