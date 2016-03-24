CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"

PUB Main | val
    lcd.Start(gfx.Start)

    val := %%1000_0000_1000_0000
    repeat
        gfx.Fill(val)
        lcd.DrawScreen
        val ->= 2
