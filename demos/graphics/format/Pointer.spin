OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"
    ctrl: "LameControl"
    
VAR
    byte    frame
    
PUB Main
    lcd.Start(gfx.Start)

    repeat
        ctrl.Update
        
        if ctrl.Up
            frame := 0
        if ctrl.Right
            frame := 1
        if ctrl.Down
            frame := 2
        if ctrl.Left
            frame := 3

        gfx.Sprite(@data, 60, 28, frame)
        lcd.DrawScreen

DAT

data
word    16
word    8, 8

word    %%00011000
word    %%00011000
word    %%00111100
word    %%00111100
word    %%01111110
word    %%01111110
word    %%11111111
word    %%11111111

word    %%00000011
word    %%00001111
word    %%00111111
word    %%11111111
word    %%11111111
word    %%00111111
word    %%00001111
word    %%00000011

word    %%11111111
word    %%11111111
word    %%01111110
word    %%01111110
word    %%00111100
word    %%00111100
word    %%00011000
word    %%00011000

word    %%11000000
word    %%11110000
word    %%11111100
word    %%11111111
word    %%11111111
word    %%11111100
word    %%11110000
word    %%11000000
