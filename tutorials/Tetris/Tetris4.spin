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

    lcd      :   "LameLCD" 
    gfx      :   "LameGFX"
    ctrl     :   "LameControl"

    blocks   :   "tetris"

CON
    MAP_W = 10
    MAP_H = 16
    MAP_SIZE = MAP_W*MAP_H
    MAP_X = 44
    MAP_Y = 0

    TETRO_W = 4
    TETRO_SIZE = TETRO_W*TETRO_W

VAR
    word    mapindex

    word    mapw
    word    maph
    byte    map[MAP_SIZE]

    byte    tx, ty
    byte    tetro[TETRO_SIZE]

    byte    rotate


PUB Main

    lcd.Start(gfx.Start)

    mapw := MAP_W
    maph := MAP_H

    tx := 0
    ty := 0

    repeat mapindex from 0 to MAP_SIZE-1
        map[mapindex] := 1

    gfx.LoadMap(blocks.Addr, @mapw)

    repeat
        gfx.DrawMapRectangle(0, 0, 44, 0, 84, 64)

        ctrl.Update
        if ctrl.A
            rotate := (rotate + 1) & $3

        DrawTetromino(tx,   ty,    0, rotate)
        DrawTetromino(tx,   ty+4,  1, rotate)
        DrawTetromino(tx,   ty+8,  2, rotate)
        DrawTetromino(tx,   ty+12, 3, rotate)
        DrawTetromino(tx+4, ty,    4, rotate)
        DrawTetromino(tx+4, ty+4,  5, rotate)
        DrawTetromino(tx+4, ty+8,  6, rotate)

        lcd.DrawScreen

PUB DrawTetromino(dx, dy, type, rotation) | x, y, base, addr

    base := @tetrominos+type<<4

    repeat y from 0 to 3
        repeat x from 0 to 3
            case rotation
                0:  addr := base + ( y )<<2 + ( x )
                1:  addr := base + ( y )    + (3-x)<<2
                2:  addr := base + (3-y)<<2 + (3-x)
                3:  addr := base + (3-y)    + ( x )<<2

            if byte[addr] > 0
                gfx.Sprite(blocks.Addr, MAP_X + (dx+x)<<2, MAP_Y + (dy+y)<<2, type+1)

DAT

tetrominos

byte    0,0,0,0 '
byte    1,1,1,1 ' ####
byte    0,0,0,0 '
byte    0,0,0,0 '


byte    0,0,0,0 '
byte    0,1,0,0 ' #
byte    0,1,1,1 ' ###
byte    0,0,0,0 '

byte    0,0,0,0 '
byte    0,0,1,0 '   #
byte    1,1,1,0 ' ###
byte    0,0,0,0 '

byte    0,0,0,0 '
byte    0,1,1,0 ' ##
byte    0,1,1,0 ' ##
byte    0,0,0,0 '

byte    0,0,0,0 '
byte    1,1,0,0 ' ##
byte    0,1,1,0 '  ##
byte    0,0,0,0 '

byte    0,0,0,0 '  #
byte    0,1,0,0 ' ###
byte    1,1,1,0 '
byte    0,0,0,0 '

byte    0,0,0,0 '  ##
byte    0,1,1,0 ' ##
byte    1,1,0,0 '
byte    0,0,0,0 '

 
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
