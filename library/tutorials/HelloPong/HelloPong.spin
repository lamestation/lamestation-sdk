CON

    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    
    BALLSPEED = 2
    HIGHSCORE = 9

OBJ

    lcd     : "LameLCD" 
    gfx     : "LameGFX"
    ctrl    : "LameControl"
    fn      : "LameFunctions"

VAR

    long    ballx
    long    bally
    long    ballspeedx
    long    ballspeedy

    long    paddle1_y
    long    paddle1_x
    long    paddle1_speedy
    
    long    paddle2_x
    long    paddle2_y
    long    paddle2_speedy
    
    long    score1
    long    score2
    long    timeout

PUB Main

    lcd.Start(gfx.Start)
'    lcd.SetFrameLimit (lcd#HALFSPEED)
    ctrl.Start

    InitGame
    
    repeat
        GameLoop
        
PUB InitGame
    
    ballx := (128 / 2) - gfx.Width (@ball_gfx)
    bally := (64 / 2) - gfx.Height (@ball_gfx)

    ballspeedx := BALLSPEED
    ballspeedy := 2

    paddle1_x := 4
    paddle2_x := 116

PUB ResetGame

    score1 := 0
    score2 := 0
    
PUB GameLoop
    
    ctrl.Update
    gfx.Clear

    if ballx => paddle1_x+8 and ballx =< paddle2_x
        ControlPlayer
        ControlOpponent
    
    ControlBall
     
    gfx.Sprite(@paddle_gfx, paddle1_x, paddle1_y, 0)
    gfx.Sprite(@paddle_gfx, paddle2_x, paddle2_y, 0)
            
    gfx.Sprite(@ball_gfx, ballx, bally >> 3, 0)
    
    lcd.Draw

PUB ControlPlayer

    paddle1_speedy := 0

    if ctrl.Up and paddle1_y > 0
           paddle1_speedy := -1
    if ctrl.Down and paddle1_y < gfx#res_y - 16
           paddle1_speedy := 1
           
    paddle1_y += paddle1_speedy

PUB ControlOpponent | ballcenter, paddlecenter

    paddle2_speedy := 0

    ballcenter := bally >> 3 + gfx.Height(@ball_gfx)/2
    paddlecenter := paddle2_y + gfx.Height(@paddle_gfx)/2

    if paddlecenter > ballcenter and paddle2_y > 0
        paddle2_speedy := -1
    if paddlecenter < ballcenter and paddle2_y < gfx#res_y - 16
        paddle2_speedy := 1
        
    paddle2_y += paddle2_speedy

PUB ControlBall | ballcenter, paddlecenter

    if bally >> 3 < 0 or bally >> 3 > gfx#res_y - 8
        ballspeedy := -ballspeedy

    bally += ballspeedy

    if ballx < -8
        score2++
        InitGame
        if score2 > 9
            ResetGame
    if ballx > gfx#res_x
        score1++
        InitGame
        if score1 > 9
            ResetGame
            
    ballx += ballspeedx
    ballcenter := bally >> 3 + gfx.Height(@ball_gfx)/2
    
    if fn.TestBoxCollision (ballx, bally >> 3, gfx.Width(@ball_gfx), gfx.Height(@ball_gfx), paddle1_x, paddle1_y, gfx.Width(@paddle_gfx), gfx.Height(@paddle_gfx))
        ballspeedx := BALLSPEED
        paddlecenter := paddle1_y + gfx.Height(@paddle_gfx)/2
        ballspeedy := ballcenter - paddlecenter + paddle1_speedy * 2
        
    if fn.TestBoxCollision (ballx, bally >> 3, gfx.Width(@ball_gfx), gfx.Height(@ball_gfx), paddle2_x, paddle2_y, gfx.Width(@paddle_gfx), gfx.Height(@paddle_gfx))
        ballspeedx := -BALLSPEED

        paddlecenter := paddle2_y + gfx.Height(@paddle_gfx)/2        
        ballspeedy := ballcenter - paddlecenter + paddle2_speedy * 2
 

DAT

ball_gfx
word    0
word    8, 8
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111


paddle_gfx
word    0
word    8, 16

word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111
word    %%11111111