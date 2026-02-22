# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="fb3197f17a99eb44d22a3a1a71f755f9622dd963e66acfdea1a45120951b02ed"
SRC_NAME="kbd"
SRC_URL="https://www.kernel.org/pub/linux/utils/kbd/kbd-2.9.0.tar.xz"
SRC_VERSION="2.9.0"

build() {
    tar xJf ../$SRC_FILENAME
    cd kbd-$SRC_VERSION/
    # NOTE: Apparently, vlock requires PAM to build, which we do not have and I
    #       hope I never have to add. ~ahill
    ./configure $TT_AUTOCONF_COMMON --disable-vlock
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
