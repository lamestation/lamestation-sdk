CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd     :               "LameLCD"
        gfx     :               "LameGFX"
        fn      :               "LameFunctions"
        audio   :               "LameAudio"

        font_8x8    :           "gfx_font8x8"
        font_6x8    :           "gfx_font6x8"
        font_4x4    :           "gfx_font4x4"

PUB TextDemo | x, ran, y

    lcd.Start(gfx.Start)
    audio.Start

    repeat
        gfx.ClearScreen(0)

        ThisIsATest
        ZoomToCenter
        HouseOfLeaves

PUB ThisIsATest
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen(0)
    gfx.PutString(string("THIS IS A TEST"),4,28)
    lcd.DrawScreen
    fn.Sleep(1000)

    gfx.ClearScreen(0)
    gfx.PutString(string("DO NOT ADJUST"),10,24)
    gfx.PutString(string("YOUR BRAIN"),15,32)
    lcd.DrawScreen
    fn.Sleep(1000)

PUB HouseOfLeaves

    gfx.LoadFont(font_4x4.Addr, " ", 4, 4)

    gfx.PutChar("c", 120, 0)

    gfx.PutString(string("Super Texty Fun-Time?"), 0, 0)
    gfx.PutString(string("Wow, this isn't legible at all!"), 0, 40)
    gfx.PutString(string("Well, kind of, actually."), 0, 44)
    gfx.PutString(@allcharacters, 0, 5)

    gfx.TextBox(string("Lorem ipsum dolor chicken bacon inspector cats and more"), 52, 32, 5, 32)
    lcd.DrawScreen
    fn.Sleep(2000)

    gfx.ClearScreen(0)
    gfx.TextBox(string("I recently added LoadFont, PutChar and PutString functions to LameGFX.spin. I used to use the TextBox command, which used the format you described to draw to the screen, but now that LameGFX uses a linear framebuffer, that approach doesn't make sense anymore. PutChar and PutString work by simply using the Box command. I'm working on supporting arbitrary font sizes, variable-width fonts, and a one-bit color mode so that fonts don't waste space."),1,1,120,56)
    lcd.DrawScreen
    fn.Sleep(2000)

    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.PutString(string("A LOT OF TEXT"), 6, 32)
    lcd.DrawScreen
    fn.Sleep(2000)

    gfx.ClearScreen(0)
    lcd.DrawScreen
    fn.Sleep(1000)

PUB ZoomToCenter | x, y, ax, ay, vx, vy, m, ran, count, count2, centerx, centery
    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)
    gfx.ClearScreen(0)

    centerx := 64
    centery := 32
    vx := 10
    vy := 0
        ran := cnt
        x := ran? & $7F
        y := ran? & $3F
        repeat count2 from 1 to 200
            gfx.ClearScreen(0)

            ax := (centerx - x)/20
            ay := (centery - y)/20

            vx += ax
            vy += ay

            x += vx
            y += vy

            gfx.PutString(string("BUY ME!!"), x-16, y-4)
            gfx.PutString(string("SUBLIMINAL"), 12, 32)
            lcd.DrawScreen

DAT
''Strings need to be null-terminated
allcharacters   byte    "!",34,"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz",0