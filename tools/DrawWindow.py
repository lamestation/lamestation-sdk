
import wx
import logging
from wx.lib.pubsub import setuparg1 
from wx.lib.pubsub import pub

import Color
import Bitmap
from FileManager import FileManager


BITMAP_SIZE = 32


class DrawWindow(wx.ScrolledWindow):
    def __init__(self, parent, image=None):
        wx.ScrolledWindow.__init__(self, parent)

        self.SetScrollbars(1,1,-1,-1)
        self.draw = DrawPanel(self)

class DrawPanel(wx.Panel):
    x = 0
    y = 0
    ox = 0
    oy = 0
    scale = 8

    def __init__(self, parent, image=None):
        wx.Panel.__init__(self, parent)

        self.parent = parent

        fm = FileManager()
        fm.New('image',BITMAP_SIZE,BITMAP_SIZE)

        self.OnSize(self)
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

        self.Bind(wx.EVT_MOTION, self.OnMouseMove)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)
        self.Bind(wx.EVT_LEFT_UP, self.OnLeftUp)
        self.Bind(wx.EVT_RIGHT_DOWN, self.OnRightDown)
        self.Bind(wx.EVT_RIGHT_UP, self.OnRightUp)
        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_ERASE_BACKGROUND, self.OnEraseBackground)

        pub.subscribe(self.OnSize,"SizeBitmap")
        pub.subscribe(self.UpdateBitmap,"UpdateBitmap")
        pub.subscribe(self.OnRecolor,"Recolor")

    def OnEraseBackground(self, event):
        # This is here to reduce flicker
        pass

    def OnSize(self, message):
        d = FileManager().CurrentFile().data
        w = d.GetWidth()
        h = d.GetHeight()
        self.SetSize(size=(w*self.scale,h*self.scale))
        self.parent.SetScrollbars(1,1,w*self.scale,h*self.scale)
        logging.info("DrawPanel.OnZoom()")
	self.Refresh()

    def UpdateBitmap(self, message):
        logging.info("DrawPanel.UpdateBitmap()")
        self.Refresh()

    def OnPaint(self, event):
        logging.info("DrawPanel.OnPaint()")
        d = FileManager().CurrentFile().data
        dc = wx.BufferedPaintDC(self,Bitmap.Scale(d,self.scale))
        

    def GetOldMouse(self):
        self.ox = self.x
        self.oy = self.y

    def GetMouse(self, event):
        self.GetOldMouse()
        self.x, self.y = event.GetPosition()
        self.x = self.x/self.scale
        self.y = self.y/self.scale

    def Log(self, name):
        logging.info(name+"(): %3s %3s %3s %3s %s" % (self.x, self.y, self.ox, self.oy, Color.COLOR))

    def Draw(self, event):
        self.GetOldMouse()
        self.GetMouse(event)
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

        d = FileManager().CurrentFile().data
        dc = wx.MemoryDC()
        dc.SelectObject(d)
        dc.SetBrush(wx.Brush(Color.COLOR))
        dc.SetPen(wx.Pen(Color.COLOR))
        dc.DrawPoint(self.x,self.y)
        dc.DrawLine(self.ox, self.oy, self.x, self.y)
        dc.SelectObject(wx.NullBitmap)
        logging.info("DRAW %s", id(d))

        pub.sendMessage("UpdateBitmap")


    def Read(self, event):
        self.GetMouse(event)
        self.Log("Read")

        d = FileManager().CurrentFile().data
        dc = wx.MemoryDC()
        dc.SelectObject(d)

        Color.Change(dc.GetPixel(self.x,self.y).GetAsString(flags=wx.C2S_HTML_SYNTAX))
        dc.SelectObject(wx.NullBitmap)


    def OnLeftDown(self, event):
        f = FileManager().CurrentFile()
        f.UpdateOld()

        self.Draw(event)


    def OnLeftUp(self, event):
        logging.info("OnLeftUp():")

        f = FileManager().CurrentFile()
        f.PushUndo()
        pub.sendMessage("DRAW")


    def OnRecolor(self, message):
        logging.info("OnRecolor():")

        bmp = FileManager().CurrentFile().data
        Bitmap.Recolor(bmp, message.data)
	self.Refresh()
        pub.sendMessage("UpdateBitmap")


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

