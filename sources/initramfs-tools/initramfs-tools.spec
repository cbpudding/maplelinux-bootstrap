# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="initramfs-tools-0.150.tar.gz"
SRC_HASH="d2578bed875b65962dfb51fae3bea8af11765ae76d1d66708fffef1fd3512a0c"
SRC_NAME="initramfs-tools"
SRC_URL="https://salsa.debian.org/kernel-team/initramfs-tools/-/archive/v0.150/initramfs-tools-v0.150.tar.gz"
SRC_VERSION="0.150"

build() {
    tar xf ../$SRC_FILENAME
    cd initramfs-tools-*/
    # NOTE: Since this is for a single file, we don't pass TT_PROC. ~ahill
    make
}

clean() {
    rm -rf initramfs-tools-*/
}

package() {
    cd initramfs-tools-*/

    # NOTE: There's no make install! ~ahill
    mkdir -p $TT_INSTALLDIR/bin
    cp lsinitramfs $TT_INSTALLDIR/bin/
    cp mkinitramfs $TT_INSTALLDIR/bin/
    cp unmkinitramfs $TT_INSTALLDIR/bin/
    cp update-initramfs $TT_INSTALLDIR/bin/

    mkdir -p $TT_INSTALLDIR/etc/initramfs-tools
    cp conf/initramfs.conf $TT_INSTALLDIR/etc/initramfs-tools/
    cp conf/update-initramfs.conf $TT_INSTALLDIR/etc/initramfs-tools/

    mkdir -p $TT_INSTALLDIR/usr/share/bash-completion/completions
    cp bash_completion.d/update-initramfs $TT_INSTALLDIR/usr/share/bash-completion/completions/

    mkdir -p $TT_INSTALLDIR/usr/share/initramfs-tools
    cp hook-functions $TT_INSTALLDIR/usr/share/initramfs-tools/
    cp -r hooks $TT_INSTALLDIR/usr/share/initramfs-tools/
    cp init $TT_INSTALLDIR/usr/share/initramfs-tools/
    cp conf/modules $TT_INSTALLDIR/usr/share/initramfs-tools/
    cp -r scripts $TT_INSTALLDIR/usr/share/initramfs-tools/

    mkdir -p $TT_INSTALLDIR/usr/share/man/man5
    cp initramfs.conf.5 $TT_INSTALLDIR/usr/share/man/man5/
    cp update-initramfs.conf.5 $TT_INSTALLDIR/usr/share/man/man5/

    mkdir -p $TT_INSTALLDIR/usr/share/man/man7
    cp initramfs-tools.7 $TT_INSTALLDIR/usr/share/man/man7/

    mkdir -p $TT_INSTALLDIR/usr/share/man/man8
    cp lsinitramfs.8 $TT_INSTALLDIR/usr/share/man/man8/
    cp mkinitramfs.8 $TT_INSTALLDIR/usr/share/man/man8/
    cp unmkinitramfs.8 $TT_INSTALLDIR/usr/share/man/man8/
    cp update-initramfs.8 $TT_INSTALLDIR/usr/share/man/man8/
}