#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR

img2dat ibot.png
img2dat idrone.png

img2dat -f 8x16  spacemarine_small.png

img2dat -f 16x8  spacetank.png

img2dat -f 16x16 zeroforce.png 
img2dat -f 16x16 frappy.png
img2dat -f 16x16 lumpy.png 

img2dat -f 16x24 spacemarine.png

img2dat -f 24x16 krakken.png
img2dat -f 24x16 rocket.png 

img2dat -f 24x24 blackhole.png 
