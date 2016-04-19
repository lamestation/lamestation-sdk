CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    #0, RIGHT, UP, LEFT, DOWN

OBJ
    lcd     : "LameLCD"
    gfx     : "LameGFX"
    txt     : "LameText"
    map     : "LameMap"
    ctrl    : "LameControl"
    fn      : "LameFunctions"

    world   : "overworld"
    tilemap : "tiles_2b_poketron"
    player  : "knight"
    title   : "epictitle"
    ghost   : "ghosterman"

VAR
    long    playerx
    long    playery
    long    oldx
    long    oldy
    byte    frame
    byte    dir
    byte    count
    long    xoffset
    long    yoffset



PUB Main
    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#HALFSPEED)
    ctrl.Start


    gfx.Clear
    gfx.Sprite(title.Addr, 20, 0, 0)
    gfx.Sprite(ghost.Addr, 15, 25, 0)
    lcd.DrawScreen

    repeat while not ctrl.A or ctrl.B
        ctrl.Update

    playerx := 40

    map.Load(tilemap.Addr, world.Addr)
    repeat
        ctrl.Update
        gfx.Clear

        HandlePlayer
        ControlOffset
        map.Draw(xoffset,yoffset)
        DrawPlayer

        lcd.DrawScreen
        

PUB HandlePlayer  | adjust

    oldx := playerx
    oldy := playery    
            
    if ctrl.Left or ctrl.Right or ctrl.Up or ctrl.Down
    
        if ctrl.Left
            playerx--
            dir := LEFT
        if ctrl.Right
            playerx++
            dir := RIGHT

        adjust := map.TestMoveX(oldx, playery, word[player.Addr][1], word[player.Addr][2], playerx)
        if adjust
            playerx += adjust

        if ctrl.Up
            playery--
            dir := UP
        if ctrl.Down
            playery++
            dir := DOWN

        adjust := map.TestMoveY(playerx, oldy, word[player.Addr][1], word[player.Addr][2],  playery)
        if adjust
            playery += adjust
    
        count++
        if count & $3 == 0
            case (count >> 2) & $1
                0:  frame := 1
                1:  frame := 2
             '   2:  frame := 0
              '  3:  frame := 2                                                
    else
        frame := 0
        count := 0


PUB DrawPlayer
    gfx.Sprite(player.Addr,playerx-xoffset,playery-yoffset, dir*3+frame)


PUB ControlOffset | bound_x, bound_y

    bound_x := map.Width<<3 - lcd#SCREEN_W
    bound_y := map.Height<<3 - lcd#SCREEN_H
    
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
