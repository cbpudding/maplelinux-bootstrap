# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="musl_fts-1.2.7.tar.gz"
SRC_HASH="49ae567a96dbab22823d045ffebe0d6b14b9b799925e9ca9274d47d26ff482a6"
SRC_NAME="musl-fts"
SRC_URL="https://github.com/void-linux/musl-fts/archive/refs/tags/v1.2.7.tar.gz"
SRC_VERSION="1.2.7"

build() {
    tar xf ../$SRC_FILENAME
    cd musl-fts-*/
    # TODO: Can we rewrite this to not rely on libtool going forward? ~ahill
    ./bootstrap.sh
    ./configure $TT_AUTOCONF_COMMON --disable-static
    make -j $TT_PROCS
}

clean() {
    rm -rf musl-fts-*/
}

package() {
    cd musl-fts-*/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}