#!/usr/bin/env python

import os, sys, shutil
import errno    
import subprocess
import zipfile
import fnmatch
import re


def zipdir(path, ziph):
    for root, dirs, files in os.walk(path):
        for file in files:
            ziph.write(os.path.join(root, file))

def mkdir(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

def purge(directory, pattern):
    for root, dirnames, filenames in os.walk(directory):
        for filename in fnmatch.filter(filenames, pattern):
            print "del", os.path.join(root, filename)
            os.remove(os.path.join(root, filename))

version = 'master'

if len(sys.argv) > 1:
    version = sys.argv[1]

release = "lamestation-sdk-"+version
archive = release+".zip"
builddir = ".build"

print release

try:
    shutil.rmtree(builddir)
except:
    pass
shutil.copytree("library",builddir)

purge(builddir, "*.sh")
purge(builddir, "*.xcf")
purge(builddir, "*.svg")

def command(cmd):
    try:
        out = subprocess.check_output(cmd)
    except subprocess.CalledProcessError as e:
        print "Error: Command failed"
        sys.exit(1)
    return out


files = command(["git","ls-tree","-r",version,"--name-only"]).splitlines()
files = [f for f in files if re.match(r'.*\.spin', f)]

for line in files:
    filebase = os.path.basename(line)

    if filebase.startswith('gfx'):  continue
    if filebase.startswith('map'):  continue
    if filebase.startswith('snd'):  continue
    if filebase.startswith('ins'):  continue
    if filebase.startswith('song'): continue
    if filebase.startswith('wav'):  continue

    filecomps = line.split(os.sep)
    filecomps.pop(0)
    filename = os.sep.join(filecomps)
    newfilename = os.path.join(builddir, filename)

    print line
    logs = command(["git","log", "--format=%aD","--follow", line]).splitlines()
    today = logs[0].split()[3]
    created = logs[-1].split()[3]

    age = created + "-" + today
    if created == today:
        age = today

    f = open(line, 'r').read()

    output = ""
    output += "' "+80*'-'+"\n"
    output += "' "+filename+"\n"
    output += "' Version: "+version+"\n"
    output += "' Copyright (c) "+age+" LameStation LLC\n"
    output += "' See end of file for terms of use.\n"
    output += "' "+80*'-'+"\n"

    output += f

    output += "\n\nDAT\n"
    output += open(os.path.join('scripts','license.stub'),'r').read()
    output += "DAT\n"

    f = open(newfilename, 'w')
    f.write(output)
    f.close()

try:
    shutil.rmtree(release)
except OSError:
    pass
shutil.move(builddir, release)

try:
    os.remove(archive)
except:
    pass

print "Building zip:",archive
zipf = zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED)
zipdir(release, zipf)
zipf.close()

shutil.move(release, builddir)
