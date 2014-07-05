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

    WALKSPEED = 4

VAR
    long    xoffset

    long    playerx
    long    playery
    long    oldx
    long    oldy
    long    speed
    byte    count, frame, dir, jumping

PUB Main

    gfx.Start(lcd.Start)
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



        gfx.DrawScreen
        fn.Sleep(40)



PUB HandlePlayer
    oldx := playerx
    oldy := playery    
            
    if ctrl.Left or ctrl.Right
    
            if ctrl.Left
                playerx -= WALKSPEED
                dir := LEFT
            if ctrl.Right
                playerx += WALKSPEED
                dir := RIGHT
    
            count++
            if count & $1 == 0
                case (count >> 2) & $1
                    0:  frame := 1
                    1:  frame := 2
    else
            frame := 0
            count := 0            
         
    if gfx.TestMapCollision(playerx, playery, word[lumpy.Addr][1], word[lumpy.Addr][2])
        playerx := oldx

    if ctrl.A
        if not jumping               
            speed := -9
            jumping := 1                 
                
    speed += 1
    playery += speed

    if gfx.TestMapCollision(playerx, playery, word[lumpy.Addr][1], word[lumpy.Addr][2])
        if  speed > 0
            jumping := 0
        playery := oldy
        speed := 0
    
    if speed > 0
        jumping := 1


    if dir == LEFT
        gfx.Sprite(lumpy.Addr,playerx-xoffset,playery, 3+frame)
    if dir == RIGHT
        gfx.Sprite(lumpy.Addr,playerx-xoffset,playery, frame)