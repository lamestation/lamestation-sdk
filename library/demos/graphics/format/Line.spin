OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.Sprite(@data, 0,0, 0)
    lcd.Draw

DAT

data
word    0
word    8, 1
word    %%11111111
