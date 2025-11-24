#!/bin/sh -e
export CFLAGS="-O3 -pipe"
export CXXFLAGS=$CFLAGS

# xz Build
cd /maple
treetap build sources/xz/xz.spec
cd .treetap/sources/xz/*/*/xz-*/
make -j $(nproc) install DESTDIR=/

# libarchive Build
cd /maple
treetap build sources/libarchive/libarchive.spec
cd .treetap/sources/libarchive/*/*/libarchive-*/
make -j $(nproc) install DESTDIR=/

# Now we can build stuff exclusively with treetap
# NOTE: bzip2, xz, and zlib need to be built before libarchive or we will be
#       missing functionality! ~ahill
# NOTE: CMake requires LibreSSL and libarchive to function properly so it is
#       built after that. ~ahill
PACKAGES="bzip2 libressl make musl xz zlib libarchive cmake"
for pkg in $PACKAGES; do
    treetap fetch sources/$pkg/$pkg.spec
    treetap build sources/$pkg/$pkg.spec
    treetap package sources/$pkg/$pkg.spec
    treetap install .treetap/packages/*/$pkg-*.cpio.xz
done