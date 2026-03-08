#!/bin/sh
if [ -z "$1" ]; then
    echo "Usage: pkgconflict.sh <package directory>" >&2
    exit 1
fi
BUFFER=$(mktemp)
for pkg in $1/*.cpio.xz; do
    # NOTE: This only highlights the need for machine-readable filenames. ~ahill
    NAME=$(basename $pkg | sed -E "s/-[0-9].+$//")
    bsdcpio -iJt < $pkg | sed -E "/^\.(\/(bin|boot|etc|lib|usr|usr\/include|usr\/share|usr\/share\/man|usr\/share\/man\/man[1-8]))?$/d" | sed "s/$/:$NAME/" >> $BUFFER
done
# First time using Lua for something like this. Is there a better way to write this? ~ahill
sort -k1,1 -t: $BUFFER | lua -e "l, s = nil, {} for p, n in io.read(\"*all\"):gmatch(\"([^:]+):(%S+)\") do if p == l then table.insert(s, n) else if #s > 1 then io.write(l .. \":\" .. table.concat(s, \",\")) end l, s = p, {n} end end"
rm $BUFFER
