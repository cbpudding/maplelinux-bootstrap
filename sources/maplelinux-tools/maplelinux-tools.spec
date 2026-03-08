# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="3587d9cb45f3d17b6be4a996dc507a19635b0638be7b34c01b7471fb82aeb908"
SRC_NAME="maplelinux-tools"
SRC_URL="https://linux.maple.camp/git/ahill/maplelinux-tools/archive/455dc3f3e54b5e091af5a4bb65c380be4247e4d0.tar.gz"
SRC_VERSION="455dc3f"

SRC_FILENAME="maplelinux-tools-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd maplelinux-tools/
    mkdir -p $TT_INSTALLDIR$TT_BINDIR
    find -perm 755 -type f -exec cp "{}" $TT_INSTALLDIR$TT_BINDIR/ \;
}
