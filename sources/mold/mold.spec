# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="mold-2.40.4.tar.gz"
SRC_HASH="69414c702ec1084e1fa8ca16da24f167f549e5e11e9ecd5d70a8dcda6f08c249"
SRC_NAME="mold"
SRC_URL="https://github.com/rui314/mold/archive/refs/tags/v2.40.4.tar.gz"
SRC_VERSION="2.40.4"

build() {
    tar xf ../$SRC_FILENAME
    cd mold-*/
    cmake -B build $TT_CMAKE_COMMON
    cmake --build build --parallel $TT_PROCS
}

clean() {
    rm -rf mold-*/
}

package() {
    cd mold-*/
    # NOTE: Setting --prefix here is ineffective because GNUInstallDirs are used
    #       in install functions despite CMake's documentation warning against
    #       such a thing for this exact reason. ~ahill
    # See also: https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html
    cmake --install build --parallel $TT_PROCS
    mkdir -p $TT_INSTALLDIR$TT_BINDIR
    ln -sf mold $TT_INSTALLDIR$TT_BINDIR/ld
}
