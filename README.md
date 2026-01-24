# Maple Linux Bootstrap Scripts

This repository contains the scripts used to build Maple Linux from the source code.

## Maple Linux Philosophy

Maple Linux was designed to be much more than "yet another Linux distribution", and aims to achieve the following goals (in no particular order):

- Provide a fully functional operating system with as few moving parts as possible
- Take advantage of modern advancements in hardware
- Provide a unified user experience, where the various software all behave as one coherent operating system

While it may sound too good to be true, that's because it is. Maple Linux does not aim to be a "fix everything" solution, and compromises on the following:

- Reducing the number of moving parts in an operating system will naturally make certain software (particularly, proprietary software) incompatible with Maple Linux. An effort will be made to maintain the balance between functionality and minimalism to make the user experience as enjoyable as possible while keeping maintenance costs low.
- By taking advantage of newer hardware, we are making the system incompatible with older machines. This isn't to say that Maple Linux *shouldn't* be run on older machines, but rather that it is out of scope for this project. If you want to make this run on your own hardware, then by all means, go right ahead. That's the beauty of open source.
- In order to achieve the "unified" experience, the software you are given has been pre-determined so we can focus on optimizing Maple Linux as a whole. This makes it far less generic and customizable, but offers a much more coherent and focused system overall. In addition, this makes it much more maintainable for a single developer such as myself.

### Licensing

Maple Linux is built upon software created by various developers, and is distributed under various licenses as a result. While it isn't one of the main goals of the system, especially since Linux itself is copyleft, I aim to create an operating system that's as free as I can reasonably make it.

![Licensing Summary](licensebar.svg)

For more information about the software included in this project and its licensing, see [SOFTWARE.md](./SOFTWARE.md).

### Filesystem Hierarchy

Maple Linux uses a slightly different filesystem hierarchy compared to most Linux systems, but it shouldn't be enough to become incompatible with existing software. The following are the notable changes:

- `/bin` - This is the canonical location for all system-level binaries. Paths such as `/sbin`, `/usr/bin`, and `/usr/sbin` should be considered legacy. See also: https://lists.busybox.net/pipermail/busybox/2010-December/074114.html
- `/boot` - This is the mount point for the EFI System Partition
- `/lib` - This is the canonical location for all system-level libraries. Paths such as `/usr/lib` and `/usr/libexec` should be considered legacy.

Many of alternative paths are symlinked for compatibility's sake.
