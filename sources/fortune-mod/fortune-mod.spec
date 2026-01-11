# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="1f387877254e95eab61f937257b42609f29b994ef0571531655bbfc3a2ac74ac"
SRC_NAME="fortune-mod"
SRC_URL="https://github.com/shlomif/fortune-mod/releases/download/fortune-mod-3.24.0/fortune-mod-3.24.0.tar.xz"
SRC_VERSION="3.24.0"

build() {
    tar xf ../$SRC_FILENAME
    # NOTE: There is no other way to prevent fortune from installing itself
    #       under /games, so we have to modify the CMakeLists in this case.
    #       ~ahill
    sed -i "/fortune\/fortune.c/{n; s/games/bin/}" fortune-mod-$SRC_VERSION/CMakeLists.txt
    # NOTE: Similarly, the same thing happens for man pages. ~ahill
    sed -i "s|share/man/man|usr/share/man/man|" fortune-mod-$SRC_VERSION/cmake/Shlomif_Common.cmake
    cat fortune-mod-3.24.0/cmake/Shlomif_Common.cmake
    # NOTE: I don't agree with the offensive jokes included in this distribution
    #       but they are hidden behind the -o flag, and I want them to be seen
    #       as "unfunny" before the next generation thinks they're funny. ~ahill
    cmake \
        -B build-$SRC_VERSION \
        -S fortune-mod-$SRC_VERSION \
        -DCMAKE_INSTALL_PREFIX=$TT_INSTALLDIR \
        -DCOOKIEDIR=$TT_INSTALLDIR/usr/share/games/fortunes \
        -DNO_OFFENSIVE=OFF
    cmake --build build-$SRC_VERSION --parallel $TT_PROCS
    # Finally, we add our custom fortunefile into the mix. ~ahill
    cp ../maple .
    # NOTE: Is there a better way to do this? This probably won't survive
    #       cross-compilation. ~ahill
    ./build-$SRC_VERSION/strfile maple
}

package() {
    cmake --install build-$SRC_VERSION --parallel $TT_PROCS
    cp maple $TT_INSTALLDIR/usr/share/games/fortunes/
    cp maple.dat $TT_INSTALLDIR/usr/share/games/fortunes/
    ln -sf maple $TT_INSTALLDIR/usr/share/games/fortunes/maple.u8
}
