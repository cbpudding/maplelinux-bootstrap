# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="muon-0.5.0.tar.gz"
SRC_HASH="565c1b6e1e58f7e90d8813fda0e2102df69fb493ddab4cf6a84ce3647466bee5"
SRC_NAME="muon"
SRC_URL="https://git.sr.ht/~lattis/muon/archive/0.5.0.tar.gz"
SRC_VERSION="0.5.0"

build() {
    tar xf ../$SRC_FILENAME
    cd muon-*/
    ./bootstrap.sh build
    ./build/muon-bootstrap setup build
    ./build/muon-bootstrap -C build samu
    ./build/muon -C build test -R
}

clean() {
    rm -rf muon-*/
}

package() {
    cd muon-*/
    DESTDIR=$TT_INSTALLDIR ./build/muon -C build install
}