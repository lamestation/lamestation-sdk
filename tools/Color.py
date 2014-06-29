
import wx
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
RECT = 32

def Change(newcolor):
    global COLOR
    COLOR = newcolor
    pub.sendMessage("COLOR")
    logging.info("Color.Change("+COLOR+")")

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

class ColorManager(object):

    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(ColorManager, cls).__new__(
                                cls, *args, **kwargs)
        return cls._instance



class StylePicker(wx.ComboBox):

    def __init__(self, parent):
        wx.ComboBox.__init__(self, parent, 
                value=STYLE,
                choices=GetStyles(), 
                style=wx.CB_READONLY,
                size=(150,-1))

        self.Bind(wx.EVT_COMBOBOX, self.OnSelect)

    def OnSelect(self, event):
        pub.sendMessage("Recolor",self.GetValue())


class ColorPicker(wx.Panel):

    def __init__(self, parent):
        wx.Panel.__init__(self, parent, 
                size=(RECT*2,RECT*Count() ), style=wx.SUNKEN_BORDER)

        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)

        pub.subscribe(self.OnPaint,"STYLE")

    def OnPaint(self, event):
        dc = wx.PaintDC(self)

        inc = 0
        for c in range(0,4):
            dc.SetBrush(wx.Brush(Number(c) ))
            dc.SetPen(wx.Pen(Number(c) ))
            dc.DrawRectangle(0, RECT*inc, RECT*2, RECT)

            inc += 1

    def OnLeftDown(self, event):
        self.x, self.y = event.GetPosition()
        self.x = self.x/RECT
        self.y = self.y/RECT
        Change(Number(self.y) )
        logging.info("ColorPicker.OnLeftDown(%s %s %s %s)" % (self.x, self.y, Number(self.y), COLOR))


