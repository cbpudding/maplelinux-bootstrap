#!/bin/sh -e
mkdir -p sources
cd sources
cat ../sources.list | while read line; do
    URL=$(echo $line | cut -d"," -f1)
    CANONICAL=$(echo $line | cut -d"," -f2)
    if [ -z "$CANONICAL" ]; then
        curl $URL -o $(basename $URL)
    else
        curl $URL -o $CANONICAL
    fi
done