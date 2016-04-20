OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.Sprite(@data, 15, 20, 0)
    gfx.Sprite(@data, 35, 20, 0)
    gfx.Sprite(@data, 20, 30, 0)
    gfx.Sprite(@data, 30, 30, 0)
    gfx.Sprite(@data, 45, 10, 0)

    lcd.Draw

DAT

data
word    0
word    1, 1
word    1