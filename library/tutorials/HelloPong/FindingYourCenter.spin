CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
VAR
    byte    i

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start

    repeat i from 0 to 7
        gfx.Sprite (@centerline_gfx, 64 - gfx.Width (@centerline_gfx) / 2, i*8, 0)
    
    gfx.Sprite (@ball_gfx, 64 - gfx.Width (@ball_gfx) / 2, 32 - gfx.Height (@ball_gfx) / 2, 0)
    gfx.Sprite (@paddle_gfx, 4, 32 - gfx.Height (@paddle_gfx) / 2, 0)
    gfx.Sprite (@paddle_gfx, 124 - gfx.Width (@paddle_gfx), 32 - gfx.Height (@paddle_gfx) / 2, 0)
    
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