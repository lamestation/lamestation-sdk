CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
VAR
    byte    ballx
    byte    bally
    
    byte    playerx
    byte    playery
    
    byte    opponentx
    byte    opponenty

    byte    i

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start

    ballx := 64 - gfx.Width(@ball_gfx)/2
    bally := 32 - gfx.Height(@ball_gfx)/2
    
    playerx := 4
    playery := 32 - gfx.Height (@paddle_gfx) / 2

    opponentx := 124 - gfx.Width (@paddle_gfx)
    opponenty := 32 - gfx.Height (@paddle_gfx) / 2

    repeat i from 0 to 7
        gfx.Sprite (@centerline_gfx, 63, i*8, 0)
    
    gfx.Sprite (@ball_gfx, ballx, bally, 0)
    gfx.Sprite (@paddle_gfx, playerx, playery, 0)
    gfx.Sprite (@paddle_gfx, opponentx, opponenty, 0)
    
    lcd.Draw

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