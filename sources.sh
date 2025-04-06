#!/bin/sh -e
mkdir -p sources
cd sources
cat ../sources.list | while read line; do
    URL=$(echo $line | cut -d"," -f1)
    CANONICAL=$(echo $line | cut -d"," -f2)
    HASH=$(echo $line | cut -d"," -f3)
    if [ -z "$CANONICAL" ]; then
        OUTPUT=$(basename $URL)
    else
        OUTPUT=$CANONICAL
    fi
    echo $OUTPUT
    curl -L $URL -o $OUTPUT
    echo "$HASH  $OUTPUT" | sha256sum -c -
done
