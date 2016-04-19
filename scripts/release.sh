#!/bin/bash
set -e

RELEASENAME=lamestation-sdk-$1
VERSION=$1

BUILDDIR=.build

rm -rf ./$BUILDDIR/
mkdir -p $BUILDDIR/

cp library/demos/ library/games/ library/tutorials/ library/*.spin -r $BUILDDIR/

if [ -z $1 ] ; then
        echo "No version given... pass as parameter"
fi

echo -n "Packaging SDK"
while read LINE
do
        if [[ ! -f $BUILDDIR/$LINE ]]  ; then
            echo "Failed to find file $BUILDDIR/$LINE"
            continue
        fi

       
        F=`basename $LINE`

        # Generate file date

        TODAY=`git log $F 2>/dev/null | head -3 | grep "Date" | awk '{print $6}'`
        CREATED=`git log --reverse $F 2>/dev/null | head -3 | grep "Date" | awk '{print $6}'`

        if [[ -z $TODAY ]] ; then
                AGE=`date +%Y`
        elif  [[ ! $CREATED == $TODAY ]] ; then
                AGE=$CREATED-$TODAY
        else
                AGE=$TODAY
        fi

        mkdir -p $BUILDDIR/`dirname $LINE`

        if [[ ! "$F" =~ ^gfx_.*|^map_.*|^ins_.*|^song_.* ]]; then

                echo "SOODO"
                cat > $BUILDDIR/$LINE << EOF
' ${LINE}
' -------------------------------------------------
' Version:   ${VERSION}
' Author(s): $(git blame $LINE -f \
  | cut -d'(' -f 2- \
  | sed -e 's/ [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] .*//g' \
  | sort \
  | uniq \
  | sed ':a;N;$!ba;s/\n/, /g')
' Copyright (c) $AGE LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------

`cat ${LINE}`


`cat scripts/license.stub`
EOF
        else
                cat $LINE > $BUILDDIR/$LINE
        fi

        echo -n "."

done < <(git ls-tree -r ${VERSION} --name-only | grep .spin$)

cp library/media/ -r $BUILDDIR/

rm -f `find $BUILDDIR/ -name .\* -type f`

echo "DONE"

mv ${BUILDDIR} ${RELEASENAME}

rm -f ${RELEASENAME}.zip
#zip -r ${RELEASENAME}.zip ${RELEASENAME}/

mv ${RELEASENAME} ${BUILDDIR} 
