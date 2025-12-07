# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_FILENAME="bsdutils-13.2.tar.gz"
SRC_HASH="4547990309afe686c6f36c2a4f7ac5806e0064b182dd1f93f52dda7661979a3c"
SRC_NAME="bsdutils"
SRC_REVISION=1
SRC_URL="https://codeberg.org/dcantrell/bsdutils/archive/v13.2.tar.gz"
SRC_VERSION="13.2"

# NOTE: Even though the install implementation from bsdutils is being used, some
#       packages may try to use -D and -t, which are only supported under
#       Busybox's implementation. ~ahill

build() {
    tar xf ../$SRC_FILENAME
    cd bsdutils/
    # NOTE: Before we start building bsdutils, we tell it *not* to build df/wc,
    #       since that requires an additional dependency (libxo) and we already
    #       have BusyBox's version of df and wc to replace it. ~ahill
    sed -i "/libxo/d" meson.build
    sed -i "/'df'/d" src/meson.build
    sed -i "/'wc'/d" src/meson.build
    # NOTE: Apparently, rpmatch is REQUIRED, despite meson.build stating that it
    #       is optional. Disabling find in favor of BusyBox to prevent another
    #       dependency from being introduced. ~ahill
    sed -i "/'find'/d" src/meson.build
    # NOTE: Finally, we have a *lot* of duplicate commands between bsdutils and
    #       Busybox. After reviewing *all* of the commands they share, these are
    #       the commands I believe Busybox should handle. ~ahill
    sed -i "/'dirname'/d" src/meson.build
    sed -i "/'echo'/d" src/meson.build
    sed -i "/'expand'/d" src/meson.build
    sed -i "/'expr'/d" src/meson.build
    sed -i "/'false'/d" src/meson.build
    sed -i "/'fold'/d" src/meson.build
    sed -i "/'groups'/d" src/meson.build
    sed -i "/'head'/d" src/meson.build
    sed -i "/'hexdump'/d" src/meson.build
    sed -i "/'kill'/d" src/meson.build
    sed -i "/'ln'/d" src/meson.build
    sed -i "/'logname'/d" src/meson.build
    sed -i "/'ls'/d" src/meson.build
    sed -i "/'mkdir'/d" src/meson.build
    sed -i "/'mkfifo'/d" src/meson.build
    sed -i "/'mknod'/d" src/meson.build
    sed -i "/'mktemp'/d" src/meson.build
    sed -i "/'mv'/d" src/meson.build
    sed -i "/'nice'/d" src/meson.build
    sed -i "/'nohup'/d" src/meson.build
    sed -i "/'paste'/d" src/meson.build
    sed -i "/'printenv'/d" src/meson.build
    sed -i "/'printf'/d" src/meson.build
    sed -i "/'pwd'/d" src/meson.build
    sed -i "/'rm'/d" src/meson.build
    sed -i "/'rmdir'/d" src/meson.build
    sed -i "/'sed'/d" src/meson.build
    sed -i "/'sleep'/d" src/meson.build
    sed -i "/'stat'/d" src/meson.build
    sed -i "/'stty'/d" src/meson.build
    sed -i "/'sync'/d" src/meson.build
    sed -i "/'tail'/d" src/meson.build
    sed -i "/'tee'/d" src/meson.build
    sed -i "/'test'/d" src/meson.build
    sed -i "/'true'/d" src/meson.build
    sed -i "/'tty'/d" src/meson.build
    sed -i "/'uname'/d" src/meson.build
    sed -i "/'unexpand'/d" src/meson.build
    sed -i "/'uniq'/d" src/meson.build
    sed -i "/'users'/d" src/meson.build
    sed -i "/'whoami'/d" src/meson.build
    sed -i "/'xargs'/d" src/meson.build
    muon setup $TT_MESON_COMMON build
    muon samu -C build
}

clean() {
    rm -rf bsdutils/
}

package() {
    cd bsdutils/
    muon -C build install -d $TT_INSTALLDIR
}
