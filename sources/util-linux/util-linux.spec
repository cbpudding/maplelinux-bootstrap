# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="25dc2fd70c6b6bec1c0c97cb11636edd2d5b2645df2324eef4820db3677bd412"
SRC_NAME="util-linux"
SRC_URL="https://github.com/util-linux/util-linux/archive/refs/tags/v2.41.3.tar.gz"
SRC_VERSION="2.41.3"

SRC_FILENAME="util-linux-$SRC_VERSION.tar.gz"
SRC_PATCHES="
64867fc3cd34263137f8db91839fad44f0096f76602a4281b3e542e344ae97cc  util-linux-byacc.patch
"

build() {
    tar xf ../$SRC_FILENAME
    cd util-linux-$SRC_VERSION/
    # NOTE: util-linux is hard-coded to use bison, so we need to patch the build
    #       script to use byacc. In addition to the difference in name, byacc
    #       has slightly different arguments, resulting in an error later on in
    #       the build. Because of this, the command line arguments are patched
    #       as well. ~ahill
    patch -p1 < ../util-linux-byacc.patch
    # NOTE: I'm not sure why, but muon doesn't seem to be able to build libfdisk
    #       and libmount, so they are disabled for now. ~ahill
    # NOTE: libsmartcols appears to rely on some bison-specific behavior that
    #       byacc seems to lack, so we aren't able to build the software at this
    #       time. ~ahill
    muon setup $TT_MESON_COMMON \
        -Dbuild-libfdisk=disabled \
        -Dbuild-libmount=disabled \
        -Dbuild-libsmartcols=disabled \
        -Dbuild-python=disabled \
        build
    muon samu -C build
    muon -C build install -d $TT_INSTALLDIR
}
