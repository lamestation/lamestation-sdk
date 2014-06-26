
import wx
import Color

def Copy(bitmap):
    return  wx.ImageFromBitmap(bitmap).Copy().ConvertToBitmap()

def Scale(bitmap, width, height):
    image = wx.ImageFromBitmap(bitmap)
    image = image.Scale(width, height, wx.IMAGE_QUALITY_NORMAL)
    result = wx.BitmapFromImage(image)
    return result

def New(w, h):
        bmp = wx.EmptyBitmap(w,h) 
        dc = wx.MemoryDC()
        dc.SelectObject(bmp)
        dc.Clear()
        dc.SetBrush(wx.Brush(Color.color['plain'][Color.lookup['none']]))
        dc.FloodFill(0, 0, wx.Colour(255,255,255))
        dc.SelectObject(wx.NullBitmap)

        return bmp
    


