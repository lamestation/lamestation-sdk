CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)

    gfx.Sprite(@black, 0, 0, 0)
    gfx.Sprite(@gray, 8, 0, 0)
    gfx.Sprite(@white, 16, 0, 0)
    lcd.Draw

DAT

black
word    0
word    8, 8
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000

white
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

gray
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
