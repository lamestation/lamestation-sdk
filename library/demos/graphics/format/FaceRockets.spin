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
    
    repeat 140
        gfx.Sprite(sprite.Gfx, x, 24, 0)
        lcd.Draw
        x++
        
    x := 0
        
    repeat 140
        gfx.Sprite(sprite.Gfx, x, 4, 0)
        lcd.Draw
        x++

    x := 0
        
    repeat
        gfx.Sprite(sprite.Gfx, x, 44, 0)
        lcd.Draw
        x++                
