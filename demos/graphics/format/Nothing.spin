OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.Sprite(0, 0, 0, 0)
    lcd.DrawScreen

