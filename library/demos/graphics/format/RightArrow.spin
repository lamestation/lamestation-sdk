OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)

    gfx.Sprite(@data, 0, 0, 0)
    lcd.DrawScreen

DAT

data
word    0
word    8, 8
word    %%11
word    %%1111
word    %%111111
word    %%11111111
word    %%11111111
word    %%111111
word    %%1111
word    %%11
