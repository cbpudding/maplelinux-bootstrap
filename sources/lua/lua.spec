# Maintainer: Alexander Hill <ahill@breadpudding.dev>
SRC_HASH="57ccc32bbbd005cab75bcc52444052535af691789dba2b9016d5c50640d68b3d"
SRC_NAME="lua"
SRC_REVISION=2
SRC_URL="https://lua.org/ftp/lua-5.5.0.tar.gz"
SRC_VERSION="5.5.0"

build() {
    tar xf ../$SRC_FILENAME
    cd lua-$SRC_VERSION/
    # NOTE: LUA_ROOT and LUA_CDIR default to paths outside of Maple Linux's
    #       filesystem heirarchy, so it is necessary to manually tweak
    #       src/luaconf.h. ~ahill
    sed -i '/#define LUA_ROOT/s|/usr/local/|/usr/|' src/luaconf.h
    sed -i '/#define LUA_CDIR/s|LUA_ROOT "lib/lua/"|"/lib/lua/"|' src/luaconf.h
    # NOTE: Lua automatically assumes that GCC is installed, which is not the
    #       case here. CC is manually defined as a result. ~ahill
    make -O -j $TT_PROCS CC=$CC
    make -O -j $TT_PROCS install \
        INSTALL_BIN=$TT_INSTALLDIR$TT_BINDIR \
        INSTALL_CMOD=$TT_INSTALLDIR$TT_LIBDIR/lua/5.5 \
        INSTALL_INC=$TT_INSTALLDIR$TT_INCLUDEDIR \
        INSTALL_LIB=$TT_INSTALLDIR$TT_LIBDIR \
        INSTALL_LMOD=$TT_INSTALLDIR$TT_DATADIR/lua/5.5 \
        INSTALL_MAN=$TT_INSTALLDIR$TT_DATADIR/man/man1 \
        INSTALL_TOP=$TT_INSTALLDIR$TT_PREFIX
}
