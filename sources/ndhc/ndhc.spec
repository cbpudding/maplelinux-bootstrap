# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="6f02ddf9b5839c6771adb6efe2eb2a1df93eb41bc964838b23e4f4057fcf1fad"
SRC_NAME="ndhc"
SRC_PATCHES="92f0e757af230d2e4af0ab605eafba669943b017434255377452331af44fccdf  default.conf
06b7baf5622ec0dc65c404c9bc15b5fe0b91a6a848b719d0c56e75e22bbec31b  ndhcd"
SRC_URL="https://linux.maple.camp/git/ahill/ndhc/archive/v2024-05-24.tar.gz"
SRC_VERSION="2024-05-24"

SRC_FILENAME="ndhc-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd ndhc/
    make

    mkdir -p $TT_INSTALLDIR$TT_BINDIR
    cp ndhc $TT_INSTALLDIR$TT_BINDIR/
    mkdir -p $TT_INSTALLDIR$TT_DATADIR/man/man8
    cp ndhc.8 $TT_INSTALLDIR$TT_DATADIR/man/man8/

    CONFDIR=$TT_INSTALLDIR$TT_CONFDIR/ndhc
    mkdir -p $CONFDIR
    chown root:root $CONFDIR
    chmod 0755 $CONFDIR

    NDHCROOT=$TT_INSTALLDIR$TT_STATEDIR/lib/ndhc
    mkdir -p $NDHCROOT
    chown root:root $NDHCROOT
    chmod a+rx $NDHCROOT

    mkdir -p $NDHCROOT/var/run
    mkdir -p $NDHCROOT/var/state
    chown -R ndhc:dhcp $NDHCROOT/var
    chmod -R a+rx $NDHCROOT/var
    chmod g+w $NDHCROOT/var/run

    # This is where cpio comes in clutch. ~ahill
    mkdir -p $NDHCROOT/dev
    mknod $NDHCROOT/dev/null c 1 3
    mknod $NDHCROOT/dev/urandom c 1 9
    chown -R root:root $NDHCROOT/dev
    chmod a+rx $NDHCROOT/dev
    chmod a+rw $NDHCROOT/dev/null
    chmod a+r $NDHCROOT/dev/urandom

    mkdir -p $TT_INSTALLDIR$TT_DATADIR/mapleconf$TT_CONFDIR/ndhc
    cp ../default.conf $TT_INSTALLDIR$TT_DATADIR/mapleconf$TT_CONFDIR/ndhc/

    mkdir -p $TT_INSTALLDIR$TT_CONFDIR/init.d
    cp ../ndhcd $TT_INSTALLDIR$TT_CONFDIR/init.d/
}
