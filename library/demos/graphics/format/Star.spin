OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)
    
    repeat
        gfx.Sprite(@data1, 0,0, 0)
        lcd.Draw
        
        repeat 1000
        
        gfx.Sprite(@data2, 0,0, 0)
        lcd.Draw
        
        repeat 1000
        
        gfx.Sprite(@data3, 0,0, 0)
        lcd.Draw
    
        repeat 1000
        
        gfx.Sprite(@data4, 0,0, 0)
        lcd.Draw
        
        repeat 1000
        
        gfx.Sprite(@data5, 0,0, 0)
        lcd.Draw
        
        repeat 1000
        
        gfx.Sprite(@data6, 0,0, 0)
        lcd.Draw
    
DAT

data1
word    0
word    8, 8
word    %%00000000
word    %%00000000
word    %%00011000
word    %%00111100
word    %%00111100
word    %%00011000
word    %%00000000
word    %%00000000

data2
word    0
word    8, 8
word    %%00000000
word    %%00011000
word    %%00111100
word    %%01100110
word    %%01100110
word    %%00111100
word    %%00011000
word    %%00000000

data3
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

data4
word    0
word    8, 8
word    %%00011000
word    %%01100110
word    %%01000010
word    %%10000001
word    %%10000001
word    %%01000010
word    %%01100110
word    %%00011000

data5
word    0
word    8, 8
word    %%01100110
word    %%10000001
word    %%10000001
word    %%00000000
word    %%00000000
word    %%10000001
word    %%10000001
word    %%01100110

data6
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
