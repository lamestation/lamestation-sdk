
import wx
import Color

def Copy(bitmap):
    return  wx.ImageFromBitmap(bitmap).Copy().ConvertToBitmap()

def Scale(bitmap, scale):
    image = wx.ImageFromBitmap(bitmap)
    image = image.Scale(bitmap.GetWidth()*scale,
                        bitmap.GetHeight()*scale,
                        wx.IMAGE_QUALITY_NORMAL)
    result = wx.BitmapFromImage(image)
    return result

def New(w, h):
        bmp = wx.EmptyBitmap(w,h) 
        dc = wx.MemoryDC()
        dc.SelectObject(bmp)
        dc.Clear()
        dc.SetBrush(wx.Brush( Color.Name('transparent') ))
        dc.FloodFill(0, 0, wx.Colour(255,255,255))
        dc.SelectObject(wx.NullBitmap)

        return bmp
    
def Recolor(bitmap, newstyle):
    if not Color.STYLE == newstyle:
        dc = wx.MemoryDC()
        dc.SelectObject(bitmap)
        Color.GetStyles()
        for y in range(0,bitmap.GetHeight()):
            for x in range(0,bitmap.GetWidth()):
                
                pixel = dc.GetPixel(x,y).GetAsString(flags=wx.C2S_HTML_SYNTAX)
                dc.SetBrush(wx.Brush( Color.Convert(pixel,newstyle) ))
                dc.SetPen(wx.Pen( Color.Convert(pixel,newstyle) ))
                dc.DrawPoint(x, y)

        dc.SelectObject(wx.NullBitmap)
        Color.ChangeStyle(newstyle)
