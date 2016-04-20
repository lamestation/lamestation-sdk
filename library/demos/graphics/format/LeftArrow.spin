OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)

    gfx.Sprite(@data, 0, 0, 0)
    lcd.Draw

DAT

data
word    0
word    8, 8
word    %%11000000
word    %%11110000
word    %%11111100
word    %%11111111
word    %%11111111
word    %%11111100
word    %%11110000
word    %%11000000
