CON

    #0, LEFT, RIGHT
    
OBJ    
    gfx         : "LameGFX"

    gfx_whoosh  : "gfx_whoosh"
    
PUB Draw(x, y, dir) | i, w, h, count, frame

    i := 0
    w := gfx.Width (gfx_whoosh.Addr)
    h := gfx.Height (gfx_whoosh.Addr) >> 1
    frame := 2
    
    if x > constant(gfx#SCREEN_W << 1)
'        i := (x - gfx#SCREEN_W << 1) / w * w
        count := (x - gfx#SCREEN_W << 1) / w
        if count < 4
            frame := 1
        elseif count => 4 and count < 8
            frame := 0
        else
            return
        
    repeat while i < x
        gfx.Sprite (gfx_whoosh.Addr, i, y - h, frame)
        i += w