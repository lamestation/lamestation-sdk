
import wx
import logging
from wx.lib.pubsub import pub

import Color
import Bitmap


BITMAP_SIZE = 32
BITMAP_SCALE = 16
BITMAP_NEWSIZE = BITMAP_SIZE*BITMAP_SCALE

class DrawWindow(wx.Panel):
    x = 0
    y = 0
    ox = 0
    oy = 0

    def __init__(self, parent, image=None):
        wx.Panel.__init__(self, parent, size=(BITMAP_NEWSIZE,BITMAP_NEWSIZE), style=wx.SUNKEN_BORDER)

        if image == None:
            self.bmp = Bitmap.New(BITMAP_SIZE,BITMAP_SIZE)
        else:
            self.bmp = image


        self.SetSize(size=(BITMAP_NEWSIZE,BITMAP_NEWSIZE))

        self.oldbmp = self.bmp
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

        dc = wx.ClientDC(self)
        dc.DrawBitmap(Bitmap.Scale(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)

        self.Bind(wx.EVT_MOTION, self.OnMouseMove)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)
        self.Bind(wx.EVT_LEFT_UP, self.OnLeftUp)
        self.Bind(wx.EVT_RIGHT_DOWN, self.OnRightDown)
        self.Bind(wx.EVT_RIGHT_UP, self.OnRightUp)
        self.Bind(wx.EVT_PAINT, self.OnPaint)

        pub.subscribe(self.UpdateBitmap,"UpdateBitmap")
        pub.subscribe(self.OnRecolor,"Recolor")


    def UpdateBitmap(self, message):
        self.bmp = message.data
        self.OnPaint(None)


    def OnPaint(self, event):
        dc = wx.ClientDC(self)
        dc.DrawBitmap(Bitmap.Scale(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)
        


    def GetOldMouse(self):
        self.ox = self.x
        self.oy = self.y


    def GetImage(self):
        return self.bmp


    def GetMouse(self, event):
        self.GetOldMouse()
        self.x, self.y = event.GetPosition()
        self.x = self.x*BITMAP_SIZE/BITMAP_NEWSIZE
        self.y = self.y*BITMAP_SIZE/BITMAP_NEWSIZE


    def Log(self, name):
        print Color.COLOR
        logging.info(name+"(): %3s %3s %3s %3s %s" % (self.x, self.y, self.ox, self.oy, Color.COLOR))


    def Draw(self, event):
        self.GetOldMouse()
        self.GetMouse(event)
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))


        dc = wx.MemoryDC()
        dc.SelectObject(self.bmp)
        dc.SetBrush(wx.Brush(Color.COLOR))
        dc.SetPen(wx.Pen(Color.COLOR))
        dc.DrawPoint(self.x,self.y)
        dc.DrawLine(self.ox, self.oy, self.x, self.y)
        dc.SelectObject(wx.NullBitmap)

        dc = wx.ClientDC(self)
        dc.DrawBitmap(Bitmap.Scale(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)


    def Read(self, event):
        self.GetMouse(event)
        self.Log("Read")

        dc = wx.MemoryDC()
        dc.SelectObject(self.bmp)

        Color.Change(dc.GetPixel(self.x,self.y).GetAsString(flags=wx.C2S_HTML_SYNTAX))
        dc.SelectObject(wx.NullBitmap)


    def OnLeftDown(self, event):
        logging.info("DRAW %s", id(self.bmp))

        self.oldbmp = Bitmap.Copy(self.bmp)
        self.Draw(event)


    def OnLeftUp(self, event):
        logging.info("OnLeftUp():")
        self.images = [self.oldbmp, self.bmp]
        pub.sendMessage("DRAW",self.images)


    def OnRecolor(self, message):
        self.oldbmp = Bitmap.Copy(self.bmp)
        Bitmap.Recolor(self.bmp, message.data)
        self.images = [self.oldbmp, self.bmp]
        pub.sendMessage("DRAW",self.images)


    def OnRightDown(self, event):
        self.SetCursor(wx.StockCursor(wx.CURSOR_BULLSEYE))
#        pub.sendMessage("COLOR")
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

