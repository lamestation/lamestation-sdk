{{
Pikemanz - Overworld
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation.
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    #0, UP, RIGHT, DOWN, LEFT

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    map     :               "LameMap"
    ctrl    :               "LameControl"
    fn      :               "LameFunctions"

    state   :   "PikeState"

    player  :               "gfx_nash"

DAT
    playerx long        0
    playery long        0
    xoffset long        0
    yoffset long        0
    targetx long        0
    targety long        0
    moving  byte        0
    frame   byte        0
    dir     byte        DOWN
    count   byte        0

OBJ
    map_parrot_town     :   "map_parrot_town"
    map_path1           :   "map_path1"
    map_path2           :   "map_path2"

    tilemap     :   "gfx_pikeman"

CON
    WORLD_W = 1
    WORLD_H = 3
DAT
    currentmap  word    0
    worldmap    word    0[9]
    worldx      word    0
    worldy      word    2

    mapchanged  word    0

PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start

    Init
    repeat
        View

PUB Init

    playerx := targetx := 3<<3
    playery := targety := 4<<3

    worldmap[0] := map_path2.Addr
    worldmap[1] := map_path1.Addr
    worldmap[2] := map_parrot_town.Addr

    mapchanged := 1

PUB View

    repeat

        ctrl.Update
        gfx.ClearScreen(0)

        HandlePlayer
        ControlMap
        ControlOffset
        map.Draw(xoffset, yoffset)
        DrawPlayer
        fn.Sleep(30)

        if playerx >> 3 > 10
            'playerx := targetx := 3 << 3
            return state.SetState(state#_BATTLE)

        lcd.DrawScreen

PUB HandlePlayer | adjust

    if not moving

    moving := 1
    if targetx > playerx
        playerx++
    elseif targetx < playerx
        playerx--
    elseif targety > playery
        playery++
    elseif targety < playery
        playery--
    else
        if ctrl.Left
            dir := LEFT
            if not map.TestPoint((playerx>>3)-1, playery>>3)
                targetx -= 8

        elseif ctrl.Right
            dir := RIGHT
            if not map.TestPoint((playerx>>3)+1, playery>>3)
                targetx += 8

        elseif ctrl.Up
            dir := UP
            if not map.TestPoint(playerx>>3, (playery>>3)-1)
                targety -= 8

        elseif ctrl.Down
            dir := DOWN
            if not map.TestPoint(playerx>>3, (playery>>3)+1)
                targety += 8

        else
            moving := 0

    if moving
        count++
        if count & $3 == 0
            case (count >> 2) & $1
                0:  frame := 1
                1:  frame := 2
    else
        frame := 0
        'count := 0

PUB DrawPlayer
    gfx.Sprite(player.Addr,(playerx)-xoffset,(playery)-yoffset, dir*3+frame)

PUB ControlMap
    if not moving
        if playerx < 0
            if worldx > 0
                worldx--
                playerx := targetx := (map.GetWidth-1)<<3
        if playerx > (map.GetWidth-1)<<3
            if worldx < WORLD_W-1
                worldx++
                playerx := targetx := 0

        if playery < 0
            if worldy > 0
                worldy--
                playery := targety := (map.GetHeight-1)<<3
        if playery > (map.GetHeight-1)<<3
            if worldy < WORLD_H-1
                worldy++
                playery := targety := 0

    if mapchanged
        map.Load(tilemap.Addr, worldmap[WORLD_W*worldx + worldy])

PUB ControlOffset | bound_x, bound_y

    bound_x := map.GetWidth<<3 - lcd#SCREEN_W
    bound_y := map.GetHeight<<3 - lcd#SCREEN_H

    xoffset := playerx + (word[player.Addr][1]>>1) - (lcd#SCREEN_W>>1)
    if xoffset < 0
        xoffset := 0
    elseif xoffset > bound_x
        xoffset := bound_x

    yoffset := playery + (word[player.Addr][2]>>1) - (lcd#SCREEN_H>>1)
    if yoffset < 0
        yoffset := 0
    elseif yoffset > bound_y
        yoffset := bound_y

DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT
