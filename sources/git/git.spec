# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="5818bd7d80b061bbbdfec8a433d609dc8818a05991f731ffc4a561e2ca18c653"
SRC_NAME="git"
SRC_URL="https://www.kernel.org/pub/software/scm/git/git-2.53.0.tar.xz"
SRC_VERSION="2.53.0"

build() {
    tar xJf ../$SRC_FILENAME
    cd git-$SRC_VERSION/
    ./configure $TT_AUTOCONF_COMMON --without-tcltk
    make -j $TT_PROCS NO_GITWEB=YesPlease NO_PERL=YesPlease NO_REGEX=NeedsStartEnd
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR NO_GITWEB=YesPlease NO_PERL=YesPlease NO_REGEX=NeedsStartEnd
    # Another package ignoring proper paths? Unacceptable! ~ahill
    mv $TT_INSTALLDIR/share/* $TT_INSTALLDIR/usr/share/
    rm -rf $TT_INSTALLDIR/share
}
