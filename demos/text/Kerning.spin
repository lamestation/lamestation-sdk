{{
My Yearning For Kerning
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd     :               "LameLCD"
        gfx     :               "LameGFX"
        font    :               "gfx_font4x6"
        
PUB Kerning

    lcd.Start(gfx.Start)

    gfx.ClearScreen(0)

    ' 0,0 loads default kerning, so normal letter spacing
    gfx.LoadFont(font.Addr, " ", 0, 0)
    gfx.TextBox(@strang,0,0,128,30)


    ' kerning can also be specified, giving rise to completely
    ' right or completely wrong sizes...
    gfx.LoadFont(font.Addr, " ", 6, 8)
    gfx.TextBox(@strang,0,16,128,30)

    gfx.LoadFont(font.Addr, " ", 10, 10)
    gfx.TextBox(@strang,0,32,128,30)

    gfx.LoadFont(font.Addr, " ", 3, 3)
    gfx.TextBox(@strang,0,52,128,30)

    lcd.DrawScreen

    repeat


DAT

strang  byte    "This is cool",10,"You think so?",0
