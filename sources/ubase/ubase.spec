# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="962ea0f6e91f9557121bc1c9e44fb9b303dd33a4ba39c3ac0d18c5eb0db3d1c6"
SRC_NAME="ubase"
SRC_REVISION=1
SRC_URL="https://linux.maple.camp/git/mirror/ubase/archive/e8249b49ca3e02032dece5e0cdac3d236667a6d9.tar.gz"
SRC_VERSION="e8249b4"

# NOTE: ubase hasn't had a tag created in twelve years, and significant progress
#       has been made since then. To get the version number, I'm using:
#           git describe --always --tags
#       This seems to work well, but I'm not sure why it doesn't detect the last
#       tag that was created. Doing a deeper dive reveals a different commit
#       hash for the tagged version, despite being the same thing. Maybe someone
#       smarter than me can figure it out?
# https://linux.maple.camp/git/mirror/ubase/commit/c3341ac588dd6675f8e8725b72ab214c1042721d
# https://linux.maple.camp/git/mirror/ubase/commit/fffdb91ada0cc1af981ad8a36a4f5a64b5fa819d

SRC_FILENAME="ubase-$SRC_VERSION.tar.gz"

build() {
    tar xzf ../$SRC_FILENAME
    cd ubase/
    sed -E -i "s|^PREFIX.+|PREFIX = $TT_PREFIX|" config.mk
    sed -E -i "s|^MANPREFIX.+|MANPREFIX = $TT_DATADIR/man|" config.mk
    # NOTE: Some commands conflict with other packages (even sbase!), so we tell
    #       ubase not to build some commands. ~ahill
    export BIN="\
    chvt ctrlaltdel fallocate freeramdisk fsfreeze getty halt last lastlog \
    mesg mountpoint nologin pagesize passwd pivot_root pwdx readahead respawn \
    swaplabel swapoff swapon truncate vtallow who"

    export MAN8="\
    ctrlaltdel.8 freeramdisk.8 fsfreeze.8 getty.8 halt.8 lastlog.8 nologin.8 \
    pivot_root.8 readahead.8 swaplabel.8 swapoff.8 swapon.8 sysctl.8"

    export MAN1="\
    chvt.1 fallocate.1 mesg.1 mountpoint.1 pagesize.1 passwd.1 pwdx.1 respawn.1 \
    truncate.1 vtallow.1 who.1"

    # NOTE: Basic system utilities should be statically linked anyways. ~ahill
    sed -E -i "/^(C|LD)FLAGS/s/$/ -static/" config.mk
    # NOTE: When bootstrapping, the Makefile applies LDFLAGS to the compilation,
    #       but not CFLAGS, resulting in it attempting to use the host's
    #       libraries. Due to the nature of ubase, we can set LDFLAGS to CFLAGS.
    #       ~ahill
    make -e -j $TT_PROCS LDFLAGS="$CFLAGS"
    make -e -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
