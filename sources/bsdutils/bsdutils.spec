# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="bsdutils-13.2.tar.gz"
SRC_HASH="4547990309afe686c6f36c2a4f7ac5806e0064b182dd1f93f52dda7661979a3c"
SRC_NAME="bsdutils"
SRC_URL="https://codeberg.org/dcantrell/bsdutils/archive/v13.2.tar.gz"
SRC_VERSION="13.2"

# TODO: Determine which utilities should be moved to bsdutils and which should
#       stick with Busybox. ~ahill
# [
# bc
# cat
# chgrp
# chmod
# chown
# chroot
# cksum
# comm
# cp
# csplit
# cut
# date
# dc
# dd
# dirname
# du
# echo
# env
# expand
# expr
# factor
# false
# fmt
# fold
# groups
# head
# hexdump
# hostname
# id
# install
# join
# kill
# ln
# logname
# ls
# mkdir
# mkfifo
# mknod
# mktemp
# mv
# nice
# nl
# nohup
# paste
# pathchk
# pr
# printenv
# printf
# pwd
# readlink
# realpath
# rm
# rmdir
# sed
# seq
# sleep
# split
# stat
# stdbuf
# stty
# sync
# tail
# tee
# test
# timeout
# touch
# tr
# true
# truncate
# tsort
# tty
# uname
# unexpand
# uniq
# unlink
# users
# which
# who
# whoami
# xargs
# yes

build() {
    tar xf ../$SRC_FILENAME
    cd bsdutils/
    # NOTE: Before we start building bsdutils, we tell it *not* to build df/wc,
    #       since that requires an additional dependency (libxo) and we already
    #       have BusyBox's version of df and wc to replace it. ~ahill
    sed -i "/libxo/d" meson.build
    sed -i "/'df'/d" src/meson.build
    sed -i "/'wc'/d" src/meson.build
    # NOTE: Apparently, rpmatch is REQUIRED, despite meson.build stating that it
    #       is optional. Disabling find in favor of BusyBox to prevent another
    #       dependency from being introduced. ~ahill
    sed -i "/'find'/d" src/meson.build
    # NOTE: Finally, we have a *lot* of duplicate commands between bsdutils and
    #       Busybox. Busybox takes priority unless the bsdutils version has more
    #       functionality. ~ahill
    # ...
    muon setup $TT_MESON_COMMON build
    muon samu -C build
}

clean() {
    rm -rf bsdutils/
}

package() {
    cd bsdutils/
    muon -C build install -d $TT_INSTALLDIR
}