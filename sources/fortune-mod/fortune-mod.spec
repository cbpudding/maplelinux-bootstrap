# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ac4d1486cac9b999049107136b94106fe98a4aeac00ec635b144c43764bffe4c"
SRC_NAME="fortune-mod"
SRC_PATCHES="1dde7a66dcf9033227a4747b5e892cc1845a77f025d6c5d3c6f49c15dee7c239  maple"
SRC_URL="https://github.com/shlomif/fortune-mod/releases/download/fortune-mod-3.26.0/fortune-mod-3.26.0.tar.xz"
SRC_VERSION="3.26.0"

build() {
    tar xJf ../$SRC_FILENAME
    # NOTE: There is no other way to prevent fortune from installing itself
    #       under /games, so we have to modify the CMakeLists in this case.
    #       ~ahill
    sed -i "/fortune\/fortune.c/{n; s/games/bin/}" fortune-mod-$SRC_VERSION/CMakeLists.txt
    # NOTE: Similarly, the same thing happens for man pages. ~ahill
    sed -i "s|share/man/man|usr/share/man/man|" fortune-mod-$SRC_VERSION/cmake/Shlomif_Common.cmake
    # NOTE: I don't agree with the offensive jokes included in this distribution
    #       but they are hidden behind the -o flag, and I want them to be seen
    #       as "unfunny" before the next generation thinks they're funny. ~ahill
    cmake \
        -B build-$SRC_VERSION \
        -S fortune-mod-$SRC_VERSION \
        -DCMAKE_INSTALL_PREFIX=$TT_INSTALLDIR \
        -DCOOKIEDIR=$TT_INSTALLDIR$TT_DATADIR/fortunes \
        -DNO_OFFENSIVE=OFF
    cmake --build build-$SRC_VERSION --parallel $TT_PROCS
    # Finally, we add our custom fortunefile into the mix. ~ahill
    # NOTE: Is there a better way to do this? This probably won't survive
    #       cross-compilation. ~ahill
    ./build-$SRC_VERSION/strfile maple
    cmake --install build-$SRC_VERSION --parallel $TT_PROCS
    cp maple $TT_INSTALLDIR/usr/share/games/fortunes/
    cp maple.dat $TT_INSTALLDIR/usr/share/games/fortunes/
    ln -sf maple $TT_INSTALLDIR/usr/share/games/fortunes/maple.u8
}
