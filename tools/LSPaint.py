#!/usr/bin/python

import wx
import Color
import logging
from wx.lib.pubsub import setuparg1 
from wx.lib.pubsub import pub

import DrawWindow
import Bitmap
from FileManager import FileManager

import EventHandler

BITMAP_MAXSIZE = 256

logging.basicConfig(level=logging.INFO)

class ImageTile(wx.Panel):

    def __init__(self, parent, size=(128,128), scale=1, style=None):
        wx.Panel.__init__(self, parent, 

                size=size, style=wx.TAB_TRAVERSAL|wx.NO_BORDER)
        self.scale = scale

        self.Bind(wx.EVT_PAINT, self.OnPaint)
        pub.subscribe(self.UpdateBitmap,"UpdateBitmap")

    def UpdateBitmap(self, message):
        f = FileManager().CurrentFile()
        self.SetSize((f.data.GetWidth()*self.scale,f.data.GetWidth()*self.scale))
        self.OnPaint(None)

    def OnPaint(self, event):
        f = FileManager().CurrentFile()
        dc = wx.ClientDC(self)
        dc.DrawBitmap(Bitmap.Scale(f.data,f.data.GetWidth()*self.scale,f.data.GetHeight()*self.scale), 0, 0, True)

    def OnMouseMove(self, event):
        self.SetCursor(wx.StockCursor(wx.CURSOR_ARROW))


class ColorTile(wx.Panel):

    def __init__(self, parent, size, color, style=wx.TAB_TRAVERSAL|wx.NO_BORDER):
        wx.Panel.__init__(self, parent, size=size, style=style)

        self.size = self.GetSize()
        self.color = color
        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_LEFT_DOWN, self.OnLeftDown)

    def OnPaint(self, event):
        dc = wx.PaintDC(self)
        dc.SetBrush(wx.Brush(self.color))
        dc.SetPen(wx.Pen(self.color))
        dc.DrawRectangle(0, 0, self.size[0],self.size[1])

    def OnLeftDown(self, event):
        Color.Change(self.color)

class ChosenColor(ColorTile):

    def __init__(self, parent, size, style=wx.TAB_TRAVERSAL|wx.SUNKEN_BORDER):
        ColorTile.__init__(self, parent, size=size, color=Color.COLOR, style=style)

        pub.subscribe(self.SetColor, "COLOR")

    def SetColor(self, message):
        self.color = Color.COLOR
        self.OnPaint(None)


class SideBar(wx.Panel):

    def __init__(self, parent):
        wx.Panel.__init__(self, parent)

        cp1 = Color.ColorPicker(self)
        cc = ChosenColor(self,(50,50))

        ss = Color.StylePicker(self)


        panel = wx.Panel(self)
        tt = ImageTile(panel,scale=2)
        hbox = wx.BoxSizer(wx.HORIZONTAL)
        hbox.Add(tt, 1, wx.ALL|wx.ALIGN_CENTER, 0)
        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(hbox, 1, wx.ALL|wx.ALIGN_CENTER, 0)
        panel.SetSizer(vbox)


        vbox = wx.FlexGridSizer(rows=4,cols=1, hgap=5, vgap=5)
        vbox.Add(cc, 0, wx.ALL|wx.ALIGN_CENTER)
        vbox.Add(cp1, 0, wx.ALL|wx.ALIGN_CENTER)
        vbox.Add(ss, 0, wx.ALL|wx.ALIGN_CENTER)
        vbox.Add(panel, 0, wx.ALL|wx.ALIGN_CENTER)

        hbox = wx.BoxSizer(wx.VERTICAL)
        hbox.Add(vbox, 0, wx.ALL|wx.ALIGN_CENTER, 0)

        self.SetSizer(hbox)


class LSPaint(wx.Frame):
    scale = 4
    scales = ['1x','2x','4x','8x','16x']
    width = 32
    height = 32

    def __init__(self, parent, id, title):
        wx.Frame.__init__(self, parent, id, title, size=(600,600))


        self.filename = ""
        self.evt = EventHandler.EventHandler(self)
        self.toolbar = self.ToolBar()
        self.MenuBar()
        self.SetMenuBar(self.menu)
        self.statusbar = self.CreateStatusBar()
        self.statusbar.SetStatusText('Ready')


        # SideBar
        self.sidebar = wx.Panel(self, style=wx.RAISED_BORDER)
        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(SideBar(self),1,wx.EXPAND,0)
        self.sidebar.SetSizer(vbox)

        self.draw = DrawWindow.DrawWindow(self)

        # Combine windows
        hboxm = wx.BoxSizer(wx.HORIZONTAL)
        hboxm.Add(self.sidebar,0,wx.EXPAND,0)
        hboxm.Add(self.draw,1,wx.EXPAND,0)

        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(hboxm,1, wx.EXPAND, 0)


        wx.EVT_TOOL(self.toolbar, wx.ID_UNDO, self.evt.OnUndo)
        wx.EVT_TOOL(self.toolbar, wx.ID_REDO, self.evt.OnRedo)
        wx.EVT_MENU(self, wx.ID_UNDO, self.evt.OnUndo)
        wx.EVT_MENU(self, wx.ID_REDO, self.evt.OnRedo)

        wx.EVT_MENU(self, wx.ID_NEW, self.evt.OnNew)
        wx.EVT_MENU(self, wx.ID_OPEN, self.evt.OnLoad)
        wx.EVT_MENU(self, wx.ID_SAVE, self.evt.OnSave)
        wx.EVT_MENU(self, wx.ID_SAVEAS, self.evt.OnSaveAs)
        wx.EVT_MENU(self, wx.ID_CLOSE, self.evt.OnClose)
        wx.EVT_MENU(self, wx.ID_EXIT, self.evt.OnQuit)
        self.Bind(wx.EVT_MENU, self.evt.OnExport, self.exp)
#        wx.EVT_MENU(self, wx.ID_ABOUT, self.evt.OnAbout)
        self.zoom.Bind(wx.EVT_COMBOBOX, self.evt.OnZoom)

        self.SetSizer(vbox)
        self.Show(True)


    def MenuBar(self):
        menufile = wx.Menu()
        menufile.Append(wx.ID_NEW, '&New', 'New Image')        
        menufile.Append(wx.ID_OPEN, '&Open', 'Open Image')
        menufile.Append(wx.ID_SAVE, '&Save', 'Save Image')
        menufile.Append(wx.ID_SAVEAS, 'Save &As...', 'Save Image As...')
        menufile.AppendSeparator()
        self.exp = menufile.Append(wx.ID_ANY, '&Export', 'Export Image As Spin')
        menufile.AppendSeparator()
        menufile.Append(wx.ID_CLOSE, '&Close', 'Close image')
        menufile.Append(wx.ID_EXIT, '&Quit\tCtrl+Q', 'Quit application')

        menuedit = wx.Menu()
        menuedit.Append(wx.ID_UNDO, '&Undo\tCtrl+z', 'Undo')        
        menuedit.Append(wx.ID_REDO, '&Redo\tCtrl+Shift+z', 'Redo')
        menuedit.AppendSeparator()
        menuedit.Append(wx.ID_CUT, 'Cu&t', 'Cut To Clipoard')
        menuedit.Append(wx.ID_COPY, '&Copy', 'Copy To Clipboard')
        menuedit.Append(wx.ID_PASTE, 'Paste','Paste Into Image')


        menuhelp = wx.Menu()
        menuhelp.Append(wx.ID_ABOUT, 'About', 'About LSPaint')

        self.menu = wx.MenuBar()

        self.menu.Append(menufile, '&File')
        self.menu.Append(menuedit, '&Edit')
        self.menu.Append(menuhelp, '&Help')

        return self.menu

    def ToolBar(self):
        self.toolbar = self.CreateToolBar()
        self.toolbar.AddLabelTool(wx.ID_NEW,'New',wx.ArtProvider.GetBitmap(wx.ART_NEW))
        self.toolbar.AddLabelTool(wx.ID_OPEN,'Open Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_OPEN))
        self.toolbar.AddLabelTool(wx.ID_SAVE,'Save Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE))
        self.toolbar.AddLabelTool(wx.ID_SAVEAS,'Save Image As...',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE_AS))

        self.toolbar.AddSeparator()

        self.toolbar.AddLabelTool( wx.ID_UNDO, 'Undo', wx.ArtProvider_GetBitmap(wx.ART_UNDO))
        self.toolbar.AddLabelTool( wx.ID_REDO, 'Redo', wx.ArtProvider_GetBitmap(wx.ART_REDO))
        self.toolbar.EnableTool( wx.ID_UNDO, False )
        self.toolbar.EnableTool( wx.ID_REDO, False )
        self.toolbar.EnableTool( wx.ID_SAVE, False )


        self.toolbar.AddSeparator()

        self.zoom = wx.ComboBox(self.toolbar,-1,value='4x',choices=self.scales,size=(60,-1),style=wx.CB_DROPDOWN)
        self.toolbar.AddControl(self.zoom)

        self.toolbar.Realize()
        
        return self.toolbar


app = wx.App()
LSPaint(None, -1, 'LSPaint')
app.MainLoop()
