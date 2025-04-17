#!/bin/sh -e

# User/Group Generation
echo "root:x:0:0::/home/root:/bin/zsh" > /etc/passwd
echo "root:x:0:root" > /etc/group

# fstab Generation
# TODO: Is the dump column still used today? ~ahill
echo "/dev/vda2 /              xfs      defaults            1 1" > /etc/fstab
echo "/dev/vda1 /boot          vfat     defaults            0 2" >> /etc/fstab
echo "proc      /proc          proc     nosuid,noexec,nodev 0 0" >> /etc/fstab
echo "sysfs     /sys           sysfs    nosuid,noexec,nodev 0 0" >> /etc/fstab
echo "devpts    /dev/pts       devpts   gid=5,mode=620      0 0" >> /etc/fstab
echo "tmpfs     /run           tmpfs    defaults            0 0" >> /etc/fstab
echo "devtmpfs  /dev           devtmpfs mode=0755,nosuid    0 0" >> /etc/fstab
echo "tmpfs     /dev/shm       tmpfs    nosuid,nodev        0 0" >> /etc/fstab
echo "cgroup2   /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0 0" >> /etc/fstab

# initramfs Generation
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