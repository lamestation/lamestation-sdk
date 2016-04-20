CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    txt  : "LameText"
    font : "gfx_font4x6"

PUB Kerning

    lcd.Start(gfx.Start)

    gfx.Clear

    ' 0,0 loads default kerning, so normal letter spacing
    txt.Load(font.Addr, " ", 0, 0)
    txt.Box(@strang,0,0,128,30)

    ' kerning can also be specified, giving rise to completely
    ' right or completely wrong sizes...
    txt.Load(font.Addr, " ", 6, 8)
    txt.Box(@strang,0,16,128,30)

    txt.Load(font.Addr, " ", 10, 10)
    txt.Box(@strang,0,32,128,30)

    txt.Load(font.Addr, " ", 3, 3)
    txt.Box(@strang,0,52,128,30)

    lcd.Draw

    repeat

DAT

strang  byte    "This is cool",10,"You think so?",0
