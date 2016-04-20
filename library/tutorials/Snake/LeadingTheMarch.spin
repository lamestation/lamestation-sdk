CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

    UP    = 0
    RIGHT = 1
    DOWN  = 2
    LEFT  = 3
    
    MAX_LENGTH = 256

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
VAR
    byte    snakex[MAX_LENGTH]
    byte    snakey[MAX_LENGTH]

    byte    snakedir
    byte    snakecount

    byte    i

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    snakex[0] := 32
    snakey[0] := 32
    snakedir := 1
    snakecount := 1
    
    repeat
        gfx.Clear
        ctrl.Update

        if ctrl.A
            if snakecount < constant(MAX_LENGTH-1)
                snakecount++

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
        
        if snakedir == LEFT and snakex[0] > 0
            snakex[0]--
        if snakedir == RIGHT and snakex[0] < constant(128-2)
            snakex[0]++
        if snakedir == UP and snakey[0] > 0
            snakey[0]--
        if snakedir == DOWN and snakey[0] < constant(64-2)
            snakey[0]++
            
        gfx.Sprite(@dot_gfx, snakex[0], snakey[0], 0)        

        repeat i from snakecount to 1
            snakex[i] := snakex[i-1]
            snakey[i] := snakey[i-1]
            gfx.Sprite(@dot_gfx, snakex[i], snakey[i], 0) 
            
        lcd.Draw
    
DAT
    dot_gfx
    word    0
    word    2, 2
    word    %%22222211
    word    %%22222211