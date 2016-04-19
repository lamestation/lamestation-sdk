CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    map  : "LameMap"
    box  : "gfx_box"
    map1 : "map_map"
    tile : "gfx_box_s"
VAR
    byte    x1, y1
CON
    w = 24
    h = 24
PUB Main
    lcd.Start(gfx.Start)
    x1 := 12
    y1 := 12
    map.Load(tile.Addr, map1.Addr)
    repeat
        gfx.Clear

        ctrl.Update
        if ctrl.Left
            if x1 > 0
                x1--
        if ctrl.Right
            if x1 < gfx#res_x-24
                x1++
        if ctrl.Up
            if y1 > 0
                y1--
        if ctrl.Down
            if y1 < gfx#res_y-24
                y1++
        if map.TestCollision(x1, y1, w, h)
            gfx.InvertColor(True)
        map.Draw(0,0)
        gfx.Sprite(box.Addr,x1,y1,0)
        gfx.InvertColor(False)
        lcd.DrawScreen

