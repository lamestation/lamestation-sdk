
    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

    OBJ

        lcd     :               "LameLCD"
        gfx     :               "LameGFX"

        sprite  :               "gfx_supertank"

    PUB Main

        lcd.Start(gfx.Start)
        gfx.Sprite(sprite.Addr, 56, 24, 0)
        lcd.DrawScreen
