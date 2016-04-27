CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

    UP    = 0
    RIGHT = 1
    DOWN  = 2
    LEFT  = 3

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
VAR
    byte    snakex
    byte    snakey

    byte    snakedir

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    snakex := 32
    snakey := 32
    
    snakedir := 1
    
    repeat
        gfx.Clear
        ctrl.Update

        if snakedir == LEFT or snakedir == RIGHT
            if ctrl.Up
                snakedir := UP
            if ctrl.Down
                snakedir := DOWN
                
        elseif snakedir == DOWN or snakedir == UP
            if ctrl.Left
                snakedir := LEFT
            if ctrl.Right
                snakedir := RIGHT
        
        if snakedir == LEFT and snakex > 0
            snakex--
        if snakedir == RIGHT and snakex < constant(128-2)
            snakex++
        if snakedir == UP and snakey > 0
            snakey--
        if snakedir == DOWN and snakey < constant(64-2)
            snakey++
            
        gfx.Sprite(@dot_gfx, snakex, snakey, 0)
        lcd.Draw
    
DAT
    dot_gfx
    word    0
    word    2, 2
    word    %%22222211
    word    %%22222211