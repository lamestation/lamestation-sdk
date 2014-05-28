import os, sys


def getFullFilename(prefix, filename, ext):
    return os.path.join(os.path.dirname(filename),str(prefix)+os.path.splitext(os.path.basename(filename))[0]+"."+str(ext))

def getShortFilename(filename):
    return os.path.splitext(os.path.basename(filename))[0]



def cleanFilenames(filenames):
    filenames = [ i for i in filenames if not os.path.splitext(i)[1] == '.dat' and os.path.isfile(i) ]
    filenames = [ i for i in filenames if not os.path.splitext(i)[1] == '.txt' ]
    return filenames


# Determine if application is a script file or frozen exe
def getScriptDir():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(sys.executable)
    elif __file__:
        return os.path.dirname(__file__)

def writeFile(text,filename):
#    if os.path.isfile(filename):
#        print "File exists; overwrite? (y/N):"
#        choice = raw_input().lower()
#        if not choice in set(['y']):
#            print "Skipping writing for "+filename
#            return

    f = open(filename,"w")
    f.write(text)
    f.close()

