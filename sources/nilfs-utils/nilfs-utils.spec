# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="4d208add65a4dac658cc6f73820f1865ae258b26d2ccea69c85b8996dfcbdebe"
SRC_NAME="nilfs-utils"
SRC_URL="https://github.com/nilfs-dev/nilfs-utils/archive/refs/tags/v2.3.0.tar.gz"
SRC_VERSION="2.3.0"

SRC_FILENAME="nilfs-utils-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd nilfs-utils-$SRC_VERSION/
    ./autogen.sh
    ./configure $TT_AUTOCONF_COMMON \
        --enable-year2038 \
        --without-blkid \
        --without-libmount \
        --without-selinux
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
