#!/bin/sh
# This file is made with lines from bootstrap.sh to create a shell in case the
# bootstrap fails to build for whatever reason. Building a sysroot, especially
# with LLVM, takes a stupid amount of time and it makes it unreasonable to
# rebuild after something like diffutils fails to build. ~ahill

# The following script was created with:
# sh -c "grep export bootstrap.sh | sed /CCACHE/d; echo zsh" >> rescue.sh

export MICROARCH=skylake
export TARGET=x86_64-maple-linux-musl
export ARCH=$(echo $TARGET | cut -d"-" -f1)
export BOOTSTRAP=$(pwd)/.bootstrap
export PROCS=$(nproc)
export SOURCES=$(pwd)/.treetap/sources
export SPEC=$(pwd)/sources
export AR=llvm-ar
export AS=llvm-as
    export CC=clang
    export CXX=clang++
export CFLAGS="-fuse-ld=lld -O3 -march=$MICROARCH -pipe --sysroot=$BOOTSTRAP/root -Wno-unused-command-line-argument"
export CXXFLAGS=$CFLAGS
export RANLIB=llvm-ranlib
export LD=ld.lld
export LDFLAGS="--sysroot=$BOOTSTRAP/root"
export TREETAP=$(pwd)/treetap
export TT_DIR=$(pwd)/.treetap
export TT_MICROARCH=$MICROARCH
export TT_SYSROOT=$BOOTSTRAP/root
export TT_TARGET=$TARGET
export CFLAGS="$CFLAGS -Qunused-arguments -rtlib=compiler-rt -Wl,--dynamic-linker=/lib/ld-musl-$ARCH.so.1"
export CXXFLAGS="$CXXFLAGS -Qunused-arguments -rtlib=compiler-rt -Wl,--dynamic-linker=/lib/ld-musl-$ARCH.so.1"
export CFLAGS="$CFLAGS -unwindlib=libunwind"
export CXXFLAGS="$CXXFLAGS -isystem $BOOTSTRAP/root/usr/include/c++/v1 -nostdinc++ -stdlib=libc++ -unwindlib=libunwind"
export TT_DIR=$BOOTSTRAP/root/maple/.treetap
zsh
