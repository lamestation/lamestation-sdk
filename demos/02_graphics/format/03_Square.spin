OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB SinglePixel
    lcd.Start(gfx.Start)
    gfx.Sprite(@data, 0,0, 0)
    lcd.DrawScreen

DAT

data
word    0
word    8, 8
word    %%11111111
word    %%11111111
word    %%11000011
word    %%11000011
word    %%11000011
word    %%11000011
word    %%11111111
word    %%11111111
