#!/usr/bin/python

import wx
import Color, Dialog
import logging

BITMAP_SIZE = 32
BITMAP_SCALE = 16
BITMAP_NEWSIZE = BITMAP_SIZE*BITMAP_SCALE
BITMAP_MAXSIZE = 256
COLOR = Color.color['plain'][0]
STYLE = 'plain'

BITMAP = None

#logging.basicConfig(level=logging.INFO)

stockUndo = []
stockRedo = []

class UndoDraw:
    def __init__( self, oldbmp, bmp):
        self.bmp = bmp
        self.RedoBitmap = CopyBitmap(bmp) # image after change
        self.UndoBitmap = oldbmp # image before change

        logging.info("SAVE %s %s %s" % (id(self.bmp), id(self.RedoBitmap), id(self.UndoBitmap)))
    
    def undo( self ):
        if not self.UndoBitmap == None:
                self.bmp = self.UndoBitmap

        logging.info("UNDO %s %s %s" % (id(self.bmp), id(self.RedoBitmap), id(self.UndoBitmap)))
        return self.bmp

    
    def redo( self ):
        if not self.RedoBitmap == None:
                self.bmp = self.RedoBitmap

        logging.info("REDO %s %s %s" % (id(self.bmp), id(self.RedoBitmap), id(self.UndoBitmap)))
        return self.bmp


def CopyBitmap(bitmap):
    return  wx.ImageFromBitmap(bitmap).Copy().ConvertToBitmap()

def scale_bitmap(bitmap, width, height):
    image = wx.ImageFromBitmap(bitmap)
    image = image.Scale(width, height, wx.IMAGE_QUALITY_NORMAL)
    result = wx.BitmapFromImage(image)
    return result


class MipMap(wx.Panel):
    x = 0
    y = 0
    ox = 0
    oy = 0

    def __init__(self, parent):
        wx.Panel.__init__(self, parent, 
                size=(BITMAP_NEWSIZE,BITMAP_NEWSIZE), style=wx.SUNKEN_BORDER)
        self.bmp = wx.EmptyBitmap(BITMAP_SIZE,BITMAP_SIZE)

        self.SetCursor(wx.StockCursor(wx.CURSOR_ARROW))
        self.Bind(wx.EVT_PAINT, self.OnPaint)

#    def UpdateBitmap(self):

    def OnPaint(self, event):
        dc = wx.ClientDC(self)
        dc.DrawBitmap(self.bmp, 0, 0, True)


class DrawWindow(wx.Panel):
    x = 0
    y = 0
    ox = 0
    oy = 0

    def __init__(self, parent, image=None):
        wx.Panel.__init__(self, parent, size=(600,400), style=wx.SUNKEN_BORDER)

        self.toolbar = self.GetParent().GetParent().toolbar

        if image == None:
            self.bmp = self.NewImage(BITMAP_SIZE,BITMAP_SIZE)
        else:
            self.bmp = image


        self.SetSize(size=(BITMAP_NEWSIZE,BITMAP_NEWSIZE))

        self.oldbmp = self.bmp
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

        dc = wx.ClientDC(self)
        dc.DrawBitmap(scale_bitmap(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)

        self.Bind(wx.EVT_MOTION, self.OnMouseMove)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)
        self.Bind(wx.EVT_LEFT_UP, self.OnLeftUp)
        self.Bind(wx.EVT_RIGHT_DOWN, self.OnRightDown)
        self.Bind(wx.EVT_PAINT, self.OnPaint)

        wx.EVT_TOOL(self.toolbar, wx.ID_UNDO, self.OnUndo)
        wx.EVT_TOOL(self.toolbar, wx.ID_REDO, self.OnRedo)

        wx.EVT_MENU(self.GetParent().GetParent(), wx.ID_UNDO, self.OnUndo)
        wx.EVT_MENU(self.GetParent().GetParent(), wx.ID_REDO, self.OnRedo)



    def NewImage(self, w, h):
        self.bmp = wx.EmptyBitmap(w,h) 
        dc = wx.MemoryDC()
        dc.SelectObject(self.bmp)
        dc.Clear()
        dc.SetBrush(wx.Brush(Color.color[STYLE][Color.lookup['none']]))
        dc.FloodFill(0, 0, wx.Colour(255,255,255))
        dc.SelectObject(wx.NullBitmap)

        return self.bmp
    

    def OnPaint(self, event):
        dc = wx.ClientDC(self)
        dc.DrawBitmap(scale_bitmap(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)
        


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
        logging.info(name+"(): %3s %3s %3s %3s %s" % (self.x, self.y, self.ox, self.oy, COLOR))

    def Draw(self, event):
        self.GetOldMouse()
        self.GetMouse(event)
    #    self.Log("Draw")
        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))


        dc = wx.MemoryDC()
        dc.SelectObject(self.bmp)
        dc.SetBrush(wx.Brush(COLOR))
        dc.SetPen(wx.Pen(COLOR))
        dc.DrawPoint(self.x,self.y)
        dc.DrawLine(self.ox, self.oy, self.x, self.y)
        dc.SelectObject(wx.NullBitmap)

        dc = wx.ClientDC(self)
        dc.DrawBitmap(scale_bitmap(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)

    def SaveDraw(self, event):

        self.toolbar.EnableTool(wx.ID_UNDO, True )
        undo = UndoDraw(self.oldbmp, self.bmp)
        stockUndo.append( undo )
        if stockRedo:
            del stockRedo[:]
            self.toolbar.EnableTool( wx.ID_REDO, False )

    def Read(self, event):
        global COLOR
        self.GetMouse(event)
        self.Log("Read")

        dc = wx.MemoryDC()
        dc.SelectObject(self.bmp)
        COLOR = dc.GetPixel(self.x,self.y)
        dc.SelectObject(wx.NullBitmap)

    def OnLeftDown(self, event):
        logging.info("DRAW %s", id(self.bmp))

        self.oldbmp = CopyBitmap(self.bmp)
        self.Draw(event)

    def OnLeftUp(self, event):
        logging.info("OnLeftUp():")
        self.SaveDraw(event)

    def OnRightDown(self, event):
        self.SetCursor(wx.StockCursor(wx.CURSOR_BULLSEYE))
        self.Read(event)

    def OnMouseMove(self, event):

        if event.Dragging():
            if event.LeftIsDown():
                self.Draw(event)
            if event.RightIsDown():
                self.Read(event)
        else:
            self.GetMouse(event)
            self.GetOldMouse()
            self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))


    def OnUndo( self, event ):
        if len( stockUndo ) == 0:
            self.toolbar.EnableTool( wx.ID_UNDO, False )
            return

        a = stockUndo.pop()
        if len( stockUndo ) == 0:
            self.toolbar.EnableTool( wx.ID_UNDO, False )

        self.bmp = a.undo()

        stockRedo.append( a )
        self.toolbar.EnableTool( wx.ID_REDO, True )

        self.OnPaint(None)


    def OnRedo( self, event ):
        if len( stockRedo ) == 0:
            self.toolbar.EnableTool( wx.ID_REDO, False )
            return

        a = stockRedo.pop()
        if len( stockRedo ) == 0:
            self.toolbar.EnableTool( wx.ID_REDO, False )

        self.bmp = a.redo()

        stockUndo.append( a )
        self.toolbar.EnableTool( wx.ID_UNDO, True )

        self.OnPaint(None)







class ColorPicker(wx.Panel):

    colnum = 2
    rect = 32

    def __init__(self, parent):
        wx.Panel.__init__(self, parent, 
                size=(self.rect*2,self.rect*len(Color.color[STYLE]) ), style=wx.SUNKEN_BORDER)

        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)

    def OnPaint(self, event):
        dc = wx.PaintDC(self)

        inc = 0
        for c in range(0,4):
            dc.SetBrush(wx.Brush(Color.color[STYLE][c]))
            dc.SetPen(wx.Pen(Color.color[STYLE][c]))
            dc.DrawRectangle(0, self.rect*inc, self.rect*2, self.rect)

            inc += 1

    def OnLeftDown(self, event):
        self.x, self.y = event.GetPosition()
        self.x = self.x/self.rect
        self.y = self.y/self.rect
        global COLOR
        COLOR = Color.color[STYLE][self.y]
        logging.info("ColorPicker: clicked! %s %s %s %s" % (self.x, self.y, Color.color[STYLE][self.y], COLOR))



class SideBar(wx.Panel):

    def __init__(self, parent):
        wx.Panel.__init__(self, parent, style=wx.RAISED_BORDER)

        cp1 = ColorPicker(self)

        

        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(cp1, 0, wx.ALL, 0)

        hbox = wx.BoxSizer(wx.HORIZONTAL)
        hbox.Add(vbox, 0, wx.ALL, 0)

        self.SetSizer(hbox)


class LSPaint(wx.Frame):
    scale = 4
    scales = ['1x','2x','4x','8x','16x']
    width = 32
    height = 32

    def __init__(self, parent, id, title):
        wx.Frame.__init__(self, parent, id, title)

        self.toolbar = self.ToolBar()
        self.menu = self.MenuBar()
        self.SetMenuBar(self.menu)

        panel = wx.ScrolledWindow(self)
        panel.SetScrollbars(1,1,-1,-1)
        hbox = wx.BoxSizer(wx.HORIZONTAL)
        hbox.Add(DrawWindow(panel), 1, wx.EXPAND, 0)
        panel.SetSizerAndFit(hbox)

        hboxm = wx.BoxSizer(wx.HORIZONTAL)
        hboxm.Add(SideBar(self),0,wx.EXPAND,10)
        hboxm.Add(panel,1,wx.EXPAND,0)

        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(hboxm,1, wx.EXPAND, 0)

        self.SetSizerAndFit(vbox)
        self.Show(True)


    def FileMenu(self):
        menu = wx.Menu()
        menu.Append(wx.ID_NEW, '&New', 'New Image')        
        menu.Append(wx.ID_OPEN, '&Open', 'Open Image')
        menu.Append(wx.ID_SAVE, '&Save', 'Save Image')
        menu.Append(wx.ID_SAVEAS, 'Save &As...', 'Save Image As...')
        menu.AppendSeparator()
        exp = menu.Append(wx.ID_ANY, '&Export', 'Export Image As Spin')
        menu.AppendSeparator()
        menu.Append(wx.ID_CLOSE, '&Close', 'Close image')
        menu.Append(wx.ID_EXIT, '&Quit\tCtrl+Q', 'Quit application')

        wx.EVT_MENU(self, wx.ID_NEW, self.OnNew)
        wx.EVT_MENU(self, wx.ID_EXIT, self.OnQuit)
#        wx.EVT_MENU(self, wx.ID_OPEN, self.OnBrowse)
#        self.Bind(wx.EVT_MENU, self.OnExport, exp)

        return menu

    def EditMenu(self):
        menu = wx.Menu()
        menu.Append(wx.ID_UNDO, '&Undo\tCtrl+Z', 'New Image')        
        menu.Append(wx.ID_REDO, '&Redo\tCtrl+Shift+Z', 'Open Image')
        menu.AppendSeparator()
        menu.Append(wx.ID_CUT, 'Cu&t', 'Cut To Clipoard')
        menu.Append(wx.ID_COPY, '&Copy', 'Copy To Clipboard')
        menu.Append(wx.ID_PASTE, 'Paste','Paste Into Image')

        return menu

    def HelpMenu(self):
        menu = wx.Menu()
        menu.Append(wx.ID_ABOUT, 'About', 'About LSPaint')
#        wx.EVT_MENU(self, wx.ID_ABOUT, self.OnAbout)

        return menu

    def MenuBar(self):
        menubar = wx.MenuBar()

        menubar.Append(self.FileMenu(), '&File')
        menubar.Append(self.EditMenu(), '&Edit')
        menubar.Append(self.HelpMenu(), '&Help')

        return menubar

    def ToolBar(self):
        self.toolbar = self.CreateToolBar()
        self.toolbar.AddLabelTool(wx.ID_NEW,'New',wx.ArtProvider.GetBitmap(wx.ART_NEW))
        self.toolbar.AddLabelTool(wx.ID_OPEN,'Open Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_OPEN))
#        self.toolbar.AddLabelTool(wx.ID_SAVE,'Save Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE))
#        self.toolbar.AddLabelTool(wx.ID_SAVEAS,'Save Image As...',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE_AS))
#        self.toolbar.AddLabelTool(wx.ID_EXIT,'Quit',wx.ArtProvider.GetBitmap(wx.ART_QUIT))

        self.toolbar.AddSeparator()

        self.toolbar.AddLabelTool( wx.ID_UNDO, 'Undo', wx.ArtProvider_GetBitmap(wx.ART_UNDO))
        self.toolbar.AddLabelTool( wx.ID_REDO, 'Redo', wx.ArtProvider_GetBitmap(wx.ART_REDO))
        self.toolbar.EnableTool( wx.ID_UNDO, False )
        self.toolbar.EnableTool( wx.ID_REDO, False )


        self.toolbar.AddSeparator()

        self.zoom = wx.ComboBox(self.toolbar,-1,value='4x',choices=self.scales,size=(60,-1),style=wx.CB_DROPDOWN)
        self.toolbar.AddControl(self.zoom)

        self.toolbar.Realize()
        
        return self.toolbar


    def OnNew(self, e):
        dialog = Dialog.NewImage(None)
        dialog.ShowModal()
        dialog.Destroy()  


    def OnQuit(self, e):
        self.Destroy()


app = wx.App()
LSPaint(None, -1, 'LSPaint')
app.MainLoop()
