' 02_graphics/clearscreen/02_Colors.spin
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
    fn      :               "LameFunctions"

PUB Blit

    lcd.Start(gfx.Start)
    gfx.ClearScreen(gfx#WHITE)
    lcd.DrawScreen

    fn.Sleep(1000)
        
    gfx.ClearScreen(gfx#BLACK)
    lcd.DrawScreen

    fn.Sleep(1000)

    gfx.ClearScreen(gfx#GRAY)
    lcd.DrawScreen

