# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="6e5ca4f8d76ee9e3a8db700b667f13e12aac9933828a64e1aaad93d26be9b479"
SRC_NAME="kbd"
SRC_URL="https://www.kernel.org/pub/linux/utils/kbd/kbd-2.10.0.tar.xz"
SRC_VERSION="2.10.0"

build() {
    tar xJf ../$SRC_FILENAME
    cd kbd-$SRC_VERSION/
    # NOTE: Apparently, vlock requires PAM to build, which we do not have and I
    #       hope I never have to add. ~ahill
    ./configure $TT_AUTOCONF_COMMON --disable-vlock
    make -j $TT_PROCS
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
