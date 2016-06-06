CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    MAX_TURN = 13
    MAX_FORWARD = 180
    
    DIR_LEFT = 0
    DIR_STRAIGHT = 1
    DIR_RIGHT = 2
    END_TRACK = 5
    
    TILESIZE = 3
    
    #0, UP, RIGHT, DOWN, LEFT
    #0, T_DOWNRIGHT, T_DOWNLEFT, T_HORIZONTAL, T_UPRIGHT, T_UPLEFT, T_VERTICAL
    

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    txt  : "LameText"
    ctrl : "LameControl"
    
    road    : "gfx_road"
    sun     : "gfx_sun"
    tree    : "gfx_tree"
    car     : "gfx_car"
    goal    : "gfx_goal"
    minimap : "gfx_minimap"
    dot     : "gfx_dot"
    
    fnt     : "gfx_font6x6_b"

VAR
    word    buffer
    
    long    turn
    
    long    forward
    long    forward_acc
    
    long    dir
    long    dir_acc
    long    distance
    long    distance_acc
    
    long    time
    long    time_acc
    
    long    random
    
    byte    roaddir
    byte    playerdir
    
    byte    nextwaypoint
    byte    waypoint
    
    long    targetdir
    long    targetdistance
    
    long    offset_x
    long    offset_x_acc
    
    byte    showgoal

PUB Main | i
    lcd.Start(buffer := gfx.Start)
    lcd.SetFrameLimit (lcd#FULLSPEED)
    ctrl.Start
    
    txt.Load (fnt.Addr, " ", 6, 6)
    
    random := cnt
    dir_acc := 0
    
    repeat
        GameLoop
        
PUB GameLoop

    ctrl.Update

    if dir > targetdir
    
        if turn > -MAX_TURN
            turn--

        dir_acc += turn * forward
        dir := dir_acc ~> 10

        if dir < targetdir
            dir := targetdir
            dir_acc := dir << 10

    elseif dir < targetdir
    
        if turn < MAX_TURN
            turn++

        dir_acc += turn * forward
        dir := dir_acc ~> 10
        
        if dir > targetdir
            dir := targetdir
            dir_acc := dir << 10            

    else    
        dir := targetdir
        dir_acc := dir << 10

        if turn > 0
            turn--
        elseif turn < 0
            turn++

    offset_x_acc += turn * (forward^2)
    if ctrl.Left
        offset_x_acc += (1 + forward) * 800 / forward
    if ctrl.Right
        offset_x_acc -= (1 + forward) * 800 / forward
    
    
    offset_x := offset_x_acc ~> 11
                
    if ctrl.A
        if forward < MAX_FORWARD
            forward += 2
    else
        if forward > 0
            forward--
            
    if ctrl.B
        if forward > 0
            forward -= 8
        else
            forward := 0

    HandleLevel(@level1)
    HandleField
    DrawRoad(turn)
    DrawCar

    if showgoal
        DrawScaledSprite(DIR_STRAIGHT, goal.Addr, 0, 16)
            
    DrawMap(@level1)
    
    
    txt.Dec (forward, 3, 3)
    txt.Dec (waypoint, 3, 9)
    lcd.Draw

PUB DrawField(fieldcolor1, fieldcolor2, skycolor, sunframe) | i

    wordfill(buffer, skycolor, 512)
    wordfill(buffer + 1024, fieldcolor1, 512)

    repeat i from 0 to 31
        if ((forward_acc >> 6) - i + 10) >> 4 & $1
            wordfill(buffer + 1024 + i << 5, fieldcolor2, 16)

    gfx.Sprite (sun.Addr, 60 - ((dir // 360) - 180), 2, sunframe)

    wordfill(buffer + 1024, fieldcolor2, 16)

PUB HandleField | timestate

    'timestate := time >> 6 & $F
    timestate := 1
    if timestate == 0 or timestate == 8
        DrawField(0, $FFFF, $FFFF, 0)
    elseif timestate > 0 and timestate < 8
        DrawField($5555, $FFFF, $5555, 0)
    elseif timestate > 8
        DrawField(0, $FFFF, 0, 1)
    
    distance_acc += forward
    distance := distance_acc
    
    time++
    

PUB DrawRoad(turnspeed) | i, x, offset
    forward_acc += forward
    x := 0
    offset := 0
    repeat i from 0 to 31
        gfx.Sprite (road.Addr, offset_x + 32 + (offset ~> 7), 63 - i, 31 - i + ((i + (forward_acc >> 6)) >> 3 & $1)<<5)
        offset += x
        x += turnspeed

    DrawTree(DIR_RIGHT)
    DrawTree(DIR_LEFT)

PUB DrawTree(side) | treey, treeimg, i, x, offset

    if side == DIR_RIGHT
        DrawScaledSprite(side, tree.Addr, 18, 24)
    else
        DrawScaledSprite(side, tree.Addr, -18, 24)
        
PUB DrawScaledSprite(side, source, pos_x, pos_y) | i, x, y, frame, offset

    y := forward_acc >> 6 & $1F
    if y < 10
        frame := 0
    elseif y < 20
        frame := 1
    else
        frame := 2
    
    x := 0
    offset := 0
    repeat i from 63 to (y + 20)
        offset += x
        x += turn
        
    x := 64 - (gfx.Width (source) >> 1) + offset ~> 8 - turn

    if side == DIR_RIGHT
        x += y
    elseif side == DIR_LEFT
        x -= y

    gfx.Sprite (source, offset_x + pos_x + x, pos_y + y, frame)        
        
PUB DrawCar

    if ctrl.Left
        playerdir := DIR_LEFT
    elseif ctrl.Right
        playerdir := DIR_RIGHT
    else
        playerdir := DIR_STRAIGHT
        
    gfx.Sprite (car.Addr, 52, 50, playerdir)
    

PUB DrawMap(level) | addr, x, y, lastdir, c, tile, oldx, oldy
    
    lastdir := UP
    x := 20
    y := 46
    

    addr := level
    repeat until byte[addr] == END_TRACK
        c := byte[addr++]
        oldx := x
        oldy := y
    
        case c
            DIR_STRAIGHT:
                case lastdir
                    UP:     y -= TILESIZE
                            tile := T_VERTICAL
                            
                    LEFT:   x -= TILESIZE
                            tile := T_HORIZONTAL

                    DOWN:   y += TILESIZE
                            tile := T_VERTICAL

                    RIGHT:  x += TILESIZE
                            tile := T_HORIZONTAL

            DIR_LEFT:
                case lastdir
                    UP:     x -= TILESIZE
                            tile := T_DOWNLEFT
                            lastdir := LEFT
                            
                    LEFT:   y += TILESIZE
                            tile := T_DOWNRIGHT
                            lastdir := DOWN

                    DOWN:   x += TILESIZE
                            tile := T_UPRIGHT
                            lastdir := RIGHT

                    RIGHT:  y -= TILESIZE
                            tile := T_UPLEFT
                            lastdir := UP

            DIR_RIGHT:
                case lastdir
                    UP:     x += TILESIZE
                            tile := T_DOWNRIGHT
                            lastdir := RIGHT
                            
                    LEFT:   y -= TILESIZE
                            tile := T_UPRIGHT
                            lastdir := UP

                    DOWN:   x -= TILESIZE
                            tile := T_UPLEFT
                            lastdir := LEFT

                    RIGHT:   y += TILESIZE
                            tile := T_DOWNLEFT
                            lastdir := DOWN

        gfx.Sprite (minimap.Addr, oldx, oldy, tile)
        if addr - level == waypoint
            gfx.Sprite (dot.Addr, oldx-1, oldy-1, 0)

PUB HandleLevel(level) | addr, c

    addr := level + waypoint
    
    if waypoint == nextwaypoint
        nextwaypoint++

        c := byte[addr]
        case c
            DIR_LEFT:       targetdir -= 90
            DIR_RIGHT:      targetdir += 90
            DIR_STRAIGHT:   targetdistance := distance + 5000
                            
            END_TRACK:      nextwaypoint := waypoint := 0    
                            showgoal := true

    if waypoint < nextwaypoint
        c := byte[addr]
        case c
            DIR_LEFT:       if dir =< targetdir
                                waypoint++
                                showgoal := false
            DIR_RIGHT:      if dir => targetdir
                                waypoint++
                                showgoal := false
            DIR_STRAIGHT:   if distance => targetdistance
                                waypoint++
                                showgoal := false
        
DAT    
' way points

{
level1
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_LEFT

byte    END_TRACK
}


level1
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_RIGHT
byte    DIR_STRAIGHT
byte    DIR_RIGHT
byte    DIR_LEFT
byte    DIR_LEFT
byte    DIR_STRAIGHT
byte    DIR_STRAIGHT
byte    END_TRACK
