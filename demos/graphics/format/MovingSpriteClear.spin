CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     : "LameLCD"
    gfx     : "LameGFX"

    sprite  : "HappyFaceGFX"
    
VAR
    long    x

PUB Main
    lcd.Start(gfx.Start)
    
    repeat
        gfx.ClearScreen (0)
        gfx.Sprite(sprite.Gfx, x, 24, 0)
        lcd.DrawScreen
        x++      
