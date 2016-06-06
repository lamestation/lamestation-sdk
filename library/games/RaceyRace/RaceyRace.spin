CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
    
    MAX_TURN = 13
    MAX_FORWARD = 150
    

OBJ
    lcd  : "LameLCD"
    gfx  : "LameGFX"
    ctrl : "LameControl"
    
    road : "gfx_road"
    sun  : "gfx_sun"
    tree : "gfx_tree"

VAR
    word    buffer
    
    long    turnoffset
    long    turn
    
    long    forward
    long    forward_acc
    
    long    dir
    long    dir_acc
    
    long    time
    long    time_acc
    
    long    random

PUB Main | i
    lcd.Start(buffer := gfx.Start)
    lcd.SetFrameLimit (lcd#FULLSPEED)
    ctrl.Start
    
    random := cnt
    dir_acc := 0
    
    repeat
        GameLoop
        
PUB GameLoop
    ctrl.Update
    if ctrl.Left
        if turn > -MAX_TURN
            turn--
    if ctrl.Right
        if turn < MAX_TURN
            turn++
            
    if ctrl.A
        if forward < MAX_FORWARD
            forward++
    else
        if forward > 0
            forward--
            
    if ctrl.B
        if forward > 0
            forward -= 8
        else
            forward := 0

    HandleField
    DrawRoad(turn)
    
    lcd.Draw

PUB DrawField(fieldcolor1, fieldcolor2, skycolor, sunframe) | i

    wordfill(buffer, skycolor, 512)
    wordfill(buffer + 1024, fieldcolor1, 512)

    repeat i from 0 to 31
        if ((forward_acc >> 6) - i + 10) >> 4 & $1
            wordfill(buffer + 1024 + i << 5, fieldcolor2, 16)

    gfx.Sprite (sun.Addr, 60 - (dir - 180), 2, sunframe)

    wordfill(buffer + 1024, fieldcolor2, 16)

PUB HandleField | timestate

    timestate := time >> 6 & $F
    if timestate == 0 or timestate == 8
        DrawField(0, $FFFF, $FFFF, 0)
    elseif timestate > 0 and timestate < 8
        DrawField($5555, $FFFF, $5555, 0)
    elseif timestate > 8
        DrawField(0, $FFFF, 0, 1)
    
    dir_acc += turn * forward
    dir := dir_acc >> 10 // 360
    
    time++
    

PUB DrawRoad(turnspeed) | i, x, offset
    forward_acc += forward
    x := 0
    offset := 0
    repeat i from 0 to 31
        gfx.Sprite (road.Addr, 32 + (offset ~> 7), 63 - i, 31 - i + ((i + (forward_acc >> 6)) >> 3 & $1)<<5)
        offset += x
        x += turnspeed

    DrawTree(true)
    DrawTree(false)

PUB DrawTree(rightside) | treey, treeimg, i, x, offset

    treey := forward_acc >> 6 & $1F
    if treey < 10
        treeimg := 2
    elseif treey < 20
        treeimg := 1
    else
        treeimg := 0
    
    x := 0
    offset := 0
    repeat i from 63 to (treey + 20)
        offset += x
        x += turn

    if rightside    
        gfx.Sprite (tree.Addr, 56 + 18 + offset ~> 8 + treey - turn, 24 + treey, treeimg)
    else
        gfx.Sprite (tree.Addr, 56 - 18 + offset ~> 8 - treey - turn, 24 + treey, treeimg)