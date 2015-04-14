CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd     :               "LameLCD"
    gfx     :               "LameGFX"

    sprite  :               "gfx_radar"

PUB Main | frame

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)
    repeat
        gfx.Sprite(sprite.Addr, 56, 24, frame)
        lcd.DrawScreen
        frame++
        if frame > 15
            frame := 0
