
from wx.lib.pubsub import setuparg1 
from wx.lib.pubsub import pub
import logging

color = {}
color['plain'] = ["#000000","#8F8F8F","#FFFFFF","#FF00FF"]
color['white on blue'] = ["#9140FE","#B17DE1","#CCCECB","#000000"]
color['red on black'] = ["#6F0000","#CC0000","#FF0000","#000000"]

lookup = {  
        'black':0,
        'gray':1,
        'white':2,
        'transparent':3
        }

STYLE = 'white on blue'
COLOR = color[STYLE][lookup['white']]

def Change(newcolor):
    global COLOR
    COLOR = newcolor
    pub.sendMessage("COLOR")
    logging.info("COLOR "+COLOR)

def Number(num):
    return color[STYLE][num]

def Name(name):
    return color[STYLE][lookup[name]]

def Convert(col, newstyle):
    return color[newstyle][color[STYLE].index(col)]

def Count():
    return len(color[STYLE])

def GetStyles():
    return color.keys()

def ChangeStyle(newstyle):
    Change(Convert(COLOR, newstyle))

    global STYLE
    STYLE = newstyle
    pub.sendMessage("STYLE")
