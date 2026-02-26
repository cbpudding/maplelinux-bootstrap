# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9332213d35480b647086a70c302de8568de83455a98774d35de216c4ce191006"
SRC_NAME="iproute2"
SRC_URL="https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.19.0.tar.xz"
SRC_VERSION="6.19.0"

build() {
    tar xJf ../$SRC_FILENAME
    cd iproute2-$SRC_VERSION/
    # NOTE: Don't use TT_AUTOCONF_COMMON for this because this isn't based on
    #       autoconf. ~ahill
    ./configure \
        --color=auto \
        --includedir=$TT_INCLUDEDIR \
        --libdir=$TT_LIBDIR \
        --prefix=$TT_PREFIX
    # NOTE: It appears that some of the header files rely on the automatic
    #       inclusion of linux/types.h, which should be considered bad practice.
    #       ~ahill
    sed -i "/#define __COLOR_H__ 1/a#include <linux/types.h>" include/color.h
    sed -i "/#define _JSON_PRINT_H_/a#include <linux/types.h>" include/json_print.h
    # NOTE: Yet another Makefile ignoring environment variables... ~ahill
    make -j $TT_PROCS HOSTCC=$CC
    make -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}
