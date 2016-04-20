CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd : "LameLCD"
    gfx : "LameGFX"

    img : "gfx_dagron"

PUB Main
    lcd.Start(gfx.Start)
    
    gfx.Blit(img.Addr)
    lcd.Draw
