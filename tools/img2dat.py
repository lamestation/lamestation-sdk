#!/usr/bin/python

import wx
import os
import ImageData
import PILtoWx


PROGRAM_TITLE = "IMG2DAT - Image Converter"

class ImageViewer(wx.Panel):
    def __init__(self, parent, name):
        super(ImageViewer, self).__init__(parent, name=name)

        self.SetBackgroundColour('#000000')

        self.imageCtrl = wx.StaticBitmap(self, wx.ID_ANY, wx.NullBitmap)

        self.text = wx.StaticText(self, label=name)
        self.text.SetFont(wx.Font(11,wx.DEFAULT, wx.NORMAL, wx.BOLD))
        self.text.SetForegroundColour((255,255,255))

        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(self.text, 0, wx.ALL, 0)
        vbox.Add(self.imageCtrl, 1, wx.ALL, 0)
        vbox.SetMinSize((256,128))
        self.SetSizer(vbox)


    def SetBitmap(self,image,scale):
        self.imageCtrl.SetBitmap(wx.BitmapFromImage(self.ScaleImage(image,scale)))


    def ScaleImage(self,image,scale):
        width = image.GetWidth()
        height = image.GetHeight()
        return image.Scale(width*scale,height*scale)



class Example(wx.Frame):

    def FileMenu(self):
        fileMenu = wx.Menu()
#        fileMenu.Append(wx.ID_NEW, '&New', 'New Image')        
        fileMenu.Append(wx.ID_OPEN, '&Open', 'Open Image')
#        fileMenu.Append(wx.ID_SAVE, '&Save', 'Save Image')
#        fileMenu.Append(wx.ID_SAVEAS, 'Save &As...', 'Save Image As...')
        fileMenu.AppendSeparator()
        fileMenu.Append(wx.ID_CLOSE, '&Close', 'Close image')
        fileMenu.Append(wx.ID_EXIT, '&Quit\tCtrl+Q', 'Quit application')

        wx.EVT_MENU(self, wx.ID_EXIT, self.OnQuit)
        wx.EVT_MENU(self, wx.ID_OPEN, self.OnBrowse)
#        wx.EVT_MENU(self, wx.ID_SAVE, self.OnExport)

        return fileMenu

    def ViewMenu(self):
        viewMenu = wx.Menu()
        self.shst = viewMenu.Append(wx.ID_ANY, 'Show statubar', 
                'Show Statusbar', kind=wx.ITEM_CHECK)
        self.shtl = viewMenu.Append(wx.ID_ANY, 'Show toolbar', 
                'Show Toolbar', kind=wx.ITEM_CHECK)

        viewMenu.Check(self.shst.GetId(), True)
        viewMenu.Check(self.shtl.GetId(), True)


        self.Bind(wx.EVT_MENU, self.ToggleStatusBar, self.shst)
        self.Bind(wx.EVT_MENU, self.ToggleToolBar, self.shtl)

        return viewMenu

    def HelpMenu(self):
        helpMenu = wx.Menu()
        helpMenu.Append(wx.ID_ABOUT, 'About', 'About img2dat')
        wx.EVT_MENU(self, wx.ID_ABOUT, self.OnAbout)

        return helpMenu


    def MenuBar(self):
        menubar = wx.MenuBar()

        menubar.Append(self.FileMenu(), '&File')
        menubar.Append(self.ViewMenu(), '&View')
        menubar.Append(self.HelpMenu(), '&Help')

        return menubar

    def ToolBar(self):
        self.toolbar = self.CreateToolBar()
        self.toolbar.AddLabelTool(wx.ID_EXIT,'Quit',wx.ArtProvider.GetBitmap(wx.ART_QUIT))
        #self.toolbar.AddLabelTool(wx.ID_NEW,'New',wx.ArtProvider.GetBitmap(wx.ART_NEW))
        self.toolbar.AddLabelTool(wx.ID_OPEN,'Open Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_OPEN))
#        self.toolbar.AddLabelTool(wx.ID_SAVE,'Save Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE))
#        self.toolbar.AddLabelTool(wx.ID_SAVEAS,'Save Image As...',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE_AS))

        self.toolbar.EnableTool(wx.ID_SAVE, False)

        self.toolbar.AddSeparator()

#        self.fcb = wx.CheckBox(self.toolbar,label="Chop image")
        self.fcb = wx.ToggleButton(self.toolbar,label="Chop image")
        self.fx = wx.SpinCtrl(self.toolbar,size=(50,-1),value='8',min=1, max=128)
        self.fy = wx.SpinCtrl(self.toolbar,size=(50,-1),value='8',min=1, max=128)
        self.toolbar.AddControl(self.fcb)
        self.toolbar.AddControl(self.fx)
        self.toolbar.AddControl(self.fy)

        self.fcb.Bind(wx.EVT_TOGGLEBUTTON, self.ToggleFrameSize)
        self.fx.Bind(wx.EVT_SPINCTRL, self.OnSetFrameSize)
        self.fy.Bind(wx.EVT_SPINCTRL, self.OnSetFrameSize)

        self.fcb.Enable(False)
        self.fx.Enable(False)
        self.fy.Enable(False)

        self.toolbar.AddSeparator()

        self.zoom = wx.ComboBox(self.toolbar,-1,value='4x',choices=self.scales,size=(60,-1),style=wx.CB_DROPDOWN)
        self.toolbar.AddControl(self.zoom)

        self.zoom.Bind(wx.EVT_COMBOBOX, self.OnZoom)

        self.toolbar.AddSeparator()

        self.export = wx.Button(self.toolbar,-1,label="Export")
        self.export.Bind(wx.EVT_BUTTON, self.OnExport)


        self.toolbar.Realize()


    def __init__(self, parent, title):
        super(Example, self).__init__(parent, title=title)#, style=wx.DEFAULT_FRAME_STYLE ^ wx.RESIZE_BORDER)

        self.filename = ""
        self.scale = 4
        self.scales = ['1x','2x','4x','8x','16x']

        self.panel1 = ImageViewer(self,"Original")     # old image
        self.panel2 = ImageViewer(self,"Result")     # new image

        self.hbox_inner = wx.BoxSizer(wx.HORIZONTAL)
        self.hbox_inner.Add(self.panel1, 0, wx.EXPAND, 2)
        self.hbox_inner.Add(self.panel2, 0, wx.EXPAND, 2)

        self.vbox = wx.BoxSizer(wx.VERTICAL)
        self.vbox.Add(self.hbox_inner)

        self.hbox = wx.BoxSizer(wx.HORIZONTAL)
        self.hbox.Add(self.vbox)

#        self.hbox.SetMinSize((350,256))
        self.SetSizer(self.hbox)


        self.SetMenuBar(self.MenuBar())
        self.statusbar = self.CreateStatusBar()
        self.statusbar.SetStatusText('Ready')
        self.ToolBar()


        self.SetSizerAndFit(self.hbox)
        self.Layout()

        self.SetTitle(title)
        self.Center()
        self.Show(True)


        self.Bind(wx.EVT_CLOSE, self.OnQuit)

        self.aboutme = wx.MessageDialog( self, " A sample editor \n"
                            " in wxPython","About Sample Editor", wx.OK)


    def ToggleFrameSize(self, e):
        if self.fcb.GetValue():
            self.fx.Enable(True)
            self.fy.Enable(True)
        else:
            self.fx.Enable(False)
            self.fy.Enable(False)

        self.OnUpdate(None)


    def ToggleStatusBar(self, e):

        if self.shst.IsChecked():
            self.statusbar.Show()
        else:
            self.statusbar.Hide()


    def ToggleToolBar(self, e):

        if self.shtl.IsChecked():
            self.toolbar.Show()
        else:
            self.toolbar.Hide()        


    def OnAbout(self,e):
        self.aboutme.ShowModal()


    def OnBrowse(self, event):
        wildcard = "All files (*)|*|PNG files (*.png)|*.png|GIF files (*.gif)|*.gif|Bitmap files (*.bmp)|*.bmp|GIF files (*.gif)|*.gif|JPEG files (*.jpg)|*.jpg"
        dialog = wx.FileDialog(None, "Choose a file",
                wildcard=wildcard,
                style=wx.OPEN)
        if dialog.ShowModal() == wx.ID_OK:
            self.filename = dialog.GetPath()
            self.statusbar.SetStatusText(self.filename)
        dialog.Destroy()

        if not self.filename == '':
            self.OnLoad()


    def OnExport(self, event):
        print self.spin

 
    def OnLoad(self):
        self.imgdata = ImageData.ImageData()
        self.imgdata.openImage(self.filename)

        try:
            self.imgdata.im
        except:
            print "BAHL"

        self.fcb.Enable(True)
        self.toolbar.EnableTool(wx.ID_SAVE, True)

        self.OnUpdate(None)

    def OnZoom(self, event):
        self.scale = int(self.zoom.GetValue().split('x')[0])
        self.OnUpdate(None)


    def OnSetFrameSize(self, event):

        if self.fx.GetValue() > self.imgdata.im.size[0]:
            self.fx.SetValue(self.imgdata.im.size[0])
            return

        if self.fy.GetValue() > self.imgdata.im.size[1]:
            self.fy.SetValue(self.imgdata.im.size[1])
            return
        
        print self.imgdata.im.size
        print self.fx.GetValue()
        print self.fy.GetValue()
        self.OnUpdate(None)

    def OnUpdate(self, e):

        try:
            self.imgdata
        except AttributeError:
            self.statusbar.SetStatusText('You should open an image first.')
            return

        try:
            self.imgdata.openImage(self.filename)
        except:
            self.statusbar.SetStatusText('Failed to open image!')

        self.statusbar.SetStatusText('Opened '+self.filename)

        # old image
        img = PILtoWx.PilImageToWxImage(self.imgdata.im)
        self.panel1.SetBitmap(img,self.scale)

        if self.fcb.GetValue():
            self.imgdata.setFrameSize(tuple([self.fx.GetValue(),self.fy.GetValue()]))
        else:
            self.imgdata.setFrameSize(self.imgdata.im.size)

        # new image
        self.imgdata.padFrames()
        spritedata = self.imgdata.renderSpriteData()
        self.spin = self.imgdata.assembleSpinFile(spritedata)
        
        img = PILtoWx.PilImageToWxImage(self.imgdata.im)
        self.panel2.SetBitmap(img,self.scale)

        self.panel1.Refresh()
        self.panel2.Refresh()

        self.SetSizerAndFit(self.hbox)

    def OnQuit(self, e):
#        dial = wx.MessageDialog(None, "Are you sure you want to quit?","Question",
#                wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
#        result = dial.ShowModal()
#        if result == wx.ID_YES:
            self.Destroy()


if __name__ == '__main__':
    app = wx.App()
    Example(None, title=PROGRAM_TITLE)
    app.MainLoop()
