CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    PADDLE_SPEED = 1

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    txt  : "LameText"
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
    txt.Load (@numbers_gfx, "0", 8, 8)
    
    ResetGame
    
    repeat
        GameLoop

PUB ResetRound

    playerx := 0
    playery := 32 - gfx.Height (@paddle_gfx) / 2  
    playerspeedy := 0  

    opponentx := 128 - gfx.Width (@paddle_gfx)
    opponenty := 32 - gfx.Height (@paddle_gfx) / 2
    opponentspeedy := 0

    ballx := 64-gfx.Width(@ball_gfx)/2
    bally := 32-gfx.Height(@ball_gfx)/2
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

    DrawGraphics
    
    lcd.Draw
    
PUB ControlBall | ballcenter, paddlecenter

    if bally < 0 or bally > gfx#res_y - 8
        ballspeedy := -ballspeedy

    bally += ballspeedy

    if ballx < -gfx.Width(@ball_gfx)
        opponentscore++
        ResetRound
        if opponentscore > 9
            ResetGame
            
    if ballx > gfx#res_x
        playerscore++
        ResetRound
        if playerscore > 9
            ResetGame
            
    ballx += ballspeedx
    ballcenter := bally + gfx.Height(@ball_gfx)/2
    
    if fn.TestBoxCollision (ballx, bally, gfx.Width(@ball_gfx), gfx.Height(@ball_gfx), playerx, playery, gfx.Width(@paddle_gfx), gfx.Height(@paddle_gfx))
        ballspeedx := -ballspeedx
        paddlecenter := playery + gfx.Height(@paddle_gfx)/2
        ballspeedy := (ballcenter - paddlecenter + playerspeedy * 2) / 4
        
    if fn.TestBoxCollision (ballx, bally, gfx.Width(@ball_gfx), gfx.Height(@ball_gfx), opponentx, opponenty, gfx.Width(@paddle_gfx), gfx.Height(@paddle_gfx))
        ballspeedx := -ballspeedx
        paddlecenter := opponenty + gfx.Height(@paddle_gfx)/2        
        ballspeedy := (ballcenter - paddlecenter + opponentspeedy * 2) / 4


PUB ControlPlayer

    playerspeedy := 0

    if ctrl.Up and playery > 0
           playerspeedy := -PADDLE_SPEED
    if ctrl.Down and playery < 64 - gfx.Height(@paddle_gfx)
           playerspeedy := PADDLE_SPEED
           
    playery += playerspeedy

PUB ControlOpponent | ballcenter, paddlecenter

    opponentspeedy := 0

    ballcenter := bally + gfx.Height(@ball_gfx)/2
    paddlecenter := opponenty + gfx.Height(@paddle_gfx)/2

    if paddlecenter > ballcenter and opponenty > 0
        opponentspeedy := -PADDLE_SPEED
    if paddlecenter < ballcenter and opponenty < 64 - gfx.Height (@paddle_gfx)
        opponentspeedy := PADDLE_SPEED

    opponenty += opponentspeedy

PUB DrawGraphics

    repeat i from 0 to 7
        gfx.Sprite (@centerline_gfx, 63, i*8, 0)
        
    txt.Char ("0" + 0, 56 - gfx.Width (@numbers_gfx), 4)
    txt.Char ("0" + 0, 72, 4)
    
    gfx.Sprite (@ball_gfx, ballx, bally, 0)
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
