
import wx
import logging
from wx.lib.pubsub import setuparg1 
from wx.lib.pubsub import pub

import Color
import Bitmap
from FileManager import FileManager


BITMAP_SIZE = 32
BITMAP_SCALE = 8


class DrawWindow(wx.ScrolledWindow):
    def __init__(self, parent, image=None):
        wx.ScrolledWindow.__init__(self, parent, style=wx.SUNKEN_BORDER)

        self.SetScrollbars(1,1,-1,-1)
        self.draw = DrawPanel(self)

        hbox = wx.BoxSizer(wx.HORIZONTAL)
        hbox.Add(self.draw, 1, wx.ALL|wx.ALIGN_CENTER, 0)
        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(hbox, 1, wx.ALL|wx.ALIGN_CENTER, 0)

        self.SetSizer(vbox)
        self.Layout()

class DrawPanel(wx.Panel):
    x = 0
    y = 0
    ox = 0
    oy = 0

    def __init__(self, parent, image=None):
        wx.Panel.__init__(self, parent, style=wx.SUNKEN_BORDER)

        fm = FileManager()
        fm.New('image',BITMAP_SIZE,BITMAP_SIZE)

        self.UpdateBitmap(self)
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

        self.Bind(wx.EVT_MOTION, self.OnMouseMove)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)
        self.Bind(wx.EVT_LEFT_UP, self.OnLeftUp)
        self.Bind(wx.EVT_RIGHT_DOWN, self.OnRightDown)
        self.Bind(wx.EVT_RIGHT_UP, self.OnRightUp)
        self.Bind(wx.EVT_PAINT, self.OnPaint)

        pub.subscribe(self.UpdateBitmap,"UpdateBitmap")
        pub.subscribe(self.OnRecolor,"Recolor")


    def UpdateBitmap(self, message):
        fm = FileManager()
        self.bmp = fm.CurrentFile().bitmap
        self.w = self.bmp.GetWidth()
        self.h = self.bmp.GetHeight()
        self.oldbmp = self.bmp
        self.SetSize(size=(self.w*BITMAP_SCALE,self.h*BITMAP_SCALE))
        self.Update()
        self.OnPaint(None)


    def OnPaint(self, event):
        fm = FileManager()
        dc = wx.ClientDC(self)
        dc.DrawBitmap(Bitmap.Scale(self.bmp,self.w*BITMAP_SCALE,self.h*BITMAP_SCALE), 0, 0, True)
        

    def GetOldMouse(self):
        self.ox = self.x
        self.oy = self.y

    def GetMouse(self, event):
        self.GetOldMouse()
        self.x, self.y = event.GetPosition()
        self.x = self.x/BITMAP_SCALE
        self.y = self.y/BITMAP_SCALE

    def Log(self, name):
        logging.info(name+"(): %3s %3s %3s %3s %s" % (self.x, self.y, self.ox, self.oy, Color.COLOR))

    def Draw(self, event):
        self.GetOldMouse()
        self.GetMouse(event)
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

        fm = FileManager()
        dc = wx.MemoryDC()
        dc.SelectObject(fm.CurrentFile().bitmap)
        dc.SetBrush(wx.Brush(Color.COLOR))
        dc.SetPen(wx.Pen(Color.COLOR))
        dc.DrawPoint(self.x,self.y)
        dc.DrawLine(self.ox, self.oy, self.x, self.y)
        dc.SelectObject(wx.NullBitmap)

        self.OnPaint(None)


    def Read(self, event):
        self.GetMouse(event)
        self.Log("Read")

        fm = FileManager()
        dc = wx.MemoryDC()
        dc.SelectObject(fm.CurrentFile().bitmap)

        Color.Change(dc.GetPixel(self.x,self.y).GetAsString(flags=wx.C2S_HTML_SYNTAX))
        dc.SelectObject(wx.NullBitmap)


    def OnLeftDown(self, event):
        fm = FileManager()
        bmp = fm.CurrentFile().bitmap
        logging.info("DRAW %s", id(bmp))

        self.oldbmp = Bitmap.Copy(bmp)
        self.Draw(event)


    def OnLeftUp(self, event):
        logging.info("OnLeftUp():")
        fm = FileManager()
        bmp = fm.CurrentFile().bitmap
        self.images = [self.oldbmp, bmp]
        pub.sendMessage("DRAW",self.images)


    def OnRecolor(self, message):
        fm = FileManager()
        bmp = fm.CurrentFile().bitmap
        self.oldbmp = Bitmap.Copy(bmp)
        Bitmap.Recolor(bmp, message.data)
        self.images = [self.oldbmp, bmp]
        pub.sendMessage("DRAW",self.images)


    def OnRightDown(self, event):
        self.SetCursor(wx.StockCursor(wx.CURSOR_BULLSEYE))
        self.Read(event)


    def OnRightUp(self, event):
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))


    def OnMouseMove(self, event):

        if event.Dragging():
            if event.LeftIsDown():
                self.Draw(event)
            if event.RightIsDown():
                pub.sendMessage("COLOR")
                self.Read(event)
        else:
            self.GetMouse(event)
            self.GetOldMouse()
            self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

