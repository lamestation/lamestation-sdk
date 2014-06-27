
import wx, os
from wx.lib.pubsub import setuparg1 
from wx.lib.pubsub import pub

import Bitmap, Dialog
from FileManager import FileManager

stockUndo = []
stockRedo = []

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


    def OnSave(self, event):
        fm = FileManager()
        fm.Save()

    def OnSaveAs(self, event):
        fm = FileManager()
        fm.SaveAs(self.filename)


    def OnLoad(self, event):
        wildcard = "All files (*)|*|PNG files (*.png)|*.png|GIF files (*.gif)|*.gif|Bitmap files (*.bmp)|*.bmp|GIF files (*.gif)|*.gif|JPEG files (*.jpg)|*.jpg"
        dialog = wx.FileDialog(None, "Choose a file",
                wildcard=wildcard,
                style=wx.FD_OPEN|wx.FD_CHANGE_DIR|wx.FD_PREVIEW)
        if dialog.ShowModal() == wx.ID_OK:
            self.filename = dialog.GetPath()
            self.parent.statusbar.SetStatusText(self.filename)
        dialog.Destroy()

        fm = FileManager()
        fm.Load('image',self.filename)

    def OnClose(self, event):
        fm = FileManager()
        fm.Close()
        self.parent.statusbar.SetStatusText("CLOSED")

    def OnQuit(self, event):
        self.parent.Destroy()


    def OnDraw(self, message):
        self.parent.toolbar.EnableTool(wx.ID_UNDO, True )
        self.parent.toolbar.EnableTool(wx.ID_SAVE, True )
        self.parent.menu.Enable( wx.ID_UNDO, True )
        self.parent.menu.Enable( wx.ID_SAVE, True )
        pub.sendMessage("UpdateBitmap",message.data[1])

        undo = UndoDraw(message.data[0],message.data[1])
        stockUndo.append( undo )
        if stockRedo:
            del stockRedo[:]
            self.parent.toolbar.EnableTool( wx.ID_REDO, False )



    def OnUndo( self, event ):
        if len( stockUndo ) == 0:
            self.parent.toolbar.EnableTool(wx.ID_UNDO, False )
            self.parent.toolbar.EnableTool(wx.ID_SAVE, False )
            self.parent.menu.Enable( wx.ID_UNDO, False )
            self.parent.menu.Enable( wx.ID_SAVE, False )
            return

        a = stockUndo.pop()
        if len( stockUndo ) == 0:
            self.parent.toolbar.EnableTool( wx.ID_UNDO, False )
            self.parent.toolbar.EnableTool( wx.ID_SAVE, False )
            self.parent.menu.Enable( wx.ID_UNDO, False )
            self.parent.menu.Enable( wx.ID_SAVE, False )

        pub.sendMessage("UpdateBitmap",a.undo())

        stockRedo.append( a )
        self.parent.toolbar.EnableTool( wx.ID_REDO, True )



    def OnRedo( self, event ):
        if len( stockRedo ) == 0:
            self.parent.toolbar.EnableTool( wx.ID_REDO, False )
            return

        a = stockRedo.pop()
        if len( stockRedo ) == 0:
            self.parent.toolbar.EnableTool( wx.ID_REDO, False )

        pub.sendMessage("UpdateBitmap",a.redo())

        stockUndo.append( a )
        self.parent.toolbar.EnableTool( wx.ID_UNDO, True )
        self.parent.toolbar.EnableTool( wx.ID_SAVE, True )
        self.parent.menu.Enable( wx.ID_UNDO, True )
        self.parent.menu.Enable( wx.ID_SAVE, True )



