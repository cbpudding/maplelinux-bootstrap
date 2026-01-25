# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="3cd8fee86f69a949cb610fee8cd9264e6873d07fa58411f6060b3d62729ed7c5"
SRC_NAME="git"
SRC_URL="https://www.kernel.org/pub/software/scm/git/git-2.52.0.tar.xz"
SRC_VERSION="2.52.0"

build() {
    tar xf ../$SRC_FILENAME
    cd git-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --without-tcltk
    make -j $TT_PROCS NO_GITWEB=YesPlease NO_PERL=YesPlease NO_REGEX=NeedsStartEnd
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR NO_GITWEB=YesPlease NO_PERL=YesPlease NO_REGEX=NeedsStartEnd
    # Another package ignoring proper paths? Unacceptable! ~ahill
    mv $TT_INSTALLDIR/share/* $TT_INSTALLDIR/usr/share/
    rm -rf $TT_INSTALLDIR/share
}