CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
VAR
    byte    snakex
    byte    snakey

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    snakex := 32
    snakey := 32
    
    repeat
        gfx.Clear
        ctrl.Update
        
        if ctrl.Left and snakex > 0
            snakex--
        if ctrl.Right and snakex < constant(128-2)
            snakex++
        if ctrl.Up and snakey > 0
            snakey--
        if ctrl.Down and snakey < constant(64-2)
            snakey++
            
        gfx.Sprite(@dot_gfx, snakex, snakey, 0)
        lcd.DrawScreen
    
DAT
    dot_gfx
    word    0
    word    2, 2
    word    %%22222211
    word    %%22222211