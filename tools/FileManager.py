import wx, os
from wx.lib.pubsub import setuparg1 
from wx.lib.pubsub import pub
import logging
import Bitmap

class File(object):

    def __init__(self):
        File.New(self)

    def New(self):
        self.data = None

        self.filename = ""
        self.shortname = ""
        self.ext = ""

        self.stackUndo = []
        self.stackRedo = []
        self.undo = False
        self.redo = False

    def Load(self, filename):
        self.filename = filename
        self.shortname = os.path.splitext(os.path.basename(self.filename))[0]
        self.ext = self.filename.split('.')[-1].lower()

    def Update(self, data):
        self.data = data

    def Print(self):
        print self.filename
        print self.shortname
        print self.ext

    def Save(self):
        print "BLAH"


    def PushUndo(self, operation):
        self.undo = True
        self.stackUndo.append( operation )
        if self.stackRedo:
            del self.stackRedo[:]
            self.redo = False

    def PopUndo(self):
        if len(self.stackUndo) == 0:
            self.undo = False
            return

        a = self.stackUndo.pop()
        if len(self.stackUndo) == 0:
            self.undo = False

        self.data = a.undo()
        self.stackRedo.append(a)
        self.redo = True

    def PopRedo(self):
        if len(self.stackRedo) == 0:
            self.redo = False
            return

        a = self.stackRedo.pop()
        if len(self.stackRedo) == 0:
            self.redo = False

        self.data = a.redo()
        self.stackUndo.append(a)
        self.undo = True


class Image(File):
    def __init__(self):
        File.__init__(self)

    def New(self, w, h):
        File.New(self)
        self.data = Bitmap.New(w, h)

    def Load(self, filename):
        File.Load(self, filename=filename)
        self.data = wx.Bitmap(self.filename, wx.BITMAP_TYPE_ANY)

    def Save(self, filename):
        self.data.SaveFile(filename, wx.BITMAP_TYPE_PNG)



class FileManager(object):
    index = 0
    filetype = ''
    filetypearray = {'image':[''],'map':[]}
    typetable = {'image':{'png':wx.BITMAP_TYPE_PNG,'bmp':wx.BITMAP_TYPE_BMP}}

    _instance = None
    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(FileManager, cls).__new__(
                                cls, *args, **kwargs)
        return cls._instance

    def CurrentType(self):
        return self.filetype

    def CurrentIndex(self):
        return self.index

    def CurrentFile(self):
        return self.filetypearray[self.filetype][self.index]

    def New(self, filetype, w, h):
        self.filetype = filetype
        im = Image()
        im.New(w, h)
        #self.filetypearray[self.filetype].append(im)
        self.filetypearray[self.filetype][0] = im
        logging.info("FileManager.%i.New('%s', %i, %i)" % 
                (self.index, self.filetype, w, h))

    def Load(self, filetype, filename):
        if not os.path.isfile(filename):
            raise
        self.filetype = filetype

        im = Image()
        im.Load(filename)
        #self.filetypearray[self.filetype].append(im)
        self.filetypearray[self.filetype][0] = im
        pub.sendMessage("UpdateBitmap",im.data)

        logging.info("FileManager.%i.Load('%s', '%s')" % 
                (self.index, self.filetype, filename))

    def Save(self):
        if not self.CurrentFile().filename == '':
            self.CurrentFile().Save()
            logging.info("FileManager.%i.Save()" % 
                    (self.index))

    def SaveAs(self, filename):
        self.CurrentFile().Save(filename)
        logging.info("FileManager.%i.SaveAs('%s')" % 
                (self.index, filename))

    def Close(self):
        del self.filetypearray[self.filetype][self.index]

        logging.info("FileManager.%i.Close()" % (self.index))


#    def OnExport(self, event):
#        wildcard = "Spin files (*.spin)|*.spin"
#        dialog = wx.FileDialog(None, "Choose a file",
#                defaultDir=os.path.dirname(self.parent.filename),
#                defaultFile=os.path.splitext(os.path.basename(self.parent.filename))[0]+".spin",
#                wildcard=wildcard,
#                style=wx.FD_SAVE|wx.OVERWRITE_PROMPT)
#        if dialog.ShowModal() == wx.ID_OK:
#            pass
##            f = open(dialog.GetPath(),"w")
##            f.write(self.spin.encode('utf8'))
##            f.close()
#
#            self.statusbar.SetStatusText("Wrote to "+dialog.GetPath())
#        dialog.Destroy()

        #self.imgdata = ImageData.ImageData()

        #try:
        #    self.imgdata.openImage(self.filename)
        #except:
        #    wx.MessageBox('That is not a valid image file', 'Info', 
        #        wx.OK | wx.ICON_EXCLAMATION)
