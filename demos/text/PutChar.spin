{{
Put Characters Everywhere
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
        font_8x8    :           "gfx_font8x8"
        
PUB PutChar | x, ran, y, count, char

    lcd.Start(gfx.Start)
    gfx.LoadFont(font_8x8.Addr, " ", 0, 0)

    repeat
        gfx.ClearScreen(0)
        repeat count from 1 to 1000
            ran := cnt
            x := ran? & $7F
            y := ran? & $3F
            char := ran? & %11111
            gfx.PutChar("A" + char, x-8, y-8)
            lcd.DrawScreen
