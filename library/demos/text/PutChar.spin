CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    txt  : "LameText"
    font : "gfx_font8x8"

PUB PutChar | x, ran, y, count, char

    lcd.Start(gfx.Start)
    txt.Load(font.Addr, " ", 0, 0)
    repeat
        gfx.Clear
        repeat count from 1 to 1000
            ran := cnt
            x := ran? & $7F
            y := ran? & $3F
            char := ran? & %11111
            txt.Char("A" + char, x-8, y-8)
            lcd.DrawScreen
