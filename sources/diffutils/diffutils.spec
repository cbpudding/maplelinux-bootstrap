# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="7c8b7f9fc8609141fdea9cece85249d308624391ff61dedaf528fcb337727dfd"
SRC_NAME="diffutils"
SRC_URL="https://ftp.gnu.org/gnu/diffutils/diffutils-3.12.tar.xz"
SRC_VERSION="3.12"

build() {
    tar xf ../$SRC_FILENAME
    cd diffutils-$SRC_VERSION/
    # NOTE: GNU Diffutils 3.12 has a bug when cross-compiling, stating that it
    #       can't run a test because it is cross-compiling. Rather than ignore
    #       the issue, the configure script simply dies, preventing the build
    #       from proceeding. Adding gl_cv_func_strcasecmp_works fixes the issue
    #       without the need for a patch. ~ahill
    # See also: https://lists.gnu.org/archive/html/bug-gnulib/2025-04/msg00056.html
    ./configure $TT_AUTOCONF_COMMON gl_cv_func_strcasecmp_works=y
    make -j $TT_PROCS
}

package() {
    cd diffutils-$SRC_VERSION/
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}