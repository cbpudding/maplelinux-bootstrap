#!/bin/sh -e
export CC=clang
export CFLAGS="-O3 -pipe"
export CXX=clang++
export CXXFLAGS=$CFLAGS
export LD=ld.lld
export TT_MICROARCH=skylake

# Temporary workaround since root is the only user. ~ahill
export FORCE_UNSAFE_CONFIGURE=1

# xz Build
# NOTE: xz is needed to run "treetap build", so we manually build. ~ahill
cd /maple
XZ_VERSION=$(treetap variable /maple/sources/xz/xz.spec SRC_VERSION)
echo -n "Bootstrapping xz... "
cd .treetap/sources/xz/$XZ_VERSION
mkdir -p $TT_MICROARCH
cd $TT_MICROARCH
tar xf ../xz-*.tar*
cd xz-*/
./configure $(treetap variable /maple/sources/xz/xz.spec TT_AUTOCONF_COMMON) --disable-static --enable-year2038 > /maple/xz.log 2>&1
make -j $(nproc) >> /maple/xz.log 2>&1
make -j $(nproc) install DESTDIR=/ > /maple/xz.log 2>&1
echo "Done!"

# libarchive Build
# NOTE: bsdcpio is needed to run "treetap build", so we manually build.
#       ~ahill
cd /maple
LIBARCHIVE_VERSION=$(treetap variable /maple/sources/libarchive/libarchive.spec SRC_VERSION)
echo -n "Bootstrapping libarchive... "
cd .treetap/sources/libarchive/$LIBARCHIVE_VERSION
mkdir -p $TT_MICROARCH
cd $TT_MICROARCH
tar xf ../libarchive-*.tar*
cd libarchive-*/
./configure $(treetap variable /maple/sources/libarchive/libarchive.spec TT_AUTOCONF_COMMON) --disable-static --enable-year2038 > /maple/libarchive.log 2>&1
make -j $(nproc) > /maple/libarchive.log 2>&1
make -j $(nproc) install DESTDIR=/ > /maple/libarchive.log 2>&1
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
# NOTE: libcap2 requires zsh to build. ~ahill
# NOTE: Linux requires bc, byacc, flex, kmod, ... ~ahill
# NOTE: Limine requires nasm to build. ~ahill
# NOTE: OpenRC requires libcap2 and muon to build. ~ahill
cd /maple
LAYER0="bc byacc bzip2 coreutils diffutils findutils grep gzip initramfs-tools libressl m4 make mawk muon musl ncurses patch perl pkgconf sed tar xz zlib zsh"
LAYER1="autoconf automake flex groff libarchive libcap2 libelf libtool nano openrc"
LAYER2="cmake dash fortune-mod kmod nasm"
LAYER3="limine linux"
PACKAGES="$LAYER0 $LAYER1 $LAYER2 $LAYER3"
for pkg in $PACKAGES; do
    treetap fetch /maple/sources/$pkg/$pkg.spec
    treetap build /maple/sources/$pkg/$pkg.spec
    treetap install $(treetap variable /maple/sources/$pkg/$pkg.spec TT_PACKAGE)
done
