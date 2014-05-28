import re

def lineRule():
    return "' *********************************************************\n"

def commentOut(text):
    return re.sub("^","' ",text,flags=re.M)

def commentBox(text):
    output = ""
    output += lineRule()
    output += commentOut(text)+"\n"
    output += lineRule()

    return output

def addrBox(prefix,extra=""):
    output = ""
    output += "PUB "+extra+"Addr\n"
    output += "    return @"+prefix+"data\n\n"
    output += "DAT\n\n"
    output += prefix+"data"
    return output
