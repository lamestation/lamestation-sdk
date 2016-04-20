OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.Sprite(@line1, 32, 24, 0)
    gfx.Sprite(@line2, 90, 24, 0)
        
    lcd.Draw

DAT

line1
word    0
word    24, 2
word    %%11111111, %%11111111, %%11111111
word    %%11111111, %%11111111, %%11111111

line2
word    0
word    2, 16
word    %%11
word    %%11
word    %%11
word    %%11
word    %%11
word    %%11
word    %%11
word    %%11

word    %%11
word    %%11
word    %%11
word    %%11
word    %%11
word    %%11
word    %%11
word    %%11