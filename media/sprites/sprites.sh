#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR

./backdrops/backdrops.sh
./bosses/bosses.sh
./effects/effects.sh
./logos/logos.sh
./objects/objects.sh
./sidescroll/sidescroll.sh
./status/status.sh
./text/text.sh
./topdown/topdown.sh
