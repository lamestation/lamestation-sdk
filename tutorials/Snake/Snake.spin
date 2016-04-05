CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

    UP    = 0
    RIGHT = 1
    DOWN  = 2
    LEFT  = 3
    
    MAX_LENGTH = 256
    
    SPEED = 2

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
VAR
    byte    snakex[MAX_LENGTH]
    byte    snakey[MAX_LENGTH]

    byte    snakedir
    byte    snakecount
    
    byte    foodx
    byte    foody

    byte    random
    byte    i

PUB Main
    lcd.Start(gfx.Start)
    lcd.SetFrameLimit (lcd#HALFSPEED)
    ctrl.Start

    random := cnt
    
    snakex[0] := 32
    snakey[0] := 32
    snakedir := 1
    snakecount := 1

    foodx := ||random? // 64 * 2
    foody := ||random? // 32 * 2
    
    repeat
        gfx.Clear
        ctrl.Update

        if foodx == snakex[0] and foody == snakey[0]
            if snakecount < constant(MAX_LENGTH-1)
                snakecount++

            foodx := ||random? // 64 * 2
            foody := ||random? // 32 * 2
        
        gfx.Sprite(@food_gfx, foodx, foody, 0)

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
            snakex[0] -= SPEED
        if snakedir == RIGHT and snakex[0] < constant(128-2)
            snakex[0] += SPEED
        if snakedir == UP and snakey[0] > 0
            snakey[0] -= SPEED
        if snakedir == DOWN and snakey[0] < constant(64-2)
            snakey[0] += SPEED
            
        gfx.Sprite(@dot_gfx, snakex[0], snakey[0], 0)        

        repeat i from snakecount to 1
            if snakex[i] == snakex[0] and snakey[i] == snakey[0]
                snakecount := 1
                snakex[0] := 64
                snakey[0] := 32
                snakedir := 1

            snakex[i] := snakex[i-1]
            snakey[i] := snakey[i-1]
            gfx.Sprite(@dot_gfx, snakex[i], snakey[i], 0)
            
        lcd.DrawScreen
    
DAT
    dot_gfx
    word    0
    word    2, 2
    word    %%22222211
    word    %%22222211
    
    food_gfx
    word    0
    word    2, 2
    word    %%22222233
    word    %%22222233