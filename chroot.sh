#!/bin/sh -e
mount --rbind /dev $1/dev
mount --make-rslave $1/dev
mount -t proc /proc $1/proc
mount --rbind /sys $1/sys
mount --make-rslave $1/sys
mount --rbind /tmp $1/tmp
mount --bind /run $1/run
chroot $1 /bin/sh
umount -lf $1/run
umount -lf $1/tmp
umount -lf $1/sys
umount -lf $1/proc
umount -lf $1/dev
