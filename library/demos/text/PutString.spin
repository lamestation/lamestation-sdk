CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    txt  : "LameText"
    font : "gfx_font6x8"

PUB Main

    lcd.Start(gfx.Start)

    txt.Load(font.Addr, " ", 0, 0)
    txt.Str(string("THIS IS A TEST"),4,28)

    lcd.Draw
