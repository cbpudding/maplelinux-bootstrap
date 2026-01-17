#!/bin/sh -e
export CC=clang
export CFLAGS="-O3 -pipe"
export CXX=clang++
export CXXFLAGS=$CFLAGS

# Temporary workaround since root is the only user. ~ahill
export FORCE_UNSAFE_CONFIGURE=1

# xz Build
# NOTE: xz is needed to run "treetap package", so we manually install. ~ahill
cd /maple
treetap build sources/xz/xz.spec
cd .treetap/sources/xz/*/*/xz-*/
echo -n "Bootstrapping xz... "
make -j $(nproc) install DESTDIR=/ > /dev/null 2>&1
echo "Done!"

# libarchive Build
# NOTE: bsdcpio is needed to run "treetap package", so we manually install.
#       ~ahill
cd /maple
treetap build sources/libarchive/libarchive.spec
cd .treetap/sources/libarchive/*/*/libarchive-*/
echo -n "Bootstrapping libarchive... "
make -j $(nproc) install DESTDIR=/ > /dev/null 2>&1
echo "Done!"

# Now we can build stuff exclusively with treetap
# NOTE: bzip2, xz, and zlib need to be built before libarchive or we will be
#       missing functionality! ~ahill
# NOTE: CMake requires LibreSSL and libarchive to function properly so it is
#       built after them. ~ahill
# NOTE: flex requires byacc and m4 to build. ~ahill
# NOTE: autoconf requires GNU m4 and perl to build. ~ahill
# NOTE: automake requires m4 to build. ~ahill
# NOTE: groff requires Perl to build. ~ahill
# NOTE: nasm requires autoconf and automake to build. ~ahill
# NOTE: dash requires flex and mawk to build. ~ahill
# NOTE: libelf requires zlib to build. ~ahill
# NOTE: fortune-mod requires cmake to build. ~ahill
# NOTE: nano requires ncurses to build. ~ahill
# NOTE: kmod requires autoconf, automake, libtool to build. ~ahill
# NOTE: Linux requires bc, byacc, flex, kmod, ... ~ahill
cd /maple
LAYER0="bc byacc bzip2 coreutils diffutils findutils grep gzip libressl m4 make mawk muon musl ncurses patch perl pkgconf sed tar xz zlib zsh"
LAYER1="autoconf automake flex groff libarchive libelf libtool nano"
LAYER2="dash nasm cmake fortune-mod kmod linux"
PACKAGES="$LAYER0 $LAYER1 $LAYER2"
for pkg in $PACKAGES; do
    treetap fetch /maple/sources/$pkg/$pkg.spec
    treetap build /maple/sources/$pkg/$pkg.spec
    treetap install $(treetap variable /maple/sources/$pkg/$pkg.spec TT_PACKAGE)
done
