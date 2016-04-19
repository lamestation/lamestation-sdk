OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"
    
    happy : "HappyFaceGFX"

PUB Main
    lcd.Start(gfx.Start)
    gfx.Sprite(happy.Gfx, 56, 24, 0)
    lcd.DrawScreen
