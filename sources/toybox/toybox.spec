# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9d4c124d7d731a2db399f6278baa2b42c2e3511f610c6ad30cc3f1a52581334b"
SRC_NAME="toybox"
SRC_URL="https://landley.net/toybox/downloads/toybox-0.8.13.tar.gz"
SRC_VERSION="0.8.13"

build() {
    tar xzf ../$SRC_FILENAME
    cd toybox-$SRC_VERSION/
    # NOTE: Toybox is still using egrep instead of grep -E. This will fix that
    #       and prevent errors later on. ~ahill
    sed -i "s/egrep/grep -E/" scripts/make.sh
    make defconfig
    make -j $TT_PROCS
    mkdir -p $TT_INSTALLDIR$TT_BINDIR
    PREFIX=$TT_INSTALLDIR$TT_BINDIR ./scripts/install.sh --symlink
}
