{{
Tetris
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}

CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd     :   "LameLCD" 
    gfx     :   "LameGFX"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"

    blocks  :   "tetris"

CON
    MAP_W = 10
    MAP_H = 16
    MAP_SIZE = MAP_W*MAP_H
    MAP_X = 44
    MAP_Y = 0

    TETRO_W = 4
    TETRO_SIZE = TETRO_W*TETRO_W

VAR
    word    tetrominos[7]
    word    mapindex

    word    mapw
    word    maph
    byte    map[MAP_SIZE]

    byte    otx, oty, otr, otw, oth
    byte    tx, ty, tr, tw, th
    byte    tetro[TETRO_SIZE]


    byte    type
    byte    apress, bpress


PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#HALFSPEED)

    mapw := MAP_W
    maph := MAP_H

    tx := 0
    ty := 0

    repeat mapindex from 0 to MAP_SIZE-1
        map[mapindex] := 1
   ' repeat mapindex from 100 to MAP_SIZE-1
    '    map[mapindex] := 2

    gfx.LoadMap(blocks.Addr, @mapw)
    LoadTetrominos

    repeat
        gfx.DrawMapRectangle(0, 0, 44, 0, 84, 64)

        otx := tx
        oty := ty
        otw := tw
        oth := th
        otr := tr

        ctrl.Update

        DrawTetromino

        lcd.DrawScreen


PUB DrawTetromino

    ' move left/right
    if ctrl.Left
        tx--
    if ctrl.Right
        tx++

    CheckTetromino(_MOVEX)
    otx := tx


    ' shoot down
    if ctrl.Down
        ty++

    CheckTetromino(_MOVEY)
    oty := ty


    ' place tetromino
    if ctrl.A
        if not apress
            apress := 1
            CheckTetromino(_PLACE)
            ty := 0
            tx := 4            
    else
        apress := 0


    ' rotate tetromino
    if ctrl.B
        if not bpress
            bpress := 1
            tr := (tr + 1) & $3
            CheckTetromino(_ROTATE)
    else
        bpress := 0

    ' draw tetromino
    CheckTetromino(_DRAW)



CON
    #0, _COLLIDE, _PLACE, _MOVEX, _MOVEY, _ROTATE, _DRAW

PUB CheckTetromino(attr) | x, y, base, addr

    base := tetrominos[type]

    case tr
        0,2:    tw := byte[base][0]
                th := byte[base][1]
        1,3:    th := byte[base][0]
                tw := byte[base][1]

    base += 2

    repeat y from 0 to th-1
        repeat x from 0 to tw-1
            case tr
                0:  addr := base + (  y   )*tw   + (  x   )
                1:  addr := base + (  y   )      + (tw-1-x)*th
                2:  addr := base + (th-1-y)*tw   + (tw-1-x)
                3:  addr := base + (th-1-y)      + (  x   )*th

            if byte[addr] > 0
                case attr
                    _COLLIDE:   if (tx+x) => MAP_W or (ty+y) => MAP_H or map[(ty+y)*MAP_W+(tx+x)] > 1
                                    return 1

                    _PLACE:     map[(ty+y)*MAP_W+(tx+x)] := type+2

                    _ROTATE:    if map[(ty+y)*MAP_W+(tx+x)] > 1
                                    tr := otr
                                if tx+x => MAP_W
                                    tr := otr
                                if ty+y => MAP_H
                                    tr := otr

                    _MOVEX:     if (tx+x) => MAP_W or tx < 0 or map[(ty+y)*MAP_W+(tx+x)] > 1
                                    tx := otx

                    _MOVEY:     if (ty+y) => MAP_H or map[(ty+y)*MAP_W+(tx+x)] > 1
                                    ty := oty

                    _DRAW:      gfx.Sprite(blocks.Addr, MAP_X + (tx+x)<<2, MAP_Y + (ty+y)<<2, type+1)


    if attr == _PLACE
        CheckMap
        GetNewTetro


VAR
    byte    linecleared[MAP_H]

PUB GetClearedLinesCount | lines, l
    lines := 0
    repeat l from 0 to MAP_H-1
        if linecleared[l]
            lines++
    return lines

PUB CheckMap | line
    repeat line from MAP_H-1 to 0
        linecleared[line] := CheckLine(line)

    if GetClearedLinesCount
        MarkLinesForDeletion

PUB CheckLine(line) | linecount, lineiter
    linecount := 0
    repeat lineiter from 0 to MAP_W-1
        if map[line*MAP_W+lineiter] > 1
            linecount++
    if linecount => MAP_W
        return 1

PUB MarkLinesForDeletion | l1,l2

    l2 := MAP_H-1
    repeat l1 from MAP_H-1 to 0
        if linecleared[l1]
            l2++
        else
            bytemove(@map + l2*MAP_W, @map + l1*MAP_W, MAP_W)
        l2--

    repeat l1 from 0 to l2
        bytefill(@map + l1*MAP_W, 1, MAP_W)

PUB GetNewTetro | ran
    ran := cnt
    type := (ran? & $FF) // 7


PUB LoadTetrominos
    tetrominos[0] := @tetro1
    tetrominos[1] := @tetro2
    tetrominos[2] := @tetro3
    tetrominos[3] := @tetro4
    tetrominos[4] := @tetro5
    tetrominos[5] := @tetro6
    tetrominos[6] := @tetro7


DAT

tetro1
byte    4,1
byte    1,1,1,1 ' ####

tetro2
byte    3,2
byte    1,0,0   ' #
byte    1,1,1   ' ###

tetro3
byte    3,2
byte    0,0,1   '   #
byte    1,1,1   ' ###

tetro4
byte    2,2
byte    1,1     ' ##
byte    1,1     ' ##

tetro5
byte    3,2
byte    1,1,0   ' ##
byte    0,1,1   '  ##

tetro6
byte    3,2
byte    0,1,0   '  #
byte    1,1,1   ' ###

tetro7
byte    3,2
byte    0,1,1   '  ##
byte    1,1,0   ' ##

 
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
