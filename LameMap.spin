CON
    #0, MX, MY                                          ' level map header indices
    #1, SX, SY                                          '  tile map header indices

    COLLIDEBIT = $80

OBJ
    gfx :   "LameGFX"

DAT

map_tilemap     long    0
map_levelmap    long    0

PUB Load(source_tilemap, source_levelmap)

    map_tilemap  := source_tilemap
    map_levelmap := source_levelmap
    
PUB TestPoint(x, y) | tilebase
    tilebase := 4 + word[map_levelmap][MX] * y + map_levelmap
    if (byte[tilebase][x] & COLLIDEBIT)
        return 1

PUB TestCollision(objx, objy, objw, objh) | tilebase, x, y, tx, ty
'' Returns non-zero if a collision has occurred between an object and the map; 0 otherwise.
'' Returned tiles are offset by (1,1).

    ty := word[map_tilemap][SY]

    objh  := (word[map_levelmap][MY] * ty) <# (objh += objy)
    objy #>= 0

    if objh-- =< objy
        return

    tx := word[map_tilemap][SX]

    objw  := (word[map_levelmap][MX] * tx) <# (objw += objx)
    objx #>= 0

    if objw-- =< objx
        return

    objx /= tx
    objy /= ty
    objw /= tx
    objh /= ty

    tilebase := 4 + word[map_levelmap][MX] * objy + map_levelmap

    repeat y from objy to objh
        repeat x from objx to objw
            if (byte[tilebase][x] & COLLIDEBIT)
                return (x+1)+((y+1) << 16)

        tilebase += word[map_levelmap][MX]

PUB TestMoveY(x, y, w, h, newy) | tmp, ty

    if newy == y
        return

    tmp := TestCollision(x, newy, w, h)
    if not tmp
        return

    ty  := word[map_tilemap][SY]
    tmp := ((tmp >> 16)-1) * ty - newy

    if newy > y
        return tmp - h

' newy == y is covered at the top so now newy *is* less than y

    return tmp + ty

PUB TestMoveX(x, y, w, h, newx) | tmp, tx

    if newx == x
        return

    tmp := TestCollision(newx, y, w, h)
    if not tmp
        return

    tx  := word[map_tilemap][SX]
    tmp := ((tmp & $FFFF)-1) * tx - newx

    if newx > x
        return tmp - w

' newx == x is covered at the top so now newx *is* less than x

    return tmp + tx

PUB Width

    return word[map_levelmap][MX]

PUB Height

    return word[map_levelmap][MY]

PUB Draw(offset_x, offset_y)
'' This function uses the Sprite command to draw an array of tiles to the screen.
'' Used in conjunction with the map2dat program included with this kit, it is
'' an easy way to draw your first game world to the screen.

    gfx.Map(map_tilemap, map_levelmap, offset_x, offset_y, 0, 0, gfx#res_x, gfx#res_y)

PUB DrawRectangle(offset_x, offset_y, x1, y1, x2, y2)

    gfx.Map(map_tilemap, map_levelmap, offset_x, offset_y, x1, y1, x2, y2)

