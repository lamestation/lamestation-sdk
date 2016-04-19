CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    fn      :               "LameFunctions"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.Fill($FFFF)
    lcd.DrawScreen

    fn.Sleep(500)

    gfx.Clear
    lcd.DrawScreen

    fn.Sleep(500)

    gfx.Fill($FF00)
    lcd.DrawScreen

    fn.Sleep(500)

    gfx.Fill($abc3)
    lcd.DrawScreen
