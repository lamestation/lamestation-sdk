' 02_graphics/format/01_Pixel.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB SinglePixel
    lcd.Start(gfx.Start)
    gfx.Sprite(@data, 0,0, 0)
    lcd.DrawScreen
    
DAT

data
word    0
word    1, 1
word    1


