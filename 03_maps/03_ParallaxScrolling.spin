CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ

    lcd     :   "LameLCD"
    gfx     :   "LameGFX"
    map     :   "LameMap"
    ctrl    :   "LameControl"
    mp      :   "map_cave"
    mp2     :   "map_cave2"
    tileset :   "gfx_cave"
    bkdrop  :   "gfx_cavelake"

VAR
    long    xoffset, yoffset
    long    offsetw, offseth
    long    w1, h1, w2, h2
    long    dx, dy

PUB Main

    lcd.Start(gfx.Start)

    map.Load(tileset.Addr, mp.Addr)
    w1 := map.GetWidth<<3-128
    h1 := map.GetHeight<<3-64

    map.Load(tileset.Addr, mp2.Addr)
    w2 := map.GetWidth<<3-128
    h2 := map.GetHeight<<3-64

    dx  := w1/w2
    dy  := h1/h2

    yoffset := 64

    repeat
        ctrl.Update
        if ctrl.Left
            if xoffset > 0
                xoffset--
        if ctrl.Right
            if xoffset < w1
                xoffset++
        if ctrl.Up
            if yoffset > 0
                yoffset--
        if ctrl.Down
            if yoffset < h1
                yoffset++

        gfx.Blit(bkdrop.Addr)

        gfx.InvertColor(True)
        map.Load(tileset.Addr, mp2.Addr)
        map.Draw(xoffset/dx, yoffset/dy)
        gfx.InvertColor(False)

        map.Load(tileset.Addr, mp.Addr)
        map.Draw(xoffset, yoffset)

        lcd.DrawScreen

