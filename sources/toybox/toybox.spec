# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9d4c124d7d731a2db399f6278baa2b42c2e3511f610c6ad30cc3f1a52581334b"
SRC_NAME="toybox"
SRC_PATCHES="
f4dda4662bead0679256f54b1770faa57c1bfea9462778edf537644d1e5aa3b0  .config
"
SRC_URL="https://landley.net/toybox/downloads/toybox-0.8.13.tar.gz"
SRC_VERSION="0.8.13"

build() {
    tar xf ../$SRC_FILENAME
    cd toybox-$SRC_VERSION/
    # NOTE: make defconfig seems to do more than simply configure toybox. We'll
    #       run it to set *something* up, then overwrite the configuration with
    #       what I saved before. ~ahill
    make defconfig
    cp ../.config .
    make -j $TT_PROCS
}

clean() {
    rm -rf toybox-$SRC_VERSION/
}

package() {
    cd toybox-$SRC_VERSION/
    PREFIX=$TT_INSTALLDIR/bin ./scripts/install.sh --symlink
}