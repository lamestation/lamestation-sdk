CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ

    gfx     : "LameGFX"
    lcd     : "LameLCD"
    audio   : "LameAudio"
    ctrl    : "LameControl"
    fn      : "LameFunctions"

    map     : "map1"
    tilemap : "level1"
    lumpy   : "lumpy"

CON
    #0, LEFT, RIGHT

    WALKSPEED = 10
    GRAVITY = 18

VAR
    long    xoffset

    long    playerx
    long    playery
    long    oldx
    long    oldy
    long    speedx
    long    speedy
    byte    count, frame, dir, jumping

PUB Main

    lcd.Start(gfx.Start)
    gfx.ClearScreen
    lcd.DrawScreen
    lcd.SetFrameLimit(40)
    gfx.LoadMap(tilemap.Addr, map.Addr)

    repeat
        ctrl.Update
        gfx.FillSCreen($5555)

        gfx.DrawMap(xoffset,0)

        HandlePlayer
    
        xoffset := playerx + (word[lumpy.Addr][1]>>1) - (lcd#SCREEN_W>>1)
        if xoffset < 0
            xoffset := 0      
        elseif xoffset > gfx.GetMapWidth << 3 - lcd#SCREEN_W
            xoffset := gfx.GetMapWidth << 3 - lcd#SCREEN_W



        lcd.DrawScreen



PUB HandlePlayer | adjust
    oldx := playerx
    oldy := playery    
            
    if ctrl.Left or ctrl.Right
    
            if ctrl.Left
                if ||speedx < WALKSPEED
                    speedx--

                dir := LEFT
            if ctrl.Right
                if speedx =< WALKSPEED
                    speedx++

                dir := RIGHT

            count++
            if count & $1 == 0
                case (count >> 2) & $1
                    0:  frame := 1
                    1:  frame := 2
    else
        if speedx > 0
            speedx--
        elseif speedx < 0
            speedx++
    
        frame := 0
        count := 0            
         
    playerx += (speedx ~> 2)

    adjust := gfx.TestMapMoveX(oldx, playery, word[lumpy.Addr][1], word[lumpy.Addr][2], playerx)
    if adjust
        playerx += adjust
        speedx := 0

    if ctrl.A
        if not jumping               
            speedy := -30
            jumping := 1                 
            
    if speedy < GRAVITY    
        speedy += 3

    playery += (speedy ~> 2)

    adjust := gfx.TestMapMoveY(playerx, oldy, word[lumpy.Addr][1], word[lumpy.Addr][2], playery)
    if adjust
        playery += adjust
        if  speedy > 0
            jumping := 0
        speedy := 0
    
    if speedy > 0
        jumping := 1


    if dir == LEFT
        gfx.Sprite(lumpy.Addr,playerx-xoffset,playery, 3+frame)
    if dir == RIGHT
        gfx.Sprite(lumpy.Addr,playerx-xoffset,playery, frame)