#!/bin/sh -e
mkdir -p /etc/tinyramfs
echo "root=/dev/vda2" > /etc/tinyramfs/config
echo "root_type=xfs" >> /etc/tinyramfs/config
# FIXME: Setting monolith to true is a workaround since tinyramfs searches for
#        /sbin/kmod, which doesn't work since kmod is installed under /bin.
#        While kmod *should* be moved under /sbin, tinyramfs also shouldn't
#        hard-code paths like that, so we need a way to patch this going
#        forward. Without a proper patch, kernel modules cannot be added to the
#        initramfs, which will cause issues with drivers later on. ~ahill
echo "monolith=true" >> /etc/tinyramfs/config
# TODO: This is a terrible way to detect the kernel version, since anything
#       else under /lib/modules will cause this to break, such as having
#       multiple kernel versions present. ~ahill
tinyramfs -k $(ls /lib/modules) /boot/initramfs