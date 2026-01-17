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

| Software                      | Copyright Holder                                    | License                                                                                | Alignment          |
| ----------------------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------- | ------------------ |
| Autoconf                      | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| Automake                      | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| GNU bc                        | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| Berkeley Yacc                 | Public Domain                                       | Public Domain                                                                          | Free               |
| bzip2                         | Julian R. Seward                                    | Modified Zlib license                                                                  | Free               |
| CMake                         | Kitware, Inc. and Contributors                      | BSD 3-Clause license                                                                   | Free               |
| Coreutils                     | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| Debian Almquist Shell         | Various                                             | Modified BSD 3-Clause license(?) *and* GNU General Public License version 3            | Slightly Copyleft  |
| GNU Diffutils                 | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| GNU Find Utilities            | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| Flex                          | Various                                             | BSD 2-Clause license                                                                   | Free               |
| fortune-mod                   | Various                                             | BSD 4-Clause license                                                                   | Free               |
| GNU Grep                      | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| GNU roff                      | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| GNU Gzip                      | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| initramfs-tools               | Various                                             | GNU General Public License version 2                                                   | Copyleft           |
| kmod                          | Various                                             | GNU Lesser General Public License version 2.1                                          | Copyleft           |
| libarchive                    | Tim Kientzle                                        | Mostly BSD 2-Clause license                                                            | Free               |
| libcap                        | Andrew G. Morgan                                    | BSD 3-Clause license *or* GNU General Public License version 2                         | Slightly Copyleft  |
| libelf                        | Various                                             | GNU General Public License version 2 *and* GNU Lesser General Public License version 3 | Copyleft           |
| LibreSSL                      | Various                                             | Various                                                                                | Free               |
| The GNU Portable Library Tool | Free Software Foundation, Inc.                      | GNU General Public License version 2                                                   | Copyleft           |
| Limine                        | Mintsuki and Contributors                           | BSD 2-Clause license                                                                   | Free               |
| Linux                         | Linus Torvalds and Contributors                     | Mostly GNU General Public License version 2 with Linux Syscall Note                    | Copyleft           |
| LLVM                          | Various                                             | Mostly Apache License version 2.0 with LLVM exceptions                                 | Free               |
| GNU m4                        | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| GNU Make                      | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| Maple Linux Bootstrap Scripts | Alexander Hill, Nicholas McDaniel, and Contributors | ISC License                                                                            | Free               |
| Mawk                          | Various                                             | GNU General Public License version 2                                                   | Copyleft           |
| muon                          | Stone Tickle and Contributors                       | GNU General Public License version 3                                                   | Copyleft           |
| musl                          | Rich Felker and Contributors                        | Mostly MIT License                                                                     | Slightly Copyright |
| GNU nano                      | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| The Netwide Assembler         | "The NASM Authors"                                  | BSD 2-Clause license                                                                   | Free               |
| New Curses                    | Thomas E. Dickey and Free Software Foundation, Inc. | Modified MIT License                                                                   | Free               |
| OpenRC                        | Roy Marples and the OpenRC authors                  | BSD 2-Clause license                                                                   | Free               |
| GNU patch                     | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| Perl                          | Larry Wall and others                               | GNU General Public License version 1                                                   | Copyleft           |
| pkgconf                       | Various                                             | ISC License                                                                            | Free               |
| GNU sed                       | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| GNU tar                       | Free Software Foundation, Inc.                      | GNU General Public License version 3                                                   | Copyleft           |
| xz                            | Various                                             | Mostly BSD 0-Clause license                                                            | Slightly Copyleft  |
| Zlib                          | Jean-loup Gailly and Mark Adler                     | Zlib License                                                                           | Free               |
| Zsh                           | The Zsh development group                           | Mostly MIT License (Modern Variant)                                                    | Slightly Copyleft  |

If any of the information listed above is inaccurate, please submit a patch to correct the README. ~ahill

### Filesystem Hierarchy

Maple Linux uses a slightly different filesystem hierarchy compared to most Linux systems, but it shouldn't be enough to become incompatible with existing software. The following are the notable changes:

- `/bin` - This is the canonical location for all system-level binaries. Paths such as `/sbin`, `/usr/bin`, and `/usr/sbin` should be considered legacy. See also: https://lists.busybox.net/pipermail/busybox/2010-December/074114.html
- `/boot` - This is the mount point for the EFI System Partition
- `/lib` - This is the canonical location for all system-level libraries. Paths such as `/usr/lib` and `/usr/libexec` should be considered legacy.

Many of alternative paths are symlinked for compatibility's sake.
