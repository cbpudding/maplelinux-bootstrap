# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="91eb74caed0ee6655b669711a4f350c25579778694df248e28363318e03c7fc4"
SRC_NAME="bc"
SRC_URL="https://github.com/gavinhoward/bc/releases/download/7.0.3/bc-7.0.3.tar.xz"
SRC_VERSION="7.0.3"

build() {
    tar xJf ../$SRC_FILENAME
    cd bc-$SRC_VERSION/
    # NOTE: This is another autoconf-like script that isn't actually using
    #       autoconf. Because of this, I am unable to use TT_AUTOCONF_COMMON
    #       here. ~ahill
    ./configure \
        --bindir $TT_BINDIR \
        --datadir $TT_DATADIR \
        --datarootdir $TT_DATADIR \
        --includedir $TT_INCLUDEDIR \
        --install-all-locales \
        --libdir $TT_LIBDIR \
        --prefix $TT_PREFIX \
        --set-default-on bc.banner
    # NOTE: Despite setting bc.banner, the configuration script for this version
    #       refuses to set it. It's not a big deal, but why wouldn't you want to
    #       know who made the software? ~ahill
    sed -i "s/^BC_DEFAULT_BANNER.*/BC_DEFAULT_BANNER = 1/" Makefile
    # NOTE: The Makefile ignores environment variables in this case, so we must
    #       set CC and HOSTCC manually.
    make -O -j $TT_PROCS CC=$CC HOSTCC=$CC
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
