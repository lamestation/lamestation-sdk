' 02_graphics/sprite/01_Sprite.spin
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

    sprite  :               "gfx_supertank"


PUB Main

    lcd.Start(gfx.Start)
    gfx.Sprite(sprite.Addr, 56, 24, 0)
    lcd.DrawScreen

