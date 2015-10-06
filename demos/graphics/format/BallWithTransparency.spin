CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"
    
PUB Main
    lcd.Start(gfx.Start)
    gfx.Sprite(@box, 40, 20, 0)
    gfx.Sprite(@ball, 42, 22, 0)
    lcd.DrawScreen

DAT

box
word    0
word    8, 8
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333
word    %%33333333

ball
word    0
word    8, 8
word    %%22222222
word    %%22211222
word    %%22111122
word    %%21111112
word    %%21111112
word    %%22111122
word    %%22211222
word    %%22222222
