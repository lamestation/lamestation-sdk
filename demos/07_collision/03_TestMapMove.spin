CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    map  : "LameMap"
    ctrl : "LameControl"

    box  : "gfx_box"

    map1 : "map_map"
    tile : "gfx_box_s"

CON
    w = 24
    h = 24
VAR
    long    x, y
    long    oldx, oldy
    long    adjust
PUB Main

    lcd.Start(gfx.Start)
    map.Load(tile.Addr, map1.Addr)

    x := 12
    y := 12

    repeat
        gfx.ClearScreen(0)
        oldx := x
        oldy := y
        ctrl.Update
        if ctrl.Left
            if x > 0
                x--
        if ctrl.Right
            if x < gfx#res_x
                x++
        adjust := map.TestMoveX(oldx, oldy, word[box.Addr][1], word[box.Addr][2], x)
        if adjust
            x += adjust
            gfx.InvertColor(True)
        if ctrl.Up
            if y > 0
                y--
        if ctrl.Down
            if y < gfx#res_y
                y++

        adjust := map.TestMoveY(oldx, oldy, word[box.Addr][1], word[box.Addr][2], y)
        if adjust
            y += adjust
            gfx.InvertColor(True)
        map.Draw(0,0)
        gfx.Sprite(box.Addr,x, y,0)

        gfx.InvertColor(False)
        lcd.DrawScreen
