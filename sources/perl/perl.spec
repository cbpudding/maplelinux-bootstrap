# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="9384e8deb75b7b1695e5637971b752281aaecd025a3d5d4734d33c1d0adfee47"
SRC_NAME="perl"
SRC_REVISION=1
SRC_URL="https://www.cpan.org/src/5.0/perl-5.42.2.tar.gz"
SRC_VERSION="5.42.2"

build() {
    tar xzf ../$SRC_FILENAME
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
    make -O -j $TT_PROCS install.perl DESTDIR=$TT_INSTALLDIR
}
