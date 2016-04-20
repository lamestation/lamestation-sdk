OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)
    
    repeat
        gfx.Sprite(@data1, 0, 0, 0)
        lcd.Draw
        
        repeat 10000
        
        gfx.Sprite(@data2, 0, 0, 0)
        lcd.Draw
        
        repeat 10000

DAT

data1
word    0
word    8, 8
word    %%00011000
word    %%00111100
word    %%01111110
word    %%11111111
word    %%11111111
word    %%01111110
word    %%00111100
word    %%00011000

data2
word    0
word    8, 8
word    %%00000000
word    %%00011000
word    %%00011000
word    %%01111110
word    %%01111110
word    %%00011000
word    %%00011000
word    %%00000000