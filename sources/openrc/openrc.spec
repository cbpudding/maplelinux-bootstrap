# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="1b661016bd8cd4189be83b441dd7062c967b641fdc00f741e359e22d06857df8"
SRC_NAME="openrc"
SRC_PATCHES="67f08365cddf1eda8fdfafcf4ac4e6f222193c0d1a28db11014334d4e9cb7c5a  fstab"
SRC_REVISION=1
SRC_URL="https://github.com/OpenRC/openrc/archive/refs/tags/0.63.tar.gz"
SRC_VERSION="0.63"

SRC_FILENAME="openrc-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd openrc-$SRC_VERSION/
    # TODO: Remove bash completions
    muon setup $TT_MESON_COMMON \
        -Dpam=false \
        -Dzsh-completions=true \
        build
    muon samu -C build
    muon -C build install -d $TT_INSTALLDIR
    ln -sf openrc-init $TT_INSTALLDIR/bin/init
    mkdir -p $TT_INSTALLDIR$TT_DATADIR/mapleconf/etc
    cp ../fstab $TT_INSTALLDIR$TT_DATADIR/mapleconf/etc/
}
