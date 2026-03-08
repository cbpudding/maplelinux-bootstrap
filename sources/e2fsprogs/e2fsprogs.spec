# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="254ef0e7f2a96c4d955a8038bf3f9944c9c73ae09c95848631f3ca6a2480ecb3"
SRC_NAME="e2fsprogs"
SRC_URL="https://linux.maple.camp/git/mirror/e2fsprogs/archive/v1.47.4.tar.gz"
SRC_VERSION="1.47.4"

SRC_FILENAME="e2fsprogs-$SRC_VERSION.tar.gz"

# TODO: Remove blkid
# TODO: Remove chattr
# TODO: Remove lsattr
# TODO: Remove uuidgen

build() {
    tar xzf ../$SRC_FILENAME
    cd e2fsprogs/
    ./configure $TT_AUTOCONF_COMMON \
        --enable-hardening \
        --enable-libuuid \
        --enable-relative-symlinks \
        --enable-symlink-install
    make -j $TT_PROCS
    make -j $TT_PROCS install install-libs DESTDIR=$TT_INSTALLDIR
}
