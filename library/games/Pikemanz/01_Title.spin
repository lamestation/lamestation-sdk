CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    lcd         :   "LameLCD"
    gfx         :   "LameGFX"
    txt         :   "LameText"
    ctrl        :   "LameControl"
    state       :   "PikeState"

    menu        :   "PikeMenu"
    title       :   "gfx_title"
    font_text   :   "gfx_font6x6_b"
    nash        :   "gfx_nash_fetchum"

PUB Main
    lcd.Start(gfx.Start)
    View

PUB View
    gfx.Fill(gfx#WHITE)
    txt.Load(font_text.Addr, " ", 0, 0)

    gfx.Sprite(title.Addr,1,10,0)
    txt.Str(string("lame version"), 17, 53)
    gfx.Sprite(nash.Addr, 100,14,0)

    lcd.Draw

    ctrl.WaitKey

    state.SetState(state#_INTRO)
