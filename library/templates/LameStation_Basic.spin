CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    ' add your code here