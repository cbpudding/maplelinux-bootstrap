# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269"
SRC_NAME="bzip2"
SRC_REVISION=2
SRC_URL="https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
SRC_VERSION="1.0.8"

# TODO: Install the man pages ~ahill

build() {
    tar xf ../$SRC_FILENAME
    cd bzip2-*/
    # NOTE: bzip2 likes to hard-code CC, which won't work because gcc doesn't
    #       exist here. ~ahill
    # NOTE: -D_FILE_OFFSET_BITS is present because it's present in the Makefile
    #       and we're completely overriding its defaults. I don't actually know
    #       if this will cause any issues if it's missing. ~ahill
    make -O -f Makefile-libbz2_so -j $TT_PROCS CC=$CC CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64"
    # NOTE: bzip2recover is part of the first Makefile, so we need to invoke
    #       that to build the command. ~ahill
    make -O -j $TT_PROCS bzip2recover CC=$CC CFLAGS="$CFLAGS -D_FILE_OFFSET_BITS=64"
    # NOTE: The shared Makefile doesn't have an "install" target, so we just
    #       copy the files over ourselves. ~ahill
    mkdir -p $TT_INSTALLDIR$TT_BINDIR
    cp bzdiff $TT_INSTALLDIR$TT_BINDIR/
    chmod +x $TT_INSTALLDIR$TT_BINDIR/bzdiff
    ln -sf bzdiff $TT_INSTALLDIR$TT_BINDIR/bzcmp
    cp bzgrep $TT_INSTALLDIR$TT_BINDIR/
    chmod +x $TT_INSTALLDIR$TT_BINDIR/bzgrep
    ln -sf bzgrep $TT_INSTALLDIR$TT_BINDIR/bzegrep
    ln -sf bzgrep $TT_INSTALLDIR$TT_BINDIR/bzfgrep
    cp bzip2recover $TT_INSTALLDIR$TT_BINDIR/
    cp bzmore $TT_INSTALLDIR$TT_BINDIR/
    chmod +x $TT_INSTALLDIR$TT_BINDIR/bzmore
    ln -sf bzmore $TT_INSTALLDIR$TT_BINDIR/bzless
    cp bzip2-shared $TT_INSTALLDIR$TT_BINDIR/bzip2
    ln -sf bzip2 $TT_INSTALLDIR$TT_BINDIR/bunzip2
    ln -sf bzip2 $TT_INSTALLDIR$TT_BINDIR/bzcat
    mkdir -p $TT_INSTALLDIR$TT_LIBDIR
    SO_NAME=libbz2.so.$(echo $SRC_VERSION | cut -d"r" -f1)
    cp $SO_NAME $TT_INSTALLDIR$TT_LIBDIR/
    ln -sf $SO_NAME $TT_INSTALLDIR$TT_LIBDIR/libbz2.so.$(echo $SRC_VERSION | cut -d"." -f1,2)
    ln -sf $SO_NAME $TT_INSTALLDIR$TT_LIBDIR/libbz2.so.$(echo $SRC_VERSION | cut -d"." -f1)
    ln -sf $SO_NAME $TT_INSTALLDIR$TT_LIBDIR/libbz2.so
    mkdir -p $TT_INSTALLDIR$TT_INCLUDEDIR
    cp bzlib.h $TT_INSTALLDIR$TT_INCLUDEDIR/
}