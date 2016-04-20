CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     : "LameLCD"
    gfx     : "LameGFX"
    ctrl    : "LameControl"
    sprite  : "HappyFaceGFX"
    
VAR
    long    x
    long    y

PUB Main
    lcd.Start(gfx.Start)
    
    repeat
        ctrl.Update
        
        if ctrl.Left
            x--
        if ctrl.Right
            x++
        if ctrl.Up
            y--
        if ctrl.Down
            y++
        
        gfx.Sprite(sprite.Gfx, x, y, 0)
        lcd.Draw
