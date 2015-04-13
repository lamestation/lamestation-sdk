' 02_graphics/Blit.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd     :               "LameLCD" 
    gfx     :               "LameGFX"

    img     :               "gfx_dagron"


PUB Blit

    lcd.Start(gfx.Start)
    gfx.Blit(img.Addr)
    lcd.DrawScreen

