# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="f3314240c846140d7be742e405882302f01dbecc51b8dd44d97cdad62d978f03"
SRC_NAME="liquid"
SRC_URL="https://github.com/Shopify/liquid/archive/refs/tags/v5.11.0.tar.gz"
SRC_VERSION="5.11.0"

SRC_FILENAME="$SRC_NAME-$SRC_VERSION.tar.gz"

build() {
    tar xf ../$SRC_FILENAME
    cd liquid-$SRC_VERSION/
    gem build liquid.gemspec
    gem install \
        --install-dir $TT_INSTALLDIR/lib/ruby/gems/4.0.0 \
        --local \
        --ignore-dependencies \
        --verbose \
        ./liquid-$SRC_VERSION.gem
}