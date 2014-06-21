#!/usr/bin/python

import wx
import ImageData

BITMAP_SIZE = 16
BITMAP_SCALE = 16
BITMAP_NEWSIZE = BITMAP_SIZE*BITMAP_SCALE
RECT = 32
COLOR = ImageData.colorvalue['none']['output']

def scale_bitmap(bitmap, width, height):
    image = wx.ImageFromBitmap(bitmap)
    image = image.Scale(width, height, wx.IMAGE_QUALITY_NORMAL)
    result = wx.BitmapFromImage(image)
    return result


class NewImage(wx.Dialog):
    def __init__(self, *args, **kw):
        super(NewImage, self).__init__(*args, **kw) 
            
        panel = wx.Panel(self)
        vbox = wx.BoxSizer(wx.VERTICAL)

        gs = wx.FlexGridSizer(2,2,5,5)

        add_w_txt = wx.StaticText(panel,label='Width:')
        add_h_txt = wx.StaticText(panel,label='Height:')
        add_w = wx.TextCtrl(panel,value='32')
        add_h = wx.TextCtrl(panel,value='32')

        gs.AddMany([
            (add_w_txt), (add_w,0,wx.ALL),
            (add_h_txt), (add_h,0,wx.ALL)
            ])

        panel.SetSizer(gs)


        hbox2 = wx.BoxSizer(wx.HORIZONTAL)
        okButton = wx.Button(self, label='Ok')
        closeButton = wx.Button(self, label='Close')
        hbox2.Add(okButton, border=5)
        hbox2.Add(closeButton, flag=wx.LEFT, border=5)

        
        vbox.Add(panel)
        vbox.Add(hbox2)
        self.SetSizerAndFit(vbox)
        
        okButton.Bind(wx.EVT_BUTTON, self.OnClose)
        closeButton.Bind(wx.EVT_BUTTON, self.OnClose)
        self.SetTitle("New Image")
        
        
    def OnClose(self, e):
        self.Destroy()





class DrawWindow(wx.Panel):
    x = 0
    y = 0
    ox = 0
    oy = 0

    def __init__(self, parent):
        wx.Panel.__init__(self, parent, 
                size=(BITMAP_NEWSIZE,BITMAP_NEWSIZE), style=wx.SUNKEN_BORDER)
        self.bmp = wx.EmptyBitmap(BITMAP_SIZE,BITMAP_SIZE)

        self.SetCursor(wx.StockCursor(wx.CURSOR_PENCIL))

        dc = wx.MemoryDC()
        dc.SelectObject(self.bmp)
        dc.Clear()
        dc.SetBrush(wx.Brush(ImageData.colorvalue['black']['output']))
        dc.FloodFill(0, 0, wx.Color(255,255,255))
        dc.SelectObject(wx.NullBitmap)

        dc = wx.ClientDC(self)
        dc.DrawBitmap(scale_bitmap(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)

        self.Bind(wx.EVT_MOTION, self.OnMouseMove)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)
        self.Bind(wx.EVT_RIGHT_DOWN, self.OnRightDown)
        self.Bind(wx.EVT_PAINT, self.OnPaint)


    def OnPaint(self, event):
        dc = wx.ClientDC(self)
        dc.DrawBitmap(scale_bitmap(self.bmp,BITMAP_NEWSIZE,BITMAP_NEWSIZE), 0, 0, True)


    def GetOldMouse(self):
        self.ox = self.x
        self.oy = self.y


    def GetMouse(self, event):
        self.GetOldMouse()
        self.x, self.y = event.GetPosition()
        self.x = self.x*BITMAP_SIZE/BITMAP_NEWSIZE
        self.y = self.y*BITMAP_SIZE/BITMAP_NEWSIZE


    def Draw(self, event):
        self.GetOldMouse()
        self.GetMouse(event)
        print self.x, self.y, self.ox, self.oy, COLOR
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

    def Read(self, event):
        global COLOR
        self.GetMouse(event)
        print self.x, self.y, self.ox, self.oy, COLOR

        dc = wx.MemoryDC()
        dc.SelectObject(self.bmp)
        COLOR = dc.GetPixel(self.x,self.y)
        dc.SelectObject(wx.NullBitmap)

    def OnLeftDown(self, event):
        self.Draw(event)

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


class ColorPicker(wx.Panel):
    def __init__(self, parent):
        wx.Panel.__init__(self, parent, 
                size=(RECT*4,RECT), style=wx.SUNKEN_BORDER)

        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)

    def OnPaint(self, e):
        dc = wx.PaintDC(self)

        inc = 0
        for c in range(0,4):
            color = '#%02x%02x%02x' % ImageData.colorvalue[ImageData.lookup[c]]['output']
            dc.SetBrush(wx.Brush(color))
            dc.SetPen(wx.Pen('#000000'))
            dc.DrawRectangle(RECT*inc, 0, RECT, RECT)

            inc += 1

    def OnLeftDown(self, event):
        self.x, self.y = event.GetPosition()
        self.x = self.x/RECT
        self.y = self.y/RECT
        print "clicked!", self.x, self.y, ImageData.lookup[self.x]
        global COLOR
        COLOR = '#%02x%02x%02x' % ImageData.colorvalue[ImageData.lookup[self.x]]['output']
        print COLOR


class LSPaint(wx.Frame):
    scale = 4
    scales = ['1x','2x','4x','8x','16x']
    width = 32
    height = 32

    def __init__(self, parent, id, title):
        wx.Frame.__init__(self, parent, id, title)
        panel = wx.Panel(self)
        hbox = wx.BoxSizer(wx.HORIZONTAL)
        linechart = DrawWindow(panel)
        hbox.Add(linechart, 0, wx.ALL, 0)
        panel.SetSizer(hbox)

        panel2 = wx.Panel(self)
        hbox2 = wx.BoxSizer(wx.HORIZONTAL)
        sidebar = ColorPicker(panel2)
        hbox2.Add(sidebar, 0, wx.ALL, 0)
        panel2.SetSizer(hbox2)

        hboxm = wx.BoxSizer(wx.HORIZONTAL)
        hboxm.Add(panel2)
        hboxm.Add(panel)

        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(hboxm)

        self.SetMenuBar(self.MenuBar())
        self.ToolBar()
        self.SetSizerAndFit(vbox)
        self.Show(True)


    def FileMenu(self):
        fileMenu = wx.Menu()
        fileMenu.Append(wx.ID_NEW, '&New', 'New Image')        
        fileMenu.Append(wx.ID_OPEN, '&Open', 'Open Image')
        fileMenu.Append(wx.ID_SAVE, '&Save', 'Save Image')
        fileMenu.Append(wx.ID_SAVEAS, 'Save &As...', 'Save Image As...')
        fileMenu.AppendSeparator()
        exp = fileMenu.Append(wx.ID_ANY, '&Export', 'Export Image As Spin')
        fileMenu.AppendSeparator()
        fileMenu.Append(wx.ID_CLOSE, '&Close', 'Close image')
        fileMenu.Append(wx.ID_EXIT, '&Quit\tCtrl+Q', 'Quit application')

        wx.EVT_MENU(self, wx.ID_NEW, self.OnNew)
        wx.EVT_MENU(self, wx.ID_EXIT, self.OnQuit)
#        wx.EVT_MENU(self, wx.ID_OPEN, self.OnBrowse)
#        self.Bind(wx.EVT_MENU, self.OnExport, exp)

        return fileMenu


    def HelpMenu(self):
        helpMenu = wx.Menu()
        helpMenu.Append(wx.ID_ABOUT, 'About', 'About LSPaint')
#        wx.EVT_MENU(self, wx.ID_ABOUT, self.OnAbout)

        return helpMenu

    def MenuBar(self):
        menubar = wx.MenuBar()

        menubar.Append(self.FileMenu(), '&File')
#        menubar.Append(self.FileMenu(), '&Edit')
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

        self.zoom = wx.ComboBox(self.toolbar,-1,value='4x',choices=self.scales,size=(60,-1),style=wx.CB_DROPDOWN)
        self.toolbar.AddControl(self.zoom)

#        self.zoom.Bind(wx.EVT_COMBOBOX, self.OnZoom)

        self.toolbar.Realize()


    def OnNew(self, e):
        dialog = NewImage(None, 
            title='New Image')
        dialog.ShowModal()
        dialog.Destroy()  


    def OnQuit(self, e):
        self.Destroy()


app = wx.App()
LSPaint(None, -1, 'LSPaint')
app.MainLoop()
