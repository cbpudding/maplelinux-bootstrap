# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="3cd8fee86f69a949cb610fee8cd9264e6873d07fa58411f6060b3d62729ed7c5"
SRC_NAME="git"
SRC_URL="https://www.kernel.org/pub/software/scm/git/git-2.52.0.tar.xz"
SRC_VERSION="2.52.0"

build() {
    tar xf ../$SRC_FILENAME
    cd git-$SRC_VERSION/
    # TODO: What breaks if I pass NO_CURL or NO_EXPAT? ~ahill
    make -j $TT_PROCS NO_REGEX=NeedsStartEnd NO_TCLTK=1
    # TODO: How do we tell git where to install components? ~ahill
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR NO_REGEX=NeedsStartEnd NO_TCLTK=1
}