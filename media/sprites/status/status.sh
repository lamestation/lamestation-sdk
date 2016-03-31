#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR

img2dat bar.png
img2dat head.png
img2dat heart.png
img2dat -f 16x16 radar.png
