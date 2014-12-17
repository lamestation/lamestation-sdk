#!/bin/bash

FILES=$(file $(find . -name \*.spin) | cut -d':' -f 1)

for f in $FILES
do
    ENCODING=$(file $f | cut -d':' -f 2)

    # Fix encoding
    if [[ $ENCODING == *"ISO-8859"* ]] ; then
        echo "ISO-8859"
        iconv -f iso-8859-1 -t utf-8 "$f" > "$f.tmp"
        mv "$f.tmp" "$f"

    elif [[ $ENCODING == *"UTF-16"* ]] ; then
        echo "UTF-16"
        iconv -f utf-16 -t utf-8 "$f" > "$f.tmp"
        mv "$f.tmp" "$f"
    fi

    # Fix line endings
    if [[ $ENCODING == *"CR line terminators"* ]] ; then
        mac2unix "$f"
    elif [[ $ENCODING == *"CRLF line terminators"* ]] ; then
        dos2unix "$f"
    fi

done
