# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="2c738a5e6afec43fbc358cee79fbcdfd24759cfbb20485df8e8a3ead76e44942"
SRC_NAME="sbase"
SRC_REVISION=1
SRC_URL="https://linux.maple.camp/git/mirror/sbase/archive/004a51426e42d42150a746dc113ad86fb3fbed3c.tar.gz"
SRC_VERSION="0.1-158-g004a514"

# NOTE: We're using git describe --always --tags for versioning here. ~ahill

SRC_FILENAME="sbase-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd sbase/
    sed -E -i "s|^PREFIX.+|PREFIX = $TT_PREFIX|" config.mk
    sed -E -i "s|^MANPREFIX.+|MANPREFIX = $TT_DATADIR/man|" config.mk
    # NOTE: Some commands conflict with other packages (even ubase!), so we tell
    #       sbase not to build some commands. ~ahill

    export BIN="\
    cal chroot comm cron dirname ed expand expr false flock fold join \
    link logger logname mkfifo mktemp nice nohup paste patchchk printf pwd \
    renice rev seq sha512-224sum sha512-256sum split sponge tail tee test \
    tftp tr true uname unexpand unlink uudecode which whoami xinstall yes"

    # NOTE: Basic system utilities should be statically linked anyways. ~ahill
    make -e -j $TT_PROCS CFLAGS="$CFLAGS -static" LDFLAGS="$LDFLAGS -static"
    make -e -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -sf test "$TT_INSTALLDIR/bin/["
}
