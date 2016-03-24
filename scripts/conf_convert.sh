#!/bin/bash
FILES=*.md

for f in $FILES
do
    echo $f
    g=`echo $f | sed -e's/\(_[0-9]\+\)\(.md\)/.html/g'`
    echo $g
    
    for i in $FILES
    do
        #grep $i $FILES
        sed -i $i -e 's/'$f'/'$g'/g'
    done

done

for f in $FILES
do
    echo $f
    g=`echo $f | sed -e's/\(_[0-9]\+\)\(.md\)/.md/g'`
    echo $g

#    echo "---" > $g.tmp
#    echo "layout: learnpage" >> $g.tmp
#    echo "title: `echo $g | sed -e 's/.md$//g'`" >> $g.tmp
#    echo "---" >> $g.tmp
    cat $f >> $g.tmp
    rm $f
    mv $g.tmp $g
done
