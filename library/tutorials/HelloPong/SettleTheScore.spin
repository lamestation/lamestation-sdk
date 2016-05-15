CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    PADDLE_SPEED = 1

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    fn   : "LameFunctions"
    
VAR

    long    playerx
    long    playery
    long    playerspeedy
    byte    playerscore
    
    long    opponentx
    long    opponenty
    long    opponentspeedy
    byte    opponentscore
    
    long    ballx
    long    bally
    long    ballspeedx
    long    ballspeedy

    byte    i

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    ResetGame
    
    repeat
        GameLoop

PUB ResetRound

    playerx := 4
    playery := 32 - gfx.Height (@paddle_gfx) / 2  
    playerspeedy := 0  

    opponentx := 124 - gfx.Width (@paddle_gfx)
    opponenty := 32 - gfx.Height (@paddle_gfx) / 2
    opponentspeedy := 0

    ballx := 64-gfx.Width(@ball_gfx)/2
    bally := (32-gfx.Height(@ball_gfx)/2) * 8
    ballspeedx := 1
    ballspeedy := 1

PUB ResetGame

    ResetRound

    playerscore := 0
    opponentscore := 0
    
PUB GameLoop

    gfx.Clear
    ctrl.Update

    ControlPlayer
    ControlOpponent
    ControlBall

    ifnot KeepScore
        DrawGraphics
        lcd.Draw
    
PUB ControlBall | ballcenter, paddlecenter, oldx, oldy

    oldx := ballx
    oldy := bally / 8

    if bally / 8 < 0 or bally / 8 > gfx#res_y - 8
        ballspeedy := -ballspeedy

    bally += ballspeedy
            
    ballx += ballspeedx
    ballcenter := bally / 8 + gfx.Height(@ball_gfx)/2
    
    if fn.TestBoxCollision (ballx, bally / 8, gfx.Width(@ball_gfx), gfx.Height(@ball_gfx), playerx, playery, gfx.Width(@paddle_gfx), gfx.Height(@paddle_gfx))
        if oldx => playerx + gfx.Width (@paddle_gfx) - 1
            ballspeedx := -ballspeedx
            paddlecenter := playery + gfx.Height(@paddle_gfx)/2
            ballspeedy := ballcenter - paddlecenter + playerspeedy * 2
        else
            if oldy < playery or oldy > playery + gfx.Height (@paddle_gfx)
                ballspeedy := -ballspeedy
        
    if fn.TestBoxCollision (ballx, bally / 8, gfx.Width(@ball_gfx), gfx.Height(@ball_gfx), opponentx, opponenty, gfx.Width(@paddle_gfx), gfx.Height(@paddle_gfx))
        if oldx + gfx.Width (@ball_gfx) =< opponentx
            ballspeedx := -ballspeedx
            paddlecenter := opponenty + gfx.Height(@paddle_gfx)/2        
            ballspeedy := ballcenter - paddlecenter + opponentspeedy * 2
        else
            if oldy < opponenty or oldy > opponenty + gfx.Height (@paddle_gfx)
                ballspeedy := -ballspeedy
                
PUB ControlPlayer

    playerspeedy := 0

    if ctrl.Up and playery > 0
           playerspeedy := -PADDLE_SPEED
    if ctrl.Down and playery < 64 - gfx.Height(@paddle_gfx)
           playerspeedy := PADDLE_SPEED
           
    playery += playerspeedy

PUB ControlOpponent | ballcenter, paddlecenter

    opponentspeedy := 0

    ballcenter := bally / 8 + gfx.Height(@ball_gfx)/2
    paddlecenter := opponenty + gfx.Height(@paddle_gfx)/2

    if paddlecenter > ballcenter and opponenty > 0
        opponentspeedy := -PADDLE_SPEED
    if paddlecenter < ballcenter and opponenty < 64 - gfx.Height (@paddle_gfx)
        opponentspeedy := PADDLE_SPEED

    opponenty += opponentspeedy
    
PUB KeepScore

    if ballx < -gfx.Width(@ball_gfx)
        opponentscore++
        if opponentscore > 8
            OpponentWin
            ResetGame
            return 1
        else
            ResetRound
            
    if ballx > gfx#res_x
        playerscore++
        if playerscore > 8
            PlayerWin
            ResetGame
            return 1
        else
            ResetRound

PUB PlayerWin

    gfx.Sprite (@win_gfx, 4, 4, 0)
    gfx.Sprite (@lose_gfx, 92, 4, 0)
    DrawGraphics
    lcd.Draw
    fn.Sleep (4000)
    
PUB OpponentWin

    gfx.Sprite (@lose_gfx, 4, 4, 0)
    gfx.Sprite (@win_gfx, 100, 4, 0)
    DrawGraphics
    lcd.Draw
    fn.Sleep (4000)

PUB DrawGraphics

    repeat i from 0 to 7
        gfx.Sprite (@centerline_gfx, 63, i*8, 0)
        
    gfx.Sprite(@numbers_gfx, 56 - gfx.Width (@numbers_gfx), 4, playerscore)
    gfx.Sprite(@numbers_gfx, 72, 4, opponentscore)
    
    gfx.Sprite (@ball_gfx, ballx, bally / 8, 0)
    gfx.Sprite (@paddle_gfx, playerx, playery, 0)
    gfx.Sprite (@paddle_gfx, opponentx, opponenty, 0)

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

centerline_gfx
word    0
word    2, 4

word    %%33
word    %%33
word    %%33
word    %%33



numbers_gfx
word    16
word    6, 8

word    %%333333
word    %%333333
word    %%330033
word    %%330033
word    %%330033
word    %%330033
word    %%333333
word    %%333333

word    %%330000
word    %%330000
word    %%330000
word    %%330000
word    %%330000
word    %%330000
word    %%330000
word    %%330000

word    %%333333
word    %%333333
word    %%330000
word    %%333333
word    %%333333
word    %%000033
word    %%333333
word    %%333333

word    %%333333
word    %%333333
word    %%330000
word    %%333300
word    %%333300
word    %%330000
word    %%333333
word    %%333333

word    %%330033
word    %%330033
word    %%330033
word    %%333333
word    %%333333
word    %%330000
word    %%330000
word    %%330000

word    %%333333
word    %%333333
word    %%000033
word    %%333333
word    %%333333
word    %%330000
word    %%333333
word    %%333333

word    %%000033
word    %%000033
word    %%000033
word    %%333333
word    %%333333
word    %%330033
word    %%333333
word    %%333333

word    %%333333
word    %%333333
word    %%330000
word    %%330000
word    %%330000
word    %%330000
word    %%330000
word    %%330000

word    %%333333
word    %%333333
word    %%330033
word    %%333333
word    %%333333
word    %%330033
word    %%333333
word    %%333333

word    %%333333
word    %%333333
word    %%330033
word    %%333333
word    %%333333
word    %%330000
word    %%330000
word    %%330000

lose_gfx
word    0
word    32, 8

word    %%00000033,%%03333333,%%03333333,%%03333333
word    %%00000033,%%03333333,%%03333333,%%03333333
word    %%00000033,%%03300033,%%00000033,%%00000033
word    %%00000033,%%03300033,%%03333333,%%00333333
word    %%00000033,%%03300033,%%03333333,%%00333333
word    %%00000033,%%03300033,%%03300000,%%00000033
word    %%03333333,%%03333333,%%03333333,%%03333333
word    %%03333333,%%03333333,%%03333333,%%03333333

win_gfx
word    0
word    24, 8

word    %%33000033,%%03333330,%%03300033
word    %%33033033,%%03333330,%%03300333
word    %%33033033,%%00033000,%%03303333
word    %%33033033,%%00033000,%%03333333
word    %%33033033,%%00033000,%%03333333
word    %%33033033,%%00033000,%%03333033
word    %%33333333,%%03333330,%%03330033
word    %%33333333,%%03333330,%%03300033
