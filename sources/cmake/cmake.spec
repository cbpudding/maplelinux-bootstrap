# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="4104e94657d247c811cb29985405a360b78130b5d51e7f6daceb2447830bd579"
SRC_NAME="cmake"
SRC_URL="https://github.com/Kitware/CMake/releases/download/v4.2.0/cmake-4.2.0.tar.gz"
SRC_VERSION="4.2.0"

build() {
    tar xf ../$SRC_FILENAME
    cd cmake-*/
    # NOTE: CMake's bootstrap script is strange because *everything* is located
    #       under the prefix, whether you like it or not. We're making use of
    #       /usr/bin this way, which is something I would like to avoid. ~ahill
    ./bootstrap \
        --parallel=$TT_PROCS \
        --prefix=/usr \
        --system-bzip2 \
        --system-libarchive \
        --system-liblzma \
        --system-zlib
    make -O -j $TT_PROCS
}

clean() {
    rm -rf cmake-*/
}

package() {
    cd cmake-*/
    make -O -j $TT_PROCS install DESTDIR=$TT_INSTALLDIR
}