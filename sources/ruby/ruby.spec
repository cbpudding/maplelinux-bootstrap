# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="3924be2d05db30f4e35f859bf028be85f4b7dd01714142fd823e4af5de2faf9d"
SRC_NAME="ruby"
SRC_URL="https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.1.tar.gz"
SRC_VERSION="4.0.1"

build() {
    tar xf ../$SRC_FILENAME
    cd ruby-$SRC_VERSION/
    # NOTE: Yes, Ruby has a configuration script already, but it lacks the
    #       --enable-year2038 option, so we rebuild it. ~ahill
    ./autogen.sh
    ./configure $TT_AUTOCONF_COMMON --enable-year2038 --without-gcc
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}