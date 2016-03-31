#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR

if [[ $1 == "clean" ]]
then
    rm -f `find . -name \*.spin`
    exit
fi

./fonts/fonts.sh
./images/images.sh
./samples/samples.sh
./sprites/sprites.sh

