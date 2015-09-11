#!/bin/bash -x
set -e

RELEASENAME=lamestation-sdk-$1

mkdir -p .build/
mv * .build/ -f
mv .build/scripts .
mv .build ${RELEASENAME}

rm -f ${RELEASENAME}.zip
zip -r ${RELEASENAME}.zip ${RELEASENAME}/

mv ${RELEASENAME} .build

mv .build/* .
rmdir .build
