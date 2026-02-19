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
    sed -i '/basename\\/d' Makefile
    sed -i '/bc\\/d' Makefile
    sed -i '/cat\\/d' Makefile
    sed -i '/chgrp\\/d' Makefile
    sed -i '/chmod\\/d' Makefile
    sed -i '/chown\\/d' Makefile
    sed -i '/cksum\\/d' Makefile
    sed -i '/cmp\\/d' Makefile
    sed -i '/cp\\/d' Makefile
    sed -i '/cut\\/d' Makefile
    sed -i '/date\\/d' Makefile
    sed -i '/dc\\/d' Makefile
    sed -i '/dd\\/d' Makefile
    sed -i '/du\\/d' Makefile
    sed -i '/echo\\/d' Makefile
    sed -i '/env\\/d' Makefile
    sed -i '/find\\/d' Makefile
    sed -i '/getconf\\/d' Makefile
    sed -i '/grep\\/d' Makefile
    sed -i '/head\\/d' Makefile
    sed -i '/hostname\\/d' Makefile
    sed -i '/kill\\/d' Makefile
    sed -i '/ln\\/d' Makefile
    sed -i '/ls\\/d' Makefile
    sed -i '/make\\/d' Makefile
    sed -i '/md5sum\\/d' Makefile
    sed -i '/mkdir\\/d' Makefile
    sed -i '/mv\\/d' Makefile
    sed -i '/nl\\/d' Makefile
    sed -i '/od\\/d' Makefile
    sed -i '/printenv\\/d' Makefile
    sed -i '/readlink\\/d' Makefile
    sed -i '/rm\\/d' Makefile
    sed -i '/rmdir\\/d' Makefile
    sed -i '/sed\\/d' Makefile
    sed -i '/setsid\\/d' Makefile
    sed -i '/sha1sum\\/d' Makefile
    sed -i '/sha224sum\\/d' Makefile
    sed -i '/sha256sum\\/d' Makefile
    sed -i '/sha384sum\\/d' Makefile
    sed -i '/sha512sum\\/d' Makefile
    sed -i '/sleep\\/d' Makefile
    sed -i '/sort\\/d' Makefile
    sed -i '/strings\\/d' Makefile
    sed -i '/sync\\/d' Makefile
    sed -i '/tar\\/d' Makefile
    sed -i '/time\\/d' Makefile
    sed -i '/touch\\/d' Makefile
    sed -i '/tty\\/d' Makefile
    sed -i '/uniq\\/d' Makefile
    sed -i '/wc\\/d' Makefile
    sed -i '/xargs\\/d' Makefile
    # NOTE: Basic system utilities should be statically linked anyways. ~ahill
    make -j $TT_PROCS CFLAGS="$CFLAGS -static" LDFLAGS="$LDFLAGS -static"
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
    ln -sf test "$TT_INSTALLDIR/bin/["
}
