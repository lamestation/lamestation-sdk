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
    audio   :   "LameAudio"
    music   :   "LameMusic"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"

    blocks  :   "gfx_bretrominos"
    frame   :   "gfx_wall"
    font    :   "gfx_font4x6_w"
    box     :   "gfx_scorebox"

    song    :   "sng_tetris"

CON
    MAP_W = 10
    MAP_H = 16
    MAP_SIZE = MAP_W*MAP_H
    MAP_X = 44
    MAP_Y = 0

    TETRO_W = 4
    TETRO_SIZE = TETRO_W*TETRO_W

    LEVELBREAK = 10

VAR
    long    dropcounter
    long    dropmax

    word    tetrominos[7]
    word    mapindex

    word    mapw
    word    maph
    byte    map[MAP_SIZE]

    byte    otx, oty, otr, otw, oth
    byte    tx, ty, tr, tw, th
    byte    tetro[TETRO_SIZE]

    byte    type, nexttype
    byte    apress, bpress


PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#HALFSPEED)

    audio.Start
    music.Start
    music.LoadSong(song.Addr)
    music.LoopSong


    mapw := MAP_W
    maph := MAP_H


    LoadTetrominos

    gfx.LoadFont(font.Addr," ",0,0)

    ResetGame


    repeat

        Overlay        
        gfx.Map(blocks.Addr, @mapw, 0, 0, MAP_X, MAP_Y, constant(MAP_X+MAP_W<<2), constant(MAP_Y+MAP_H<<2))

        otx := tx
        oty := ty
        otw := tw
        oth := th
        otr := tr

        dropmax := 9 - level

        ctrl.Update

        DrawTetromino
        

        lcd.DrawScreen

PUB ResetGame | x,y
    GetNewTetro

    dropmax := 9
    score := 0

    bytefill(@map, 1, MAP_SIZE)

    repeat y from 0 to 63 step 8
        gfx.Sprite(frame.Addr,MAP_X-8,y,0)

    repeat y from 0 to 63 step 8
        gfx.Sprite(frame.Addr,MAP_X+MAP_W<<2,y,1)


PUB Overlay
    gfx.PutString(string("Lines"),1,1)
    CalculateScoreStr(score)
    gfx.Sprite(box.Addr,1,7,0)
    gfx.PutString(@scorestr,14,9)

    gfx.PutString(string("Level"),1,17)
    gfx.Sprite(box.Addr,1,23,0)
    gfx.PutChar("0"+level,30,25)


VAR
    long    score
    byte    scorestr[6]
    byte    level
    byte    levelinc

PUB CalculateScoreStr(value) | i, active, ind
    i := 10_000
    active := 0

    repeat ind from 0 to 4
        if value => i
            active := 1
            scorestr[ind] := value / i + "0"
            value //= i
        else
            if active or (i == 1 and value == 0)
                scorestr[ind] := "0"
            else
                scorestr[ind] := " "

        i /= 10

    scorestr[5] := 0



PUB DrawTetromino

    ' move left/right
    if ctrl.Left
        tx--
    if ctrl.Right
        tx++

    CheckTetromino(_MOVEX)
    otx := tx

    ' drop down
    if dropcounter > dropmax or ctrl.A
        dropcounter := 0
        ty++
    else
        dropcounter++
    
    if CheckTetromino(_COLLIDE)
        if ty < 1
            ResetGame
            return

        ty := oty
        CheckTetromino(_PLACE)

    oty := ty

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
            score++

            levelinc++
            if levelinc => levelbreak
                level++
                levelinc := 0
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
    type := nexttype
    nexttype := (ran? & $FF) // 7
    ty := -1
    tx := 4


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
