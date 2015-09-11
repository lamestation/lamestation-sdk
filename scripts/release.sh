#!/bin/bash
set -e

RELEASENAME=lamestation-sdk-${RELEASE:?"CAUTION: Don't run in personal repository; Set RELEASE to continue"}

mkdir -p .build/
mv * .build/ -f
mv .build/scripts .
mv .build ${RELEASENAME}

rm -f ${RELEASENAME}.zip
zip -r ${RELEASENAME}.zip ${RELEASENAME}/

mv ${RELEASENAME} .build

mv .build/* .
rmdir .build
