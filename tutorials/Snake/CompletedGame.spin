CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
    
    MAX_SNAKE = 256
    SNAKE_SPEED = 2

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
VAR    
    byte    snakedir    
    byte    snakex[MAX_SNAKE]
    byte    snakey[MAX_SNAKE]
    byte    snakecount
    
    byte    foodx
    byte    foody
    
    byte    i
    byte    random
    
PUB Main
    lcd.Start(gfx.Start)
    lcd.SetFrameLimit (lcd#HALFSPEED)
    
    random := cnt
    
    foodx := ||random? // 64 * 2
    foody := ||random? // 32 * 2

    snakex[0] := 64
    snakey[0] := 32
    snakedir := 1
    snakecount := 1

    repeat        
        gfx.Clear
        ctrl.Update
        
        if snakedir == 0 or snakedir == 2
            if ctrl.Left
                snakedir := 3
            elseif ctrl.Right
                snakedir := 1

        elseif snakedir == 1 or snakedir == 3
            if ctrl.Up
                snakedir := 0
            elseif ctrl.Down
                snakedir := 2


        if snakedir == 3
            if snakex[0] > 0
                snakex[0] -= SNAKE_SPEED
                
        if snakedir == 1
            if snakex[0] < constant(128-2)
                snakex[0] += SNAKE_SPEED

        if snakedir == 0
            if snakey[0] > 0
                snakey[0] -= SNAKE_SPEED
                
        if snakedir == 2
            if snakey[0] < constant(64-2)
                snakey[0] += SNAKE_SPEED

        
        if foodx == snakex[0] and foody == snakey[0]
            foodx := ||random? // 64 * 2
            foody := ||random? // 32 * 2

            if snakecount < constant(MAX_SNAKE-1)
                snakecount++

        gfx.Sprite(@food_gfx, foodx, foody, 0) 

    
        repeat i from snakecount to 1
            if snakex[i] == snakex[0] and snakey[i] == snakey[0]
                snakecount := 1
                snakex[0] := 64
                snakey[0] := 32
                snakedir := 1

            snakex[i] := snakex[i-1]
            snakey[i] := snakey[i-1]
            gfx.Sprite(@dot_gfx, snakex[i], snakey[i], 0)
            
        gfx.Sprite(@dot_gfx, snakex[0], snakey[0], 0) 
        
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