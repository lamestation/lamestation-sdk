#!/usr/bin/env python

import os, glob, re
from datetime import date
import subprocess

r_num = "[0-9][0-9]_"

def version():
    try:
        return subprocess.check_output(['git','describe','--tags'], stderr=os.devnull)
    except:
        return '0.0.0'

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

def doc_ext(f,ext):
    return os.path.splitext(f)[0]+'.'+ext

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

def process_input(filename,section,next_file=None,prev_file=None):
    text = open(filename, 'r').read()

#    if text[0:3] == '---':
#        return

    if next_file:
        next_file = '\nnext_file: "'+next_file+'"\nnext_name: "'+nice_file(next_file)+'"'
    else:
        next_file = ""

    if prev_file:
        prev_file = '\nprev_file: "'+prev_file+'"\nprev_name: "'+nice_file(prev_file)+'"'
    else:
        prev_file = ""

    text = """---
version: """+version()+"""
layout: learnpage
title: """+'"'+nice_file(filename)+'"'+"""
section: """+'"'+nice_dir(section)+'"'+"""
"""+next_file+"""
"""+prev_file+"""
---
"""+text

    g = open(filename,'w')
    g.write(text)
    g.close()


def build_index(path,ext,level=0):
    index = {}
    index['path'] = path

    index['files'] = glob.glob(r_num+"*."+ext+".lit")
    index['files'].sort()

    for i, f in enumerate(index['files']):
        filename = doc_ext(f,'md')
#        print i, filename

        next_file = None
        prev_file = None

        if len(index['files']) > 1:
            if i > 0:
                prev_file = doc_ext(index['files'][i-1],'html')
            if i < len(index['files'])-1:
                next_file = doc_ext(index['files'][i+1],'html')

        process_input(  filename,
                index['path'],
                next_file=next_file,
                prev_file=prev_file)

    index['dirs'] = []
    dirs = glob.glob(r_num+"*/")
    dirs.sort()
    for d in dirs:
        os.chdir(d)
        index['dirs'].append(build_index(d,ext,level=level+1))
        os.chdir('..')

    f = open('index.md','w')

    text = ""
    if level > 0:
        text = "---\nlayout: bare\n"
    else:
        text = "---\nlayout: learnindex\n"

    if level == 1:
        text += 'title: "'+nice_dir(path)+'"\n'
    if level == 0:
        text += 'title: "Index"\n'
    text += "---\n"
    f.write(text)
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
        output += bullet(nice_dir(index['path']),level)+'\n'

    for f in index['files']:
        p = os.path.join(lpath,f)
        p = os.path.splitext(p)[0]+'.html'

        output += bullet(link(nice_file(f),p),level+1)+'\n'

    for d in index['dirs']:
        output += printer(d,path,level=level+1, root=root)


    return output

build_index('','spin')

