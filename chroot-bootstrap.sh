#!/bin/sh
MAPLE=$(pwd)/maple

run_chroot() {
    SHELL=/bin/sh
    if [ -e $MAPLE/bin/zsh ]; then
        SHELL=/bin/zsh
    fi
    chroot $MAPLE $SHELL
}

if mount --rbind /dev $MAPLE/dev && mount --make-rslave $MAPLE/dev; then
    if mount -t proc /proc $MAPLE/proc; then
        if mount --rbind /sys $MAPLE/sys && mount --make-rslave $MAPLE/sys; then
            if mount --rbind /tmp $MAPLE/tmp; then
                if mount --bind /run $MAPLE/run; then
                    if [ -d $MAPLE/maple/sources ]; then
                        if mount --bind ./sources $MAPLE/maple/sources; then
                            run_chroot
                            umount $MAPLE/maple/sources
                        fi
                    else
                        run_chroot
                    fi
                    umount $MAPLE/run
                fi
                umount $MAPLE/tmp
            fi
            umount -R $MAPLE/sys
        fi
        umount $MAPLE/proc
    fi
    umount -R $MAPLE/dev
fi