#!/usr/bin/env python

import os, glob, re

r_num = "[0-9][0-9]_"

def link(name, path):
    return "["+name+"]("+path+")"

def bullet(text,level=0):
    return "  "*level+" * "+text

def add_spaces(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1 \2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1 \2', s1)

def capitalize_first_letter(name):
    return re.sub('([a-zA-Z])', 
            lambda x: x.groups()[0].upper(), name, 1)

def nice_name(text, name):
    text = os.path.splitext(text)[0]
    text = os.path.splitext(text)[0]
    parts = text.split('_')
    output = ""

    output += name+" "+parts[0].lstrip('0')+": "

    parts.pop(0)
    parts = ' '.join(parts)
    parts = add_spaces(parts)
    parts = capitalize_first_letter(parts)
    parts = parts.strip('/')

    output += parts

    return output

def nice_file(text):
    return nice_name(text,'Step')

def nice_dir(text):
    return nice_name(text,'Section')

def build_index(path,ext):
    index = {}
    index['path'] = path

    index['files'] = glob.glob(r_num+"*."+ext+".lit")
    index['files'].sort()

    index['dirs'] = []
    dirs = glob.glob(r_num+"*/")
    dirs.sort()
    for d in dirs:
        os.chdir(d)
        index['dirs'].append(build_index(d,ext))
        os.chdir('..')

    f = open('index.md','w')
    f.write("""---
layout: page
title: Index
---
""")
    ind = printer(index, path='.', level=0, root=index['path'])
#    print ind
    f.write(ind)
    f.close()

    return index

def printer(index, path='.', level=0, root='.'):
    output = ""

    path = os.path.relpath(os.path.join(path, index['path']))

#    print 'R',root
    rpath = os.path.dirname(root).split(os.sep)
#    print 'R',rpath
    rpath = filter(None,rpath)

    lpath = path.split(os.sep)
    for i in xrange(len(rpath)):
        lpath.pop(0)
    lpath = os.sep.join(lpath)

    if level > 0:
        output += bullet(link(nice_dir(index['path']),lpath),level)+'\n'

    for f in index['files']:
        p = os.path.join(lpath,f)
        p = os.path.splitext(p)[0]+'.html'

#        print [rpath, lpath, root, index['path']]

        output += bullet(link(nice_file(f),p),level+1)+'\n'

    for d in index['dirs']:
        output += printer(d,path,level=level+1, root=root)


    return output

build_index('','spin')

