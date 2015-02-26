#!/usr/bin/python

import os, sys
import wx
from . import ImageData, Dialog
from . import files
import PILtoWx
from PIL import Image
import argparse

PROGRAM_TITLE = "IMG2DAT - Image Converter"
MIN_SIZE = 2

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
        vbox.SetMinSize((256,256))
        self.SetSizer(vbox)


    def SetBitmap(self,image,scale):
        self.imageCtrl.SetBitmap(wx.BitmapFromImage(self.ScaleImage(image,scale)))


    def ScaleImage(self,image,scale):
        width = image.GetWidth()
        height = image.GetHeight()
        return image.Scale(width*scale,height*scale)



class ImageConverter(wx.Frame):

    def FileMenu(self):
        fileMenu = wx.Menu()
        fileMenu.Append(wx.ID_OPEN, '&Open', 'Open Image')
        fileMenu.AppendSeparator()
        exp = fileMenu.Append(wx.ID_ANY, '&Export\tCtrl+E', 'Export Image As Spin')
        fileMenu.AppendSeparator()
        fileMenu.Append(wx.ID_EXIT, '&Quit\tCtrl+Q', 'Quit application')

        wx.EVT_MENU(self, wx.ID_EXIT, self.OnQuit)
        wx.EVT_MENU(self, wx.ID_OPEN, self.OnBrowse)
        self.Bind(wx.EVT_MENU, self.OnExport, exp)

        return fileMenu

    def HelpMenu(self):
        helpMenu = wx.Menu()
        helpMenu.Append(wx.ID_ABOUT, 'About', 'About img2dat')
        wx.EVT_MENU(self, wx.ID_ABOUT, self.OnAbout)

        return helpMenu


    def MenuBar(self):
        menubar = wx.MenuBar()

        menubar.Append(self.FileMenu(), '&File')
        menubar.Append(self.HelpMenu(), '&Help')

        return menubar

    def ToolBar(self):
        self.toolbar = self.CreateToolBar()
#        self.toolbar.AddLabelTool(wx.ID_EXIT,'Quit',wx.ArtProvider.GetBitmap(wx.ART_QUIT))
        #self.toolbar.AddLabelTool(wx.ID_NEW,'New',wx.ArtProvider.GetBitmap(wx.ART_NEW))
        self.toolbar.AddLabelTool(wx.ID_OPEN,'Open Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_OPEN))
#        self.toolbar.AddLabelTool(wx.ID_SAVE,'Save Image',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE))
#        self.toolbar.AddLabelTool(wx.ID_SAVEAS,'Save Image As...',wx.ArtProvider.GetBitmap(wx.ART_FILE_SAVE_AS))

        self.export = wx.Button(self.toolbar,label="Export")
        self.toolbar.AddControl(self.export)
        self.export.Bind(wx.EVT_BUTTON, self.OnExport)

        self.export.Enable(False)
        self.toolbar.EnableTool(wx.ID_SAVE, False)

        self.toolbar.AddSeparator()

        self.fcb = wx.ToggleButton(self.toolbar,label="Chop image")
        self.fx = wx.SpinCtrl(self.toolbar,size=(50,-1),value='8',min=MIN_SIZE, max=128)
        self.fy = wx.SpinCtrl(self.toolbar,size=(50,-1),value='8',min=MIN_SIZE, max=128)
        self.toolbar.AddControl(self.fcb)
        self.toolbar.AddControl(self.fx)
        self.toolbar.AddControl(self.fy)

        self.fcb.Bind(wx.EVT_TOGGLEBUTTON, self.ToggleFrameSize)
        self.fx.Bind(wx.EVT_SPINCTRL, self.OnUpdate)
        self.fy.Bind(wx.EVT_SPINCTRL, self.OnUpdate)

        self.fcb.Enable(False)
        self.fx.Enable(False)
        self.fy.Enable(False)

        self.toolbar.AddSeparator()

        self.zoom = wx.ComboBox(self.toolbar,-1,value='4x',choices=self.scales,size=(60,-1),style=wx.CB_DROPDOWN)
        self.toolbar.AddControl(self.zoom)

        self.zoom.Bind(wx.EVT_COMBOBOX, self.OnZoom)

        self.toolbar.Realize()


    def __init__(self, parent, title):
        super(ImageConverter, self).__init__(parent, title=title)

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

    def ToggleFrameSize(self, e):
        if self.fcb.GetValue():
            self.fx.Enable(True)
            self.fy.Enable(True)
        else:
            self.fx.Enable(False)
            self.fy.Enable(False)

        self.OnUpdate(None)

    def OnAbout(self,e):
        Dialog.About()


    def OnBrowse(self, event):
        wildcard = "All files (*)|*|PNG files (*.png)|*.png|GIF files (*.gif)|*.gif|Bitmap files (*.bmp)|*.bmp|GIF files (*.gif)|*.gif|JPEG files (*.jpg)|*.jpg"
        dialog = wx.FileDialog(None, "Choose a file",
                wildcard=wildcard,
                style=wx.FD_OPEN|wx.FD_CHANGE_DIR|wx.FD_PREVIEW)
        if dialog.ShowModal() == wx.ID_OK:
            self.filename = dialog.GetPath()
            self.statusbar.SetStatusText(self.filename)
        dialog.Destroy()

        if not self.filename == '':
            self.OnLoad()


    def OnExport(self, event):
        wildcard = "Spin files (*.spin)|*.spin"
        dialog = wx.FileDialog(None, "Choose a file",
                defaultDir=os.path.dirname(self.filename),
                defaultFile=os.path.splitext(os.path.basename(self.filename))[0]+".spin",
                wildcard=wildcard,
                style=wx.FD_SAVE|wx.OVERWRITE_PROMPT)
        if dialog.ShowModal() == wx.ID_OK:
            f = open(dialog.GetPath(),"w")
            f.write(self.spin.encode('utf8'))
            f.close()

            self.statusbar.SetStatusText("Wrote to "+dialog.GetPath())
        dialog.Destroy()


    def OnLoad(self):
        self.imgdata = ImageData.ImageData()

        try:
            self.imgdata.openImage(self.filename)
        except:
            wx.MessageBox('That is not a valid image file', 'Info', 
                wx.OK | wx.ICON_EXCLAMATION)
            return

        # old image
        self.oldim = self.imgdata.im
        self.fx.SetRange(MIN_SIZE,self.oldim.size[0])
        self.fy.SetRange(MIN_SIZE,self.oldim.size[1])

        self.statusbar.SetStatusText('Opened '+self.filename)

        self.export.Enable(True)
        self.fcb.Enable(True)
        self.toolbar.EnableTool(wx.ID_SAVE, True)

        self.OnUpdate(None)

    def OnZoom(self, event):
        self.scale = int(self.zoom.GetValue().split('x')[0])
        self.OnUpdate(None)

    def OnUpdate(self, e):

        try:
            self.imgdata.im = self.oldim
        except:
            return

        if self.fcb.GetValue():
            self.imgdata.setFrameSize(tuple([self.fx.GetValue(),self.fy.GetValue()]))
        else:
            self.imgdata.setFrameSize(self.imgdata.im.size)

        # old image
        img = PILtoWx.PilImageToWxImage(self.oldim)
        self.panel1.SetBitmap(img,self.scale)

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
    #    if Dialog.Quit() == wx.ID_YES:
        self.Destroy()

def gui():
    app = wx.App()
    ImageConverter(None, title=PROGRAM_TITLE)
    app.MainLoop()


def displayResult(scale, oldimage, newimage):
    canvas = Image.new("RGB",(newimage.size[0],oldimage.size[1]+newimage.size[1]))

    canvas.paste(oldimage,(0,0,oldimage.size[0],oldimage.size[1]))
    canvas.paste(newimage,(0,oldimage.size[1]))
    
    canvas = canvas.resize(tuple([scale*x for x in (newimage.size[0],oldimage.size[1]+newimage.size[1])]))
    canvas.show()

def console():
    parser = argparse.ArgumentParser(description='Convert images to Propeller Spin data blocks for use with Lame Graphics.')

    parser.add_argument('-b','--bits', nargs=1, metavar=('BITS'), type=int, choices=[2,8],default=[2],
            help="Bit depth of images.")
    parser.add_argument('-f','--framesize', nargs=2, metavar=('WIDTH','HEIGHT'), type=int,
            help="Size of individual sprite frames (only needed for sprites).")
    parser.add_argument('-d','--display', action='store_true',
            help="Display conversion results.")
    parser.add_argument('-w','--write',action='store_true',
            help="Write results to file.")
    parser.add_argument('--noprint', action='store_true',
            help="Don't print conversion output to screen.")

    parser.add_argument('filenames', metavar='FILE', nargs='+', help='Files to convert')
    args = parser.parse_args()

    args = getCommandLineArguments()
    filenames = files.cleanFilenames(args.filenames)

    if not filenames:
        print "No valid files selected"
        sys.exit(1)

    for filename in filenames:

        imgdata = ImageData.ImageData()
        imgdata.openImage(filename)

        if args.framesize:
            try:
                imgdata.setFrameSize(tuple(args.framesize))
            except ValueError as detail:
                print "error:",detail
                sys.exit(1)

        oldim = imgdata.im
        imgdata.setLogicalFrameSize()

        imgdata.padFrames()
        spritedata = imgdata.renderSpriteData()
        spin = imgdata.assembleSpinFile(spritedata)

        if args.display:
            displayResult(4, oldim, imgdata.im)

        if args.write:
            files.writeFile(spin,imgdata.fullfilename)

        if not args.noprint:
            print spin
