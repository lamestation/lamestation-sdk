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
    ctrl    :               "LameControl"
    fn      :               "LameFunctions"

    world   :               "map_parrot_town"
    tilemap :               "gfx_pikeman"
    player  :               "gfx_nash"

DAT
    playerx long    16
    playery long    16
    xoffset long    0
    yoffset long    0
    targetx long    16
    targety long    16
    moving  byte    0
    frame   byte    0
    dir     byte    DOWN
    count   byte    0
    
PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    Run

PUB Run
    lcd.SetFrameLimit(lcd#HALFSPEED)
        
    playerx := targetx := 16
    playery := targety := 16
    
    

    gfx.LoadMap(tilemap.Addr, world.Addr)
    repeat
        ctrl.Update
        gfx.ClearScreen(0)

        HandlePlayer
        ControlOffset
        gfx.DrawMap(xoffset,yoffset)
        DrawPlayer

        lcd.DrawScreen
        

PUB HandlePlayer | adjust
    
    if not moving
        if ctrl.Left
            if not gfx.TestMapPoint((playerx>>3)-1, playery>>3)
                targetx -= 8
                dir := LEFT
        elseif ctrl.Right
            if not gfx.TestMapPoint((playerx>>3)+1, playery>>3)
                targetx += 8
                dir := RIGHT
        elseif ctrl.Up
            if not gfx.TestMapPoint(playerx>>3, (playery>>3)-1)
                targety -= 8
                dir := UP
        elseif ctrl.Down
            if not gfx.TestMapPoint(playerx>>3, (playery>>3)+1)
                targety += 8
                dir := DOWN

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


PUB ControlOffset | bound_x, bound_y

    bound_x := gfx.GetMapWidth<<3 - lcd#SCREEN_W
    bound_y := gfx.GetMapHeight<<3 - lcd#SCREEN_H
    
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
