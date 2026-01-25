# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="openrc-0.63.tar.gz"
SRC_HASH="1b661016bd8cd4189be83b441dd7062c967b641fdc00f741e359e22d06857df8"
SRC_NAME="openrc"
SRC_URL="https://github.com/OpenRC/openrc/archive/refs/tags/0.63.tar.gz"
SRC_VERSION="0.63"

build() {
    tar xf ../$SRC_FILENAME
    cd openrc-$SRC_VERSION/
    # TODO: Remove bash completions
    muon setup $TT_MESON_COMMON \
        -Dpam=false \
        -Dzsh-completions=true \
        build
    muon samu -C build
    muon -C build install -d $TT_INSTALLDIR
}