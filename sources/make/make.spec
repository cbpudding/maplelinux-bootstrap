# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3"
SRC_NAME="make"
SRC_URL="https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
SRC_VERSION="4.4.1"

build() {
    tar xf ../$SRC_FILENAME
    cd make-*/
    ./configure \
        --bindir=$TT_BINDIR \
        --build=$TT_BUILD \
        --datarootdir=/usr/share \
        --enable-year2038 \
        --host=$TT_TARGET \
        --includedir=$TT_INCLUDEDIR \
        --libdir=$TT_LIBDIR \
        --libexecdir=$TT_LIBDIR \
        --localstatedir=/var \
        --prefix=$TT_PREFIX \
        --runstatedir=/run \
        --sbindir=$TT_BINDIR \
        --sysconfdir=$TT_CONFDIR
    make -O -j $TT_PROCS
}

clean() {
    rm -rf make-*/
}

package() {
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}