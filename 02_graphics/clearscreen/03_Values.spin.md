
    CON
        _clkmode = xtal1|pll16x
        _xinfreq = 5_000_000

    OBJ

        lcd     :               "LameLCD"
        gfx     :               "LameGFX"
        fn      :               "LameFunctions"

    PUB Blit | val

        lcd.Start(gfx.Start)
        gfx.ClearScreen($FFFF)
        lcd.DrawScreen

        fn.Sleep(500)

        gfx.ClearScreen(0)
        lcd.DrawScreen

        fn.Sleep(500)

        gfx.ClearScreen($FF00)
        lcd.DrawScreen

        fn.Sleep(500)

        gfx.ClearScreen($abc3)
        lcd.DrawScreen
