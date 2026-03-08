# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="254ef0e7f2a96c4d955a8038bf3f9944c9c73ae09c95848631f3ca6a2480ecb3"
SRC_NAME="e2fsprogs"
SRC_REVISION=1
SRC_URL="https://linux.maple.camp/git/mirror/e2fsprogs/archive/v1.47.4.tar.gz"
SRC_VERSION="1.47.4"

SRC_FILENAME="e2fsprogs-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd e2fsprogs/
    ./configure $TT_AUTOCONF_COMMON \
        --enable-hardening \
        --enable-libuuid \
        --enable-relative-symlinks \
        --enable-symlink-install
    # NOTE: I'm not sure why, but a couple files attempt to include
    #       linux/unistd.h instead of unistd.h. Why? ~ahill
    sed -i "s|linux/unistd.h|unistd.h|" lib/ext2fs/imager.c
    sed -i "s|linux/unistd.h|unistd.h|" lib/ext2fs/llseek.c
    make -j $TT_PROCS
    make -j $TT_PROCS install install-libs DESTDIR=$TT_INSTALLDIR
    # NOTE: These tools conflict with Toybox and don't provide as many options,
    #       so they can simply be removed. ~ahill
    # TODO: Can we simply not build these going forward? ~ahill
    rm $TT_INSTALLDIR$TT_BINDIR/blkid
    rm $TT_INSTALLDIR$TT_BINDIR/chattr
    rm $TT_INSTALLDIR$TT_BINDIR/lsattr
    rm $TT_INSTALLDIR$TT_BINDIR/uuidgen
}
