
    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

    OBJ

        lcd     :               "LameLCD"
        gfx     :               "LameGFX"

    PUB Blit

        lcd.Start(gfx.Start)
        gfx.ClearScreen(0)
        lcd.DrawScreen
