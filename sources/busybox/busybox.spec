# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="b8cc24c9574d809e7279c3be349795c5d5ceb6fdf19ca709f80cde50e47de314"
SRC_NAME="busybox"
SRC_URL="https://busybox.net/downloads/busybox-1.36.1.tar.bz2"
SRC_VERSION="1.36.1"

build() {
    tar xf ../$SRC_FILENAME
    cd busybox-*/
    # NOTE: For some reason, Busybox hard-codes GNU tools in the Makefile. This
    #       simple hack allows the environment to override the Makefile. ~ahill
    sed -i "s/?*= \$(CROSS_COMPILE)/?= /" Makefile
    make -O -j $TT_PROCS defconfig
    # FIXME: tc complains about undefined values, causing the compilation to
    #        fail. What causes this? ~ahill
    sed -i "s/CONFIG_TC=.*/CONFIG_TC=n/" .config
    make -O -j $TT_PROCS
}

clean() {
    rm -rf busybox-*/
}

package() {
    # NOTE: Busybox doesn't have a proper DESTDIR, so we just set CONFIG_PREFIX
    #       during the install to work around this limitation. ~ahill
    make -O -j $TT_PROCS install CONFIG_PREFIX=$TT_INSTALLDIR
}