' 02_graphics/clearscreen/04_EndlessRamp.spin
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
    
PUB Blit | val
    lcd.Start(gfx.Start)
    
    val := %%1000_0000_1000_0000
    repeat
        gfx.ClearScreen(val)
        lcd.DrawScreen
        val ->= 2

