#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR

img2dat -f 24x24 class16.png
img2dat -f 16x16 happyface.png
img2dat -f 16x16 happyface_full.png
img2dat -f 8x8   knight.png
img2dat -f 16x16 moonman.png
img2dat -f 16x16 supertank.png
img2dat -f 16x16 supertank_full.png
img2dat -f 16x16 superthang.png
img2dat -f 16x16 superthang_full.png

