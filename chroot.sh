#!/bin/sh
mount -o rbind /dev $1/dev
mount -t proc none $1/proc
mount -o bind /sys $1/sys
mount -o bind /tmp $1/tmp
chroot $1 /bin/sh
umount -f $1/tmp
umount -f $1/sys
umount -f $1/proc
umount -lf $1/dev