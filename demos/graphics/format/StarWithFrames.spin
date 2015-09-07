OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main | x 
    lcd.Start(gfx.Start)
    
    repeat
        repeat x from 0 to 5
            gfx.Sprite(@data, 0,0, x)
            lcd.DrawScreen
        
            repeat 1000
    
DAT

data
word    16
word    8, 8
word    %%00000000
word    %%00000000
word    %%00011000
word    %%00111100
word    %%00111100
word    %%00011000
word    %%00000000
word    %%00000000

word    %%00000000
word    %%00011000
word    %%00111100
word    %%01100110
word    %%01100110
word    %%00111100
word    %%00011000
word    %%00000000

word    %%00011000
word    %%01111110
word    %%01100110
word    %%11000011
word    %%11000011
word    %%01100110
word    %%01111110
word    %%00011000

word    %%00011000
word    %%01100110
word    %%01000010
word    %%10000001
word    %%10000001
word    %%01000010
word    %%01100110
word    %%00011000

word    %%01100110
word    %%10000001
word    %%10000001
word    %%00000000
word    %%00000000
word    %%10000001
word    %%10000001
word    %%01100110

word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
word    %%00000000
