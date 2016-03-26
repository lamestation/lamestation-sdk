#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR

for d in */
do
    d=`echo $d | sed -e 's@/@@'`
    echo $d

    pushd $d

    for f in *.png
    do
        img2dat $f -f $d
    done

    popd

done
