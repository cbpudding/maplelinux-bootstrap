# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9286ee5471a8a5339a61eb952739e4614a5b1dbed79ca73a78f014885ce2ad53"
SRC_NAME="e2fsprogs"
SRC_URL="https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git/snapshot/e2fsprogs-1.47.3.tar.gz"
SRC_VERSION="1.47.3"

# TODO: Remove blkid
# TODO: Remove chattr
# TODO: Remove lsattr
# TODO: Remove uuidgen

build() {
    tar xzf ../$SRC_FILENAME
    cd e2fsprogs-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON \
        --enable-hardening \
        --enable-libuuid \
        --enable-relative-symlinks \
        --enable-symlink-install
    make -j $TT_PROCS
    make -j $TT_PROCS install install-libs DESTDIR=$TT_INSTALLDIR
}
