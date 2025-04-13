#!/bin/sh
MAPLE=$(pwd)/maple

if mount --rbind /dev $MAPLE/dev && mount --make-rslave $MAPLE/dev; then
    if mount -t proc /proc $MAPLE/proc; then
        if mount --rbind /sys $MAPLE/sys && mount --make-rslave $MAPLE/sys; then
            if mount --rbind /tmp $MAPLE/tmp; then
                if mount --bind /run $MAPLE/run; then
                    if [ -d $MAPLE/maple/sources ]; then
                        if mount --bind ./sources $MAPLE/maple/sources; then
                            chroot $MAPLE /bin/sh
                            umount $MAPLE/maple/sources
                        fi
                    else
                        chroot $MAPLE /bin/sh
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