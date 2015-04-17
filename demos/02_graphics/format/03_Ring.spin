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
word    %%00011000
word    %%01111110
word    %%01100110
word    %%11000011
word    %%11000011
word    %%01100110
word    %%01111110
word    %%00011000

