
import wx, os
from wx.lib.pubsub import setuparg1 
from wx.lib.pubsub import pub

import Bitmap, Dialog
from FileManager import FileManager

class UndoDraw:
    def __init__( self, oldbmp, bmp):
        self.bmp = bmp
        self.RedoBitmap = Bitmap.Copy(bmp) # image after change
        self.UndoBitmap = oldbmp # image before change
    
    def undo( self ):
        if not self.UndoBitmap == None:
                self.bmp = self.UndoBitmap
        return self.bmp
    
    def redo( self ):
        if not self.RedoBitmap == None:
                self.bmp = self.RedoBitmap
        return self.bmp


class EventHandler():
    def __init__(self, parent):
        self.parent = parent

        pub.subscribe(self.OnDraw, "DRAW")
        pub.subscribe(self.OnUndo, "UNDO")
        pub.subscribe(self.OnRedo, "REDO")

    def OnNew(self, event):
        dialog = Dialog.NewImage(None)
        dialog.ShowModal()

    def OnSave(self, event):
        pass
#        if not self.CurrentFile().filename == '':
#            fm = FileManager()
#            fm.Save()
#        else:


    def OnSaveAs(self, event):
        wildcard = "PNG files (*.png)|*.png"
        dialog = wx.FileDialog(None, "Choose a file",
                defaultDir=os.path.dirname(self.parent.filename),
                defaultFile=os.path.splitext(os.path.basename(self.parent.filename))[0]+".png",
                wildcard=wildcard,
                style=wx.FD_SAVE|wx.OVERWRITE_PROMPT)
        if dialog.ShowModal() == wx.ID_OK:
            self.filename = dialog.GetPath()
            self.parent.statusbar.SetStatusText("Saved "+self.filename)
            fm = FileManager()
            fm.SaveAs(self.filename)


    def OnLoad(self, event):
        wildcard = "All files (*)|*|PNG files (*.png)|*.png|GIF files (*.gif)|*.gif|Bitmap files (*.bmp)|*.bmp|GIF files (*.gif)|*.gif|JPEG files (*.jpg)|*.jpg"
        dialog = wx.FileDialog(None, "Choose a file",
                wildcard=wildcard,
                style=wx.FD_OPEN|wx.FD_CHANGE_DIR|wx.FD_PREVIEW)
        if dialog.ShowModal() == wx.ID_OK:
            self.filename = dialog.GetPath()
            self.parent.statusbar.SetStatusText("Loaded "+self.filename)
            fm = FileManager()
            fm.Load('image',self.filename)
            pub.sendMessage("UpdateBitmap")
        dialog.Destroy()



    def OnExport(self, event):
        wildcard = "Spin files (*.spin)|*.spin"
        dialog = wx.FileDialog(None, "Choose a file",
                defaultDir=os.path.dirname(self.parent.filename),
                defaultFile=os.path.splitext(os.path.basename(self.parent.filename))[0]+".spin",
                wildcard=wildcard,
                style=wx.FD_SAVE|wx.OVERWRITE_PROMPT)
        if dialog.ShowModal() == wx.ID_OK:
            pass
#            f = open(dialog.GetPath(),"w")
#            f.write(self.spin.encode('utf8'))
#            f.close()

            self.statusbar.SetStatusText("Wrote to "+dialog.GetPath())
        dialog.Destroy()


    def OnClose(self, event):
        fm = FileManager()
        fm.Close()
        self.parent.statusbar.SetStatusText("CLOSED")

    def OnQuit(self, event):
        self.parent.Destroy()


    def OnDraw(self, message):
        f = FileManager().CurrentFile()
        f.PushUndo(UndoDraw(
            message.data[0],message.data[1]))
        self.SetUndoRedo()

    def OnUndo( self, event ):
        f = FileManager().CurrentFile()
        f.PopUndo()
        self.SetUndoRedo()

    def OnRedo( self, event ):
        f = FileManager().CurrentFile()
        f.PopRedo()
        self.SetUndoRedo()

    def SetUndoRedo(self):
        f = FileManager().CurrentFile()
        self.parent.toolbar.EnableTool( wx.ID_UNDO, f.undo)
        self.parent.toolbar.EnableTool( wx.ID_SAVE, f.undo)
        self.parent.menu.Enable( wx.ID_UNDO, f.undo)
        self.parent.menu.Enable( wx.ID_SAVE, f.undo)

        self.parent.toolbar.EnableTool( wx.ID_REDO, f.redo)
        self.parent.menu.Enable( wx.ID_REDO, f.redo)

        f = FileManager().CurrentFile()
        print f.data
        pub.sendMessage("UpdateBitmap")
        
    def OnZoom(self, event):
        print self.parent.zoom.GetValue().split('x')[0]
        self.parent.draw.draw.scale = int(self.parent.zoom.GetValue().split('x')[0])
        pub.sendMessage("UpdateBitmap")




