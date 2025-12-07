# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="b7324cbe86e767b65f26f467ed8b12ad80e124e3ccb89076855c98e43a9eddd4"
SRC_NAME="nasm"
SRC_URL="https://www.nasm.us/pub/nasm/releasebuilds/3.01/nasm-3.01.tar.xz"
SRC_VERSION="3.01"

build() {
    tar xf ../$SRC_FILENAME
    cd nasm-$SRC_VERSION/
    ./autogen.sh
    ./configure $TT_AUTOCONF_COMMON --enable-suggestions --enable-year2038
    # NOTE: nasm redefines bool since they want it to be a typedef instead of a
    #       macro. Unfortunately, this seems to break clang because it is
    #       attempting to redefine a C++ keyword in include/compiler.h.
    sed -i "/#  ifdef bool/,/#  endif/d" include/compiler.h
    make -O -j $TT_PROCS
}

clean() {
    rm -rf nasm-$SRC_VERSION/
}

package() {
    cd nasm-$SRC_VERSION/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
