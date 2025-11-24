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
    cmake --install build --parallel $TT_PROCS
    ln -sf mold $TT_INSTALLDIR/bin/ld
}