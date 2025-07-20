# Maple Linux Bootstrap Scripts

This repository contains the scripts used to build Maple Linux from the source code. Most users will want to download a tarball from [here](https://maple.camp/linux/) to install Maple Linux. For everyone else, contributions are welcome!

## System Requirements

- Intel Core i3-6100 or greater
- At least 1 GB of storage space

## Installing Maple Linux (For Most Users)

Once you have a tarball downloaded from the repository above, you can begin installing Maple Linux.

### Building the System Image

First, you will need to start with a storage device that is around 4 GB in size (although, you can probably get away with less if you're brave). The first 512 MB should be an EFI System Partition (FAT32), and the remainder of the disk should be formatted as XFS. The following is an example of formatting the disk with `parted`, where `/dev/sdX` is the disk of your choice:

```
# parted /dev/sdX
GNU Parted 3.6
Using /dev/sdX
Welcome to GNU Parted! Type 'help' to view a list of commands.
(parted) mklabel gpt
(parted) mkpart fat32 0% 512M                                             
(parted) mkpart xfs 512M 100%
(parted) set 1 esp on
(parted) quit
```

That doesn't actually format the partitions, so we'll need to do that next:

```
# mkfs.fat -F32 /dev/sdX1
mkfs.fat 4.2 (2021-01-31)
# mkfs.xfs /dev/sdX2
meta-data=/dev/sdX2              isize=512    agcount=4, agsize=1017280 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=1
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=1
         =                       exchange=0   metadir=0
data     =                       bsize=4096   blocks=4069120, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1, parent=0
log      =internal log           bsize=4096   blocks=19237, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
         =                       rgcount=0    rgsize=0 extents
         =                       zoned=0      start=0 reserved=0
Discarding blocks...Done.
```

Now that our image has been formatted correctly, we can extract the contents of Maple Linux to the disk. We'll start by creating a mount point for the root partition before mounting it and the boot partition.

```
# mkdir maple
# mount /dev/sdX2 maple
# mkdir maple/boot
# mount /dev/sdX1 maple/boot
```

Now that the image has been formatted properly, we can extract the contents of the tarball onto the system image:

```
# cd maple
# tar xf ../maplelinux-202507201645.tar.xz
```

### Configuring Limine

To configure Limine, simply open `maple/boot/limine` in your text editor of choice. The only thing you *may* need to change is the value of `kernel_cmdline`. By default, it points to `/dev/vda2`, which is the default for a VirtIO disk on KVM. Of course, you can do [much more to customize your system](https://github.com/limine-bootloader/limine/blob/v9.x/CONFIG.md), but it is not required to boot.

### Writing /etc/fstab

Once again, you can change the fstab by opening `maple/etc/fstab` in your favorite text editor. The only two lines I would recommend changing are the first two unless you know what you're doing. The first line references the root partition and the second line references the boot partition. They are set to `/dev/vda2` and `/dev/vda1` respectively, as those are what KVM defaults to with a single VirtIO disk configured. This is what fstab should look like by default:

```
/dev/vda2 /              xfs      defaults            1 1
/dev/vda1 /boot          vfat     defaults            0 2
proc      /proc          proc     nosuid,noexec,nodev 0 0
sysfs     /sys           sysfs    nosuid,noexec,nodev 0 0
devpts    /dev/pts       devpts   gid=5,mode=620      0 0
tmpfs     /run           tmpfs    defaults            0 0
devtmpfs  /dev           devtmpfs mode=0755,nosuid    0 0
tmpfs     /dev/shm       tmpfs    nosuid,nodev        0 0
cgroup2   /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0 0
```

### Building initramfs

Last, but certainly not least, is the initramfs. We'll start by creating the `maple/etc/tinyramfs` folder, which we'll use to store `maple/etc/tinyramfs/config`. Once again, `root` should be set to the root partition on your system.

```
root=/dev/vda2
root_type=xfs
monolith=true
```

Once the initramfs builder has been configured, we can `chroot` into the image one final time, check the installed kernel version by listing the contents of `/lib/modules` (there should only be one subfolder), and invoking `tinyramfs` to build the initramfs for boot.

```
# chroot maple zsh
hostname# ls /lib/modules
6.15.4-maple
hostname# tinyramfs -k 6.15.4-maple /boot/initramfs
>> creating ramfs structure
>> generating initramfs image
+> done: /boot/initramfs
hostname# exit
```

With that, we can umount the image and boot into Maple Linux!

## Building Maple Linux

Building Maple Linux is mostly an automated process at this point. Here is a summary of the scripts provided in this repository, in order of execution (assuming nothing goes wrong):

- `./fetch-sources.sh` - Downloads the sources and verifies their hashes against what is in `sources.list`
- `./build-bootstrap.sh` - Extracts and builds the bare minimum to build the remainder of the image in a `chroot`
- `./chroot-bootstrap.sh` - `chroot`s into the image with all the appropriate mounts 
- `./build-chroot.sh` - Extracts and builds the system image from inside of the `chroot`

This process has been known to take *hours*, so it's best not to do this unless you're sure you want to do it this way. Once you have a working bootstrap, it is recommended to back that up before proceeding with the chroot build so you can easily restore your progress without waiting for hours to get a new bootstrap. Of course, if you need to change LLVM for any reason, you will need to bootstrap the system again...

Once you have a working image, you can follow the steps above to install the image normally. If you have any suggestions to improve the system or its build process, please make a pull request or issue!

## Maple Linux Philosophy

Maple Linux was designed to be much more than "yet another Linux distribution", and aims to achieve the following goals (in no particular order):

- Provide a fully functional operating system with as few moving parts as possible
- Take advantage of modern advancements in hardware
- Provide a unified user experience, where the various software all behave as one coherent operating system

While it may sound too good to be true, that's because it is. Maple Linux does not aim to be a "fix everything" solution, and compromises on the following:

- Reducing the number of moving parts in an operating system will naturally make certain software (particularly, proprietary software) incompatible with Maple Linux. An effort will be made to maintain the balance between functionality and minimalism to make the user experience as enjoyable as possible while keeping maintenance costs low.
- By taking advantage of newer hardware, we are making the system incompatible with older machines. This isn't to say that Maple Linux *shouldn't* be run on older machines, but rather that it is out of scope for this project. If you want to make this run on your own hardware, then by all means, go right ahead. That's the beauty of open source.
- In order to achieve the "unified" experience, the software you are given has been pre-determined so we can focus on optimizing Maple Linux as a whole. This makes it far less generic and customizable, but offers a much more coherent and focused system overall. In addition, this makes it much more maintainable for a single developer such as myself.

### Filesystem Hierarchy

Maple Linux uses a slightly different filesystem hierarchy compared to most Linux systems, but it shouldn't be enough to become incompatible with existing software. The following are the notable changes:

- `/bin` - This is the canonical location for all system-level binaries. Paths such as `/usr/bin` should be considered legacy. See also: https://lists.busybox.net/pipermail/busybox/2010-December/074114.html
- `/boot` - This is the mount point for the EFI System Partition
- `/lib` - This is the canonical location for all system-level libraries. Paths such as `/usr/lib` should be considered legacy.
- `/sbin` - This is the canonical location for all system-level binaries that require superuser privileges to run. Paths such as `/usr/sbin` should be considered legacy.

Many of alternative paths are symlinked for compatibility's sake.