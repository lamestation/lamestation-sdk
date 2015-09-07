CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    fn      :               "LameFunctions"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.ClearScreen(gfx#WHITE)
    lcd.DrawScreen

    fn.Sleep(1000)

    gfx.ClearScreen(gfx#BLACK)
    lcd.DrawScreen

    fn.Sleep(1000)

    gfx.ClearScreen(gfx#GRAY)
    lcd.DrawScreen
