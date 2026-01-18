# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="71df8f40706a7bb0a80a5367079ea75d91da4f8c65c58ec59bcdfbf7decdab9f"
SRC_NAME="expat"
SRC_URL="https://github.com/libexpat/libexpat/releases/download/R_2_7_3/expat-2.7.3.tar.xz"
SRC_VERSION="2.7.3"

build() {
    tar xf ../$SRC_FILENAME
    cd expat-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}