#!/bin/sh -e
dd if=/dev/zero of=maple.img bs=1G count=16
# TODO: Replace parted with sfdisk to reduce the number of dependencies required
#       to build Maple Linux. ~ahill
parted --script maple.img \
    mklabel gpt \
    mkpart fat32 0% 512M \
    mkpart xfs 512M 100% \
    set 1 esp on
# FIXME: If we adjust the partition table above, these numbers are no longer
#        accurate. Is there a way to automate this process in a rootless
#        fashion? ~ahill
# FIXME: This process also gets slower with larger images. Is there a way to
#        treat a specific offset and length of a file as its own file handle?
#        ~ahill
dd if=/dev/zero of=maple.img1 count=997375
mkfs.fat -F32 maple.img1
dd if=maple.img1 of=maple.img seek=2048 conv=notrunc
rm maple.img1
dd if=/dev/zero of=maple.img2 count=31457280
mkfs.xfs maple.img2
dd if=maple.img2 of=maple.img seek=999424 conv=notrunc
rm maple.img2