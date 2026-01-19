# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="00e07d7c0f2f0cc002432d1ee84d2a40dae404a99303e3f97701c10966c91834"
SRC_NAME="python"
SRC_URL="https://www.python.org/ftp/python/3.9.25/Python-3.9.25.tar.xz"
SRC_VERSION="3.9.25"

# NOTE: Yes, this is end-of-life, but it's the last version of Python that
#       supports LibreSSL, so we're stuck with it for now. ~ahill
# See also: https://peps.python.org/pep-0644/

build() {
    tar xf ../$SRC_FILENAME
    cd Python-$SRC_VERSION/
    # NOTE: Python must do some clang-specific checks because it attempts to
    #       find and link with libclang_rt.profile.a, which unfortunately does
    #       not exist at the moment. Since it only attempts to link when
    #       CC=clang, we just override CC for the configuration portion. ~ahill
    CC=cc ./configure $TT_AUTOCONF_COMMON --enable-optimizations
    make -O -j $TT_PROCS
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    # Bad Python! Bad! ~ahill
    mv $TT_INSTALLDIR/include/python3.9/* $TT_INSTALLDIR/usr/include/python3.9/
    rm -rf $TT_INSTALLDIR/include
}