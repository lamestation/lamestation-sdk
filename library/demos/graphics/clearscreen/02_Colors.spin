CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    fn      :               "LameFunctions"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.Fill(gfx#WHITE)
    lcd.Draw

    fn.Sleep(1000)

    gfx.Fill(gfx#BLACK)
    lcd.Draw

    fn.Sleep(1000)

    gfx.Fill(gfx#GRAY)
    lcd.Draw
