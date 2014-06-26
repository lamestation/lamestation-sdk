
import wx
from wx.lib.pubsub import Publisher as pub

import Bitmap, Dialog

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



