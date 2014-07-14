{{
     ______                             ____                _ 
    |  ____|                           |  _ \              | |
    | |__ _ __ __ _ _ __  _ __  _   _  | |_) | __ _ _ __ __| |
    |  __| '__/ _` | '_ \| '_ \| | | | |  _ < / _` | '__/ _` |
    | |  | | | (_| | |_) | |_) | |_| | | |_) | (_| | | | (_| |
    |_|  |_|  \__,_| .__/| .__/ \__, | |____/ \__,_|_|  \__,_|
                   | |   | |     __/ |                        
                   |_|   |_|    |___/                         
    ----------------------------------------------------------
    A shockingly original game for the LameStation!
    ----------------------------------------------------------
    Brett Weir, 2014
}}

CON
    _clkmode = XTAL1|PLL16X
    _xinfreq = 5_000_000

OBJ

    gfx     : "LameGFX"
    lcd     : "LameLCD"
    audio   : "LameAudio"
    ctrl    : "LameControl"
    fn      : "LameFunctions"

    tilemap  : "tilemap"
    player   : "frappy"
    title    : "frappybird"
    youdied  : "youdie"
    font     : "numbers"
    pressa   : "pressa"


CON

    PIPE_TOP = 3
    PIPE_MID = 5
    PIPE_BOT = 7

    SKY = 1
    SKYLINE = 0
    BUSH = 2
    FLOOR = 4
    UNDER = 6


VAR

    long    xoffset
    long    xoffsetcounter

    long    playerx
    long    playery
    long    speedx
    long    speedy
    byte    flighttimeout, clicked, died, tapped
    byte    score


PUB Main

    lcd.Start(gfx.Start)
    gfx.ClearScreen(0)
    lcd.DrawScreen
    lcd.SetFrameLimit(40)
    gfx.LoadFont(font.Addr, "0", 4, 6)

    clicked := 0
    repeat
        TitleScreen
        GameLoop
        GameOver


PUB TitleScreen | flightstate

    xoffset := 0

    repeat while not ctrl.A or ctrl.B
        ctrl.Update

        xoffset++

        gfx.ClearScreen(gfx#WHITE)

        PutTileParallax(0,48,16,UNDER)
        PutTileParallax(xoffset,56,16,FLOOR)
        PutTileParallax(xoffset,40,8,BUSH)
        PutTileParallax(xoffset,24,4,SKYLINE)

        if flighttimeout > 0
            flighttimeout--
        else
            flighttimeout := 20
            if flightstate
                flightstate := 0
            else
                flightstate := 1

        gfx.Sprite(player.Addr, 56, 32, flightstate)
    
        gfx.Sprite(title.Addr, 40, 4, 0)
        gfx.Sprite(pressa.Addr,44,52,0)
        lcd.DrawScreen


PUB GameLoop

    xoffset := 0
    died := 0
    tapped := 0

    playerx := 56
    playery := 32
    score := 0

    InitPipes

    repeat while not died
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)

        xoffset++

        PutTileParallax(0,48,16,UNDER)
        PutTileParallax(xoffset,56,16,FLOOR)
        PutTileParallax(xoffset,40,8,BUSH)
        PutTileParallax(xoffset,24,4,SKYLINE)

        ControlPipes

        HandlePlayer

        KeepScore

        lcd.DrawScreen


PUB GameOver
    gfx.Sprite(youdied.Addr,40,32,0)
    lcd.DrawScreen
    fn.Sleep(1500)


PUB HandlePlayer

    if ctrl.A
        if not clicked
            clicked := 1
            flighttimeout := 10
            speedy := -9
    else
        clicked := 0
        flighttimeout := 0

    if speedy < 32
        speedy++

    playery += (speedy ~> 2)

    if playery > constant(60-16)
        speedy := 0
        died := 1


    if flighttimeout > 0
        gfx.Sprite(player.Addr, playerx, playery, 1)
        flighttimeout--
    else
        gfx.Sprite(player.Addr, playerx, playery, 0)


CON

    MAXPIPES = 8


VAR
    byte    pipeon[MAXPIPES]
    long    pipex[MAXPIPES]
    long    pipey[MAXPIPES]
    long    pipeh[MAXPIPES]
    byte    passed[MAXPIPES]
    
    byte    pipe


PUB InitPipes | t

    xoffset := 0
    pipe := 0

    repeat t from 0 to MAXPIPES-1
        pipex[t] := 0
        pipey[t] := 0
        pipeh[t] := 0
        passed[t] := 0
        pipeon[t] := 0


PUB ControlPipes | t, ran

    if xoffsetcounter > 0
        xoffsetcounter--
    else
        ran := cnt
        xoffsetcounter := 32 + (ran? & $1F)

        pipex[pipe] := xoffset+lcd#SCREEN_W
        pipey[pipe] := 16 + (ran?  & $F)
        pipeh[pipe] := 16'14 + (ran? & $7)
        passed[pipe] := 0
        pipeon[pipe] := 1
        pipe := (pipe+1) & $7

    repeat t from 0 to MAXPIPES-1
        if pipeon[t]
            PutPipeOpening(pipex[t]-xoffset, pipey[t], pipeh[t])
            if playerx+xoffset > pipex[t]+16 and not passed[t]
                passed[t] := 1
                score++


PUB PutPipeOpening(x,y,h) | bound_upper, bound_lower, dy, t
    bound_upper := y-h-16
    bound_lower := y+h

    dy := bound_upper
    if dy > 0
        repeat t from 0 to dy step 16
            PutTile(x,t,PIPE_MID)

    dy := bound_lower + 16
    if dy < 64
        repeat t from dy to 64 step 16
            PutTile(x,t,PIPE_MID)
    
    PutTile(x,bound_upper,PIPE_BOT)
    PutTile(x,bound_lower,PIPE_TOP)

    
    if fn.TestBoxCollision(playerx, playery, word[player.Addr][1], word[player.Addr][2], x, 0, 16, bound_upper+16)
        died := 1
    if fn.TestBoxCollision(playerx, playery, word[player.Addr][1], word[player.Addr][2], x, bound_lower, 16, 64)
        died := 1


PUB PutTileParallax(x, y, speed, tile) | t, dx
    dx := 16/speed - 1
    x := (x >> dx) & $F

    repeat t from 0 to 128 step 16
        PutTile(t-x, y, tile)
    

PUB PutTile(x, y, tile)
    gfx.Sprite(tilemap.Addr, x, y, tile)


VAR

    byte    intarray[4]


PUB KeepScore | tmp
    tmp := score
    intarray[2] := 48+(tmp // 10)
    tmp /= 10
    intarray[1] := 48+(tmp // 10)
    tmp /= 10
    intarray[0] := 48+(tmp // 10)
    intarray[3] := 0

    gfx.PutString(@intarray, 0, 0)


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