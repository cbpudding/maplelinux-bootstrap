# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="e093ef184d7f9a1b9797e2465296f55510adb6dab8842b0c3ed53329663096dc"
SRC_NAME="perl"
SRC_URL="https://www.cpan.org/src/5.0/perl-5.42.0.tar.gz"
SRC_VERSION="5.42.0r1"

build() {
    tar xf ../$SRC_FILENAME
    cd perl-*/
    # NOTE: Not a Perl user, so I hope I don't screw this up. ~ahill
    ./Configure -des \
        -D bin=$TT_BINDIR \
        -D installstyle=lib/perl5 \
        -D prefix=$TT_PREFIX \
        -D scriptdir=$TT_BINDIR \
        -D sysroot=$TT_SYSROOT \
        -D useshrplib \
        -D usethreads \
        -D usrinc=$TT_INCLUDEDIR \
        -D vendorprefix=$TT_PREFIX
    make -O -j $TT_PROCS
}

clean() {
    rm -rf perl-*/
}

package() {
    cd perl-*/
    make -O -j $TT_PROCS install.perl DESTDIR=$TT_INSTALLDIR
}
