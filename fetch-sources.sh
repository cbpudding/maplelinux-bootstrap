#!/bin/sh -e
mkdir -p sources
cd sources
cat ../sources.list | while read line; do
    # This ignores lines starting with # so comments can be added. ~ahill
    if case $line in \#*) false;; *) true;; esac; then
        HASH=$(echo $line | cut -d"," -f1)
        # Comments (-f2) are ignored by the script ~ahill
        URL=$(echo $line | cut -d"," -f3)
        CANONICAL=$(echo $line | cut -d"," -f4)
        if [ -z "$CANONICAL" ]; then
            OUTPUT=$(basename $URL)
        else
            OUTPUT=$CANONICAL
        fi
        if [ ! -f "$OUTPUT" ]; then
            echo $OUTPUT
            curl -L $URL -o $OUTPUT
        fi
        echo "$HASH  $OUTPUT" | sha256sum -c -
    fi
done
