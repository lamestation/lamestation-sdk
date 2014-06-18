#!/usr/bin/python

import wx
import os
import ImageData
import PILtoWx


class ImageViewer(wx.Panel):
    def __init__(self, parent, name):
        super(ImageViewer, self).__init__(parent, name=name, size=(256,128))

        self.SetBackgroundColour('#000000')

        self.imageCtrl = wx.StaticBitmap(self, wx.ID_ANY, wx.NullBitmap)

        self.text = wx.StaticText(self, label=name)
        self.text.SetFont(wx.Font(11,wx.DEFAULT, wx.NORMAL, wx.BOLD))
        self.text.SetForegroundColour((255,255,255))


        vbox = wx.BoxSizer(wx.VERTICAL)
        vbox.Add(self.text, 0, wx.ALL, 2)
        vbox.Add(self.imageCtrl, 1, wx.EXPAND, 2)

        self.SetSizer(vbox)


    def SetBitmap(self,image):
        self.imageCtrl.SetBitmap(wx.BitmapFromImage(self.ScaleImage(image)))


    def ScaleImage(self,image):
        width = image.GetWidth()
        height = image.GetHeight()
        scale = 4
        return image.Scale(width*scale,height*scale)



class Example(wx.Frame):

    def FileMenu(self):
        fileMenu = wx.Menu()
        fileMenu.Append(wx.ID_NEW, '&New', 'New Image')        
        fileMenu.Append(wx.ID_OPEN, '&Open', 'Open Image')
        fileMenu.Append(wx.ID_SAVE, '&Save', 'Save Image')
        fileMenu.Append(wx.ID_SAVEAS, 'Save &As...', 'Save Image As...')
        fileMenu.AppendSeparator()
        fileMenu.Append(wx.ID_CLOSE, '&Close', 'Close image')
        fileMenu.Append(wx.ID_EXIT, '&Quit\tCtrl+Q', 'Quit application')

        wx.EVT_MENU(self, wx.ID_EXIT, self.OnQuit)
        wx.EVT_MENU(self, wx.ID_OPEN, self.OnBrowse)

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
        self.toolbar.AddLabelTool(wx.ID_NEW,'New',wx.ArtProvider.GetBitmap(wx.ART_NEW))
        self.toolbar.AddLabelTool(wx.ID_OPEN,'Open Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_OPEN))
        self.toolbar.AddLabelTool(wx.ID_SAVE,'Save Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE))
        self.toolbar.AddLabelTool(wx.ID_SAVEAS,'Save Image As...',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE_AS))
        self.toolbar.Realize()


    def __init__(self, parent, title):
        super(Example, self).__init__(parent, title=title)

        self.filename = ""


        self.vbox = wx.BoxSizer(wx.VERTICAL)

        self.panel1 = ImageViewer(self,"Original")     # old image
        self.panel2 = ImageViewer(self,"Result")     # new image

        # combine image panels
#        self.hbox1 = wx.BoxSizer(wx.HORIZONTAL)

        self.vbox.Add(self.panel1, 1, wx.EXPAND, 2)
        self.vbox.Add(self.panel2, 1, wx.EXPAND, 2)

        self.vbox.SetMinSize(size=(512,512))

        # controls
        self.ctrlpanel = wx.Panel(self)

        self.fcb = wx.CheckBox(self.ctrlpanel,label="Use frames")
        self.fx = wx.SpinCtrl(self.ctrlpanel,value='0',min=1, max=128)
        self.fy = wx.SpinCtrl(self.ctrlpanel,value='0',min=1, max=128)

        self.fcb.Bind(wx.EVT_CHECKBOX, self.ToggleFrameSize)
        self.fx.Bind(wx.EVT_SPINCTRL, self.OnUpdate)
        self.fy.Bind(wx.EVT_SPINCTRL, self.OnUpdate)

        self.fx.Enable(False)
        self.fy.Enable(False)

        self.hbox2 = wx.BoxSizer()
        self.hbox2.Add(self.fcb, proportion=0)
        self.hbox2.Add(self.fx, proportion=0)
        self.hbox2.Add(self.fy, proportion=0)

        self.ctrlpanel.SetSizerAndFit(self.hbox2)

        self.vbox.Add(self.ctrlpanel, 0)


        self.SetSizer(self.vbox)


        self.SetMenuBar(self.MenuBar())
        self.statusbar = self.CreateStatusBar()
        self.statusbar.SetStatusText('Ready')
        self.ToolBar()


        self.vbox.Fit(self)
        self.Layout()

        self.SetTitle('img2dat - Image Converter')
        self.Center()
        self.Show(True)



        self.aboutme = wx.MessageDialog( self, " A sample editor \n"
                            " in wxPython","About Sample Editor", wx.OK)
        self.doiexit = wx.MessageDialog( self, " Exit - R U Sure? \n",
                        "GOING away ...", wx.YES_NO)


    def ToggleFrameSize(self, e):
        if self.fcb.IsChecked():
            self.fx.Enable(True)
            self.fy.Enable(True)
        else:
            self.fx.Enable(False)
            self.fy.Enable(False)


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
        self.OnLoad()

 
    def OnLoad(self):
        self.imgdata = ImageData.ImageData()
        self.imgdata.openImage(self.filename)


        self.OnUpdate(None)

    def OnUpdate(self, e):

        try:
            self.imgdata
        except AttributeError:
            self.statusbar.SetStatusText('You should open an image first.')
            return

        self.imgdata.openImage(self.filename)

        if not self.fcb.IsChecked():
            self.fx.SetValue(self.imgdata.im.size[0])
            self.fy.SetValue(self.imgdata.im.size[1])

        # old image
        img = PILtoWx.PilImageToWxImage(self.imgdata.im)
        self.panel1.SetBitmap(img)


        self.imgdata.setFrameSize(tuple([self.fx.GetValue(),self.fy.GetValue()]))

        # new image
        self.imgdata.padFrames()
        spritedata = self.imgdata.renderSpriteData()
        spin = self.imgdata.assembleSpinFile(spritedata)
        
        img = PILtoWx.PilImageToWxImage(self.imgdata.im)
        self.panel2.SetBitmap(img)

        self.vbox.Fit(self)

        self.panel1.Refresh()
        self.panel2.Refresh()



    def OnQuit(self, e):
        self.Close()


if __name__ == '__main__':
    app = wx.App()
    Example(None, title='img2dat - Image Converter')
    app.MainLoop()
