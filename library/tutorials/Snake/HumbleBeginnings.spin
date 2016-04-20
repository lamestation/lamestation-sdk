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
    
    gfx.Sprite(@dot_gfx, 25, 25, 0)
    lcd.Draw
    
DAT
    dot_gfx
    word    0
    word    2, 2
    word    %%22222211
    word    %%22222211
