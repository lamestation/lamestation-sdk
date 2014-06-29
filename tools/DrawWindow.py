
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
        self.bmp = fm.CurrentFile().data
        self.w = self.bmp.GetWidth()
        self.h = self.bmp.GetHeight()
        self.oldbmp = self.bmp
        self.SetSize(size=(self.w*self.scale,self.h*self.scale))
        self.parent.SetScrollbars(1,1,self.w*self.scale,self.h*self.scale)
        self.Refresh()

    def OnPaint(self, event):
        dc = wx.ClientDC(self)
        dc.DrawBitmap(Bitmap.Scale(self.bmp,self.w*self.scale,self.h*self.scale), 0, 0, True)
        

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

        fm = FileManager()
        dc = wx.MemoryDC()
        dc.SelectObject(fm.CurrentFile().data)
        dc.SetBrush(wx.Brush(Color.COLOR))
        dc.SetPen(wx.Pen(Color.COLOR))
        dc.DrawPoint(self.x,self.y)
        dc.DrawLine(self.ox, self.oy, self.x, self.y)
        dc.SelectObject(wx.NullBitmap)

        self.Refresh()


    def Read(self, event):
        self.GetMouse(event)
        self.Log("Read")

        fm = FileManager()
        dc = wx.MemoryDC()
        dc.SelectObject(fm.CurrentFile().data)

        Color.Change(dc.GetPixel(self.x,self.y).GetAsString(flags=wx.C2S_HTML_SYNTAX))
        dc.SelectObject(wx.NullBitmap)


    def OnLeftDown(self, event):
        fm = FileManager()
        bmp = fm.CurrentFile().data
        logging.info("DRAW %s", id(bmp))

        self.oldbmp = Bitmap.Copy(bmp)
        self.Draw(event)


    def OnLeftUp(self, event):
        logging.info("OnLeftUp():")
        fm = FileManager()
        bmp = fm.CurrentFile().data
        self.images = [self.oldbmp, bmp]
        pub.sendMessage("DRAW",self.images)


    def OnRecolor(self, message):
        fm = FileManager()
        bmp = fm.CurrentFile().data
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

