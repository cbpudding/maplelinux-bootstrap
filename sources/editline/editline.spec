# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="21362b00653bbfc1c71f71a7578da66b5b5203559d43134d2dd7719e313ce041"
SRC_NAME="editline"
SRC_URL="https://thrysoee.dk/editline/libedit-20251016-3.1.tar.gz"
SRC_VERSION="20251016-3.1"

build() {
    tar xf ../$SRC_FILENAME
    cd libedit-*/
    ./configure $TT_AUTOCONF_COMMON --disable-static
    # NOTE: wchar_t isn't defined correctly due to a bug in clang, preventing
    #       libedit from building properly. ~ahill
    # See also: https://bugs.gentoo.org/870001
    make -O -j $TT_PROCS CFLAGS="$CFLAGS -include stdc-predef.h"
}

clean() {
    rm -rf libedit-*/
}

package() {
    cd libedit-*/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}