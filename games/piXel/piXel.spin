{{
KS0108 Sprite And Tile Graphics Library Demo
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}

'' Why is this necessary?
'' http://en.wikipedia.org/wiki/Flat_memory_model



CON
    _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
    _xinfreq        = 5_000_000                ' External oscillator = 5 MHz


    ' screensize constants
    SCREEN_W = 128
    SCREEN_H = 64

    ' Directional constants
    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3

    HURT_TIMEOUT = 20
    ENEMY_TIMEOUT = 5
    SHOOT_TIMEOUT = 5

    
    SONGS = 1
    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252
    
    BARRESOLUTION = 8
    MAXBARS = 18
    
    'object types
    #0, PLAYER, TANK, IBOT, IDRONE, BOSS
    
    #0, TITLE, INGAME, MENU, PAUSE, DIED, GAMEOVER, WIN, STARTLEVEL, INTRO
    


OBJ
        lcd     : "LameLCD" 
        gfx     : "LameGFX"  
        audio   : "LameAudio"
        ctrl    : "LameControl"
        fn      : "LameFunctions"
        
        gfx_player      : "gfx_player"
        gfx_ibot        : "gfx_ibot"
        gfx_idrone      : "gfx_idrone"
        gfx_tank        : "gfx_tank"    
        gfx_macrosoth   : "gfx_macrosoth"
        gfx_laser       : "gfx_laser"
        gfx_bullet      : "gfx_bullet"        
        gfx_head        : "gfx_head"
        gfx_boom        : "gfx_boom"
        gfx_healthbar   : "gfx_healthbar"
        gfx_starmap     : "gfx_starmap"
        gfx_pixmain     : "gfx_pixmain"
        
        font_chars_cropped : "font_chars_cropped"


VAR

    word    buffer[1024]
                    
    byte    gamestate
    byte    clicked

PUB Main

    dira~
        
    dira[24]~~
        
    gfx.Start(@buffer, lcd.Start) 
    gfx.LoadFont(font_chars_cropped.Addr, " ", 8, 8)

    audio.Start
    ctrl.Start

    InitGraphicAssets

    InitGame
    InitLevel
    
    audio.SetWaveform(1, 127)
    audio.SetADSR(127, 10, 100, 10)
    audio.LoadSong(@pixel_theme)
    audio.LoopSong

    
    gamestate := TITLE
    clicked := 0
    repeat
        case gamestate
            TITLE:      TitleScreen
            INTRO:      GameIntro
                        gamestate := STARTLEVEL
            STARTLEVEL: InitLevel                
                        audio.StopSong                        
                        gamestate := INGAME
            INGAME:     GameLoop
            DIED:       PlayerDied
                        gamestate := STARTLEVEL
            WIN:        Victory
                        gamestate := TITLE
            GAMEOVER:   ItsGameOver
                        InitGame
                        gamestate := STARTLEVEL

PUB TitleScreen
    ctrl.Update
    gfx.ClearScreen


    gfx.PutString(string("p  i      e  l"), 8, 30)
    gfx.Sprite(gfx_pixmain.Addr, 40, 8, 0)        
    gfx.PutString(string("press A/B"), 28, 56)

    if ctrl.A or ctrl.B
        if not clicked
            gamestate := INTRO
            clicked := 1
        else
            clicked := 0
    gfx.DrawScreen

PUB GameLoop
            ctrl.Update
            gfx.Blit(gfx_starmap.Addr)
            HandlePlayer                        
            ControlOffset
            gfx.DrawMap(xoffset, yoffset, 0,0, 16, 8)
            DrawPlayer
            HandleBullets
            HandleEnemies
            HandleEffects
            HandleStatusBar
            gfx.DrawScreen
            
PUB Victory
            audio.StopAllSound
            audio.StopSong
            audio.SetWaveform(1, 127)
            audio.SetADSR(127, 10, 100, 10)
            audio.LoadSong(@song_yeah)
            audio.LoopSong

            ShowGameView
            gfx.TextBox(string("YOU WIN"), 40, 30, 100, 60)
            gfx.DrawScreen
            fn.Sleep(200000)

            audio.StopAllSound
            audio.SetWaveform(1, 127)
            audio.SetADSR(127, 10, 100, 10)
            audio.LoadSong(@pixel_theme)
            audio.LoopSong            
            StarWarsReel(string("Looks like",10,"the galaxy",10,"is safe once",10,"again, thanks",10,"to you!"),110)


    
PUB ShowGameView
            gfx.Blit(gfx_starmap.Addr)
            HandlePlayer                        
            ControlOffset
            gfx.DrawMap(xoffset, yoffset, 0,0, 16, 8)
            HandleBullets
            HandleEnemies
            HandleStatusBar

PUB PlayerDied
            playerlives--
            
            audio.StopAllSound
            audio.SetWaveform(1, 127)
            audio.SetADSR(127, 10, 100, 10)
            audio.LoadSong(@song_ohnooo)
            audio.PlaySong         
            
            ShowGameView
            gfx.TextBox(string("Macrosoth",10,"lives yet..."), 20, 20, 100, 60)
            gfx.DrawScreen
            fn.Sleep(200000)

PUB StarWarsReel(text,reeltime) | x, choice
    x := 0
    choice := 0
        
    repeat while x < reeltime and not choice
        ctrl.Update
        if ctrl.A or ctrl.B
            if not clicked
                choice := 1
                clicked := 1
        else
            clicked := 0
        playerx := 55 << 3
        playery := 5 << 3
        pos_dir := LEFT

         
        ControlOffset
        gfx.Blit(gfx_starmap.Addr)
        gfx.DrawMap(xoffset, yoffset, 0,0, 16, 8)
        DrawPlayer

        
        gfx.TextBox(text, 16, 64-x, 108, 64) 
    
        gfx.DrawScreen
        fn.Sleep(13000)
        x++

PUB ItsGameOver
            audio.StopAllSound
            audio.SetWaveform(1, 127)
            audio.SetADSR(127, 10, 100, 10)
            audio.LoadSong(@song_superohnooo)
            audio.PlaySong     

            ShowGameView
            gfx.TextBox(string("GAME OVER"), 30, 28, 100, 60)
            gfx.DrawScreen
            fn.Sleep(300000)
            
            jumping := 0
            crouching := 1
            pos_frame := 4

            audio.StopSong   
            audio.SetWaveform(3, 127)
            audio.SetADSR(127, 3, 0, 3)
            audio.LoadSong(@song_sad)
            audio.LoopSong    
    
            StarWarsReel(string("There was",10,"nothing you",10,"could do to",10,"stop him..."),100)
        
            gfx.Blit(gfx_starmap.Addr)
            gfx.DrawMap(xoffset, yoffset, 0,0, 16, 8)
            DrawPlayer            
            gfx.PutString(string("Press A and "),18,24)
            gfx.PutString(string("try again..."),18,32)
            gfx.DrawScreen
            
            repeat until ctrl.A
                ctrl.Update

PUB GameIntro
    jumping := 0
    crouching := 0
    pos_frame := 0
    
    audio.StopSong   
    audio.SetWaveform(3, 127)
    audio.SetADSR(127, 3, 0, 3)
    audio.LoadSong(@song_sad)
    audio.LoopSong    

    StarWarsReel(string("You have",10,"escaped",10,"the evil",10,"experiments",10,"of the one",10,"they call",10,"Macrosoth.",10,10,"Now you must",10,"defeat him",10,"once and for",10,"all..",10,10,"Before it's",10,"too late..."),200)


' *********************************************************
'  Levels
' *********************************************************  
CON
    LEVELS = 1

VAR
    word    leveldata[LEVELS]
    byte    currentlevel
    word    tilemap

    long    xoffset
    long    yoffset
    
    byte    playerlives 
    
PUB InitGame
    playerlives := STARTING_LIVES

PUB InitLevel

    tilemap := @gfx_tiles_2b_tuxor
    leveldata[0] := @map_supersidescroll

    ControlOffset
    InitPlayer
    InitBullets
    InitEnemies
    InitEffects
        
    gfx.LoadMap(tilemap, leveldata[currentlevel])
    ReadObjects(@objects)

            
' *********************************************************
'  Player
' *********************************************************
CON
    
    SPEED = 4
    STARTING_HEALTH = 5
    STARTING_LIVES = 3
VAR
    long    playerx
    long    playery
    long    pos_oldx
    long    pos_oldy

    byte    pos_dir
    long    pos_speed
    long    pos_speedx
    byte    pos_frame
    word    pos_count
    
    byte    jumping
    byte    crouching
    
    byte    playerhealth
    byte    playerhealth_timeout
    byte    playershoot_timeout

PUB InitPlayer
    pos_dir := RIGHT
    playerhealth := STARTING_HEALTH
    playerhealth_timeout := 0

PUB HandlePlayer
    pos_oldx := playerx
    pos_oldy := playery    
            
    if jumping
        pos_frame := 3
        crouching := 0
    else
        if ctrl.Down
            crouching := 1
        else
            crouching := 0
            
    if not crouching
        if ctrl.Left or ctrl.Right
    
            if ctrl.Left
                playerx -= SPEED
                pos_dir := LEFT
            if ctrl.Right
                playerx += SPEED
                pos_dir := RIGHT
    
            pos_count++
            if pos_count & $1 == 0
                case (pos_count >> 1) & $3  ' Test the frame
                    0:  pos_frame := 0
                    1:  pos_frame := 1
                    2:  pos_frame := 0
                    3:  pos_frame := 2                                                
        else
            pos_frame := 0
            pos_count := 0            
    else
        pos_frame := 4            

    if jumping
        pos_frame := 3

    if gfx.TestMapCollision(playerx, playery, word[gfx_player.Addr][1], word[gfx_player.Addr][2])
        playerx := pos_oldx

    if ctrl.A
        if not jumping               
            pos_speed := -9
            jumping := 1                 

    if ctrl.B
        if not playershoot_timeout
            playershoot_timeout := SHOOT_TIMEOUT
            
            if crouching
                if pos_dir == LEFT
                    SpawnBullet(playerx, playery+7, LEFT)
                if pos_dir == RIGHT
                    SpawnBullet(playerx, playery+7, RIGHT)    
            else
                if pos_dir == LEFT
                    SpawnBullet(playerx, playery+2, LEFT)
                if pos_dir == RIGHT
                    SpawnBullet(playerx, playery+2, RIGHT)    
        else
            playershoot_timeout--
    else
        playershoot_timeout := 0
                
    pos_speed += 1
    playery += pos_speed

    if gfx.TestMapCollision(playerx, playery, word[gfx_player.Addr][1], word[gfx_player.Addr][2])
        if  pos_speed > 0
            jumping := 0
        playery := pos_oldy
        pos_speed := 0
    
    if pos_speed > 0
        jumping := 1
        
    if playery > (gfx.GetMapHeight << 3)
        KillPlayer
                
    if playerhealth_timeout > 0
        playerhealth_timeout--
        

PUB DrawPlayer
    if not playerhealth_timeout or (playerhealth_timeout & $2)
        if pos_dir == LEFT
            gfx.Sprite(gfx_player.Addr,playerx-xoffset,playery-yoffset, 5+pos_frame)
        if pos_dir == RIGHT
            gfx.Sprite(gfx_player.Addr,playerx-xoffset,playery-yoffset, pos_frame)

PUB KillPlayer
    if playerlives > 1
        gamestate := DIED
    else
        gamestate := GAMEOVER
        
PUB HitPlayer
    if playerhealth_timeout == 0
        playerhealth--
        if not playerhealth > 0
            KillPlayer
        playerhealth_timeout := HURT_TIMEOUT


PUB HandleStatusBar | x

    repeat x from 0 to (playerlives-1)
        gfx.Sprite(gfx_head.Addr, x<<3, 56, 0)
        
    repeat x from 0 to (playerhealth-1)
        gfx.Sprite(gfx_healthbar.Addr, 124-x<<2, 56, 0)        



' *********************************************************
'  Effects
' *********************************************************
CON 
    EFFECTS = 6
    #1, EXPLOSION
  
VAR
    word    effect
    long    effectx[EFFECTS]
    long    effecty[EFFECTS]
    byte    effecton[EFFECTS]
    byte    effectframe[EFFECTS]
    word    effecttime[EFFECTS]

PUB InitEffects | index
    effect := 0
    repeat index from 0 to constant(EFFECTS-1)
        effecton[index] := 0 
        effectx[index] := 0
        effecty[index] := 0
        effectframe[index] := 0
        effecttime[index] := 0
    

PUB SpawnEffect(x, y, type)

    effecton[effect] := type
    effectx[effect] := x
    effecty[effect] := y
    effectframe[effect] := 0
    effecttime[effect] := 0
                                
    effect++
    if effect > constant(EFFECTS-1)
        effect := 0
        
    audio.SetWaveform(4, 127)
    audio.SetADSR(127, 10, 0, 70)
    audio.PlaySound(2,40)

PUB HandleEffects | effectxtemp, effectytemp, index

    repeat index from 0 to constant(EFFECTS-1)
        if effecton[index]
        
            effecttime[index]++
            if effecttime[index] > 4
                effecttime[index] := 0
                effectframe[index]++
                
            if effectframe[index] > 2
                effecton[index] := 0
            else
                effectxtemp := effectx[index] - xoffset
                effectytemp := effecty[index] - yoffset
      
                if (effectxtemp => 0) and (effectxtemp =< SCREEN_W-1) and (effectytemp => 0) and (effectytemp =< SCREEN_H - 1)          
                    gfx.Sprite(gfx_boom.Addr, effectxtemp , effectytemp, effectframe[index])
                else
                    effecton[index] := 0


' *********************************************************
'  Objects
' *********************************************************
VAR
    word    objectgraphics[8]
    word    objecthealth[8]
    
PUB InitGraphicAssets
    objectgraphics[PLAYER] := gfx_player.Addr
    objectgraphics[TANK] := gfx_tank.Addr
    objectgraphics[IBOT] := gfx_ibot.Addr
    objectgraphics[IDRONE] := gfx_idrone.Addr
    objectgraphics[BOSS] := gfx_macrosoth.Addr
    
    objecthealth[TANK]   := 3
    objecthealth[IBOT]   := 1
    objecthealth[IDRONE] := 2
    objecthealth[BOSS]   := 10
    


PUB ReadObjects(objectaddr) | objcount, object, objtype, objx, objy
    objcount := byte[objectaddr][0]
    objectaddr += 2
    
    repeat object from 0 to objcount-1    
        objx := byte[objectaddr][0] << 3
        objy := byte[objectaddr][1] << 3

        objtype := byte[objectaddr][2]

        case objtype
            PLAYER:     playerx := objx
                        playery := objy
            TANK, IBOT, IDRONE:  SpawnEnemy(objx, objy, objtype, LEFT)
            BOSS:       SpawnEnemy(objx, objy, objtype, LEFT)
            
        objectaddr += 3


PUB GetObjectWidth(type)
    return word[objectgraphics[type]][1]
    
PUB GetObjectHeight(type)
    return word[objectgraphics[type]][2]    


 
' *********************************************************
'  Bullets
' *********************************************************
CON 
    BULLETS = 10
    BULLETINGSPEED = 15
  
VAR
    word    bullet
    long    bulletx[BULLETS]
    long    bullety[BULLETS]
    byte    bulletdir[BULLETS]
    byte    bulleton[BULLETS]
    word    bulletindex

PUB InitBullets
    bullet := 0
    repeat bulletindex from 0 to constant(BULLETS-1)
        bulleton[bulletindex] := 0 
        bulletx[bulletindex] := 0
        bullety[bulletindex] := 0
        bulletdir[bulletindex] := 0
    

PUB SpawnBullet(x, y, dir)

    bulleton[bullet] := 1 
    bulletdir[bullet] := dir
    
    bulletx[bullet] := x
    bullety[bullet] := y
                                
    bullet++
    if bullet > constant(BULLETS-1)
        bullet := 0

    audio.SetWaveform(1, 127)
    audio.SetADSR(127, 50, 0, 50)
    audio.PlaySound(2,50)        

PUB HandleBullets | bulletxtemp, bulletytemp

    repeat bulletindex from 0 to constant(BULLETS-1)
        if bulleton[bulletindex]

          if bulletdir[bulletindex] == LEFT
             bulletx[bulletindex] -= BULLETINGSPEED
          
          elseif bulletdir[bulletindex] == RIGHT
             bulletx[bulletindex] += BULLETINGSPEED   
          
          elseif bulletdir[bulletindex] == UP
             bullety[bulletindex] -= BULLETINGSPEED    
          
          elseif bulletdir[bulletindex] == DOWN
             bullety[bulletindex] += BULLETINGSPEED  

          bulletxtemp := bulletx[bulletindex] - xoffset
          bulletytemp := bullety[bulletindex] - yoffset

          if (bulletxtemp => 0) and (bulletxtemp =< SCREEN_W-1) and (bulletytemp => 0) and (bulletytemp =< SCREEN_H - 1)
              if fn.TestBoxCollision(bulletx[bulletindex], bullety[bulletindex]+4, 8, 1, playerx, playery, word[gfx_player.Addr][1], word[gfx_player.Addr][2])
                  HitPlayer
                  bulleton[bulletindex] := 0
              else
                  gfx.Sprite(gfx_laser.Addr, bulletxtemp , bulletytemp, 0)
          else
              bulleton[bulletindex] := 0
              
          



' *********************************************************
'  Enemies
' *********************************************************
CON
    ENEMIES = 16
    ENEMYTYPES = 2

VAR           
    byte    enemyindex
    byte    enemycount
    byte    nextenemy
    byte    enemyon[ENEMIES]
    
    long    enemyx[ENEMIES]
    long    enemyy[ENEMIES]
    long    enemyspeedx[ENEMIES]
    long    enemyspeedy[ENEMIES]
    byte    enemyframe[ENEMIES]
    
    long    enemydir[ENEMIES]
    long    enemytmp1[ENEMIES]
        
    byte    enemyhealth[ENEMIES]
    byte    enemytimeout[ENEMIES]
    byte    bossspawned


PUB InitEnemies

    enemycount := 0
    
    repeat enemyindex from 0 to constant(ENEMIES-1)
        enemyon[enemyindex] := 0
        enemyx[enemyindex] := 0
        enemyy[enemyindex] := 0
        enemydir[enemyindex] := RIGHT
        enemyframe[enemyindex] := 0
        enemyhealth[enemyindex] := 0
        enemytimeout[enemyindex] := 0
        
                
PUB HandleEnemies

    repeat enemyindex from 0 to constant(ENEMIES-1)
        if enemyon[enemyindex]
            if enemyx[enemyindex] + GetObjectWidth(enemyon[enemyindex]) - xoffset > 0 and enemyx[enemyindex] - xoffset < SCREEN_W and enemyy[enemyindex] + GetObjectHeight(enemyon[enemyindex]) - yoffset > 0 and enemyy[enemyindex] - yoffset < SCREEN_H
                case enemyon[enemyindex]
                    TANK: EnemyTank(enemyindex)
                    IBOT:  EnemyEye(enemyindex)
                    IDRONE:  EnemyEye(enemyindex)
                    BOSS:  EnemyBoss(enemyindex)    
            
                if not enemytimeout[enemyindex] or (enemytimeout[enemyindex] & $1)
                    DrawObject(enemyindex, enemyon[enemyindex], enemyframe[enemyindex])
                if enemytimeout[enemyindex]
                    enemytimeout[enemyindex]--
                CheckEnemyCollision(enemyindex)
            
PUB EnemyTank(index) | dx, dy
    pos_oldx := enemyx[index]
    pos_oldy := enemyy[index]
    
    dx := playerx - enemyx[index]
    dy := playery - enemyy[index]
    
    if dx > 0
        enemydir[index] := RIGHT
    else
        enemydir[index] := LEFT
    
    if ||dx < 32 and ||(dy + 8) < 16
        
            enemytmp1[index]++
        
            if enemytmp1[index] > 20
                enemytmp1[index] := 0
                if enemydir[index] == LEFT
                    SpawnBullet(enemyx[index]-8, enemyy[index]+5, LEFT)
                if enemydir[index] == RIGHT
                    SpawnBullet(enemyx[index] + 16, enemyy[index]+5, RIGHT)
    else
        if dx > 0
            enemyx[index] += 1
        else
            enemyx[index] -= 1

    if gfx.TestMapCollision(enemyx[index], enemyy[index], 16, 16)
        enemyx[index] := pos_oldx
        enemyspeedx[index] := -enemyspeedx[index]
    
    enemyspeedy[index] += 1
    enemyy[index] += enemyspeedy[index]

    if gfx.TestMapCollision(enemyx[index], enemyy[index], 16, 16)
        enemyy[index] := pos_oldy
        enemyspeedy[index] := 0
    
    if enemydir[index] == LEFT
        enemyframe[index] := 0
    else
        enemyframe[index] := 1




PUB EnemyEye(index) | dx, dy
    dx := playerx - enemyx[index]
    dy := playery - enemyy[index]
    
    if dx > 0
        enemyx[index]++
    elseif dx < 0
        enemyx[index]--
        
    if dy > 0
        enemyy[index]++
    elseif dy < 0
        enemyy[index]--

    enemyframe[index] := 0



PUB EnemyBoss(index) | dx, dy
    dx := playerx - enemyx[index]
    dy := playery - enemyy[index]

    if not bossspawned
        bossspawned := 1
    
        audio.SetWaveform(1, 127)
        audio.SetADSR(127, 10, 100, 10)
        audio.LoadSong(@song_boss)
        audio.LoopSong    


    enemyframe[index] := 0





    
PUB DrawObject(index, type, frame) | tmpx, tmpy
    tmpx := enemyx[index] - xoffset
    tmpy := enemyy[index] - yoffset
    gfx.Sprite(objectgraphics[type], tmpx, tmpy, frame)


PUB SpawnEnemy(dx, dy, type, dir)
    if enemycount < constant(ENEMIES-1)
        enemyon[nextenemy] := type
        enemyx[nextenemy] := dx
        enemyy[nextenemy] := dy
        enemyhealth[nextenemy] := objecthealth[type]
        
        nextenemy++
        if nextenemy => ENEMIES
            nextenemy := 0
            
        enemycount++


PUB CheckEnemyCollision(index) | x, y, boom, ran
    repeat bulletindex from 0 to constant(BULLETS-1)
      if bulleton[bulletindex]
    
        if fn.TestBoxCollision(bulletx[bulletindex], bullety[bulletindex]+4, 8, 1, enemyx[index], enemyy[index], GetObjectWidth(enemyon[index]), GetObjectHeight(enemyon[index]))
            if enemyhealth[index] > 1
                enemyhealth[index]--
                enemytimeout[index] := ENEMY_TIMEOUT
            else
            
                repeat y from 0 to (GetObjectHeight(enemyon[index])>>3)-1
                    repeat x from 0 to (GetObjectWidth(enemyon[index])>>3)-1
                        SpawnEffect(enemyx[index]+(x<<3), enemyy[index]+(y<<3), EXPLOSION)
                        
                if enemyon[index] == BOSS
                    gamestate := WIN

                enemyon[index] := 0
            bulleton[bulletindex] := 0
                
    if fn.TestBoxCollision(playerx, playery, GetObjectWidth(PLAYER), GetObjectHeight(PLAYER), enemyx[index], enemyy[index], GetObjectWidth(enemyon[index]), GetObjectHeight(enemyon[index]))
        HitPlayer


PUB ControlOffset | bound_x, bound_y

    bound_x := gfx.GetMapWidth << 3 - SCREEN_W
    bound_y := gfx.GetMapHeight << 3 - SCREEN_H
    
    xoffset := playerx + (word[gfx_player.Addr][1]>>1) - (SCREEN_W>>1)
    if xoffset < 0
        xoffset := 0      
    elseif xoffset > bound_x
        xoffset := bound_x
        
        
    yoffset := playery + (word[gfx_player.Addr][2]>>1) - (SCREEN_H>>1)
    if yoffset < 0
        yoffset := 0      
    elseif yoffset > bound_y
        yoffset := bound_y


DAT


gfx_tiles_2b_tuxor

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $3333, $cccc, $3333, $cccc, $3333, $cccc, $3333, $cccc
word    $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $dddd, $7777, $dddd, $7777, $dddd, $7777, $dddd, $7777
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $3033, $0f30, $30cc, $f3c3, $3cf0, $f3cc, $3033, $030c
word    $df77, $5555, $d75d, $d5dd, $f7f5, $7f4f, $f4f3, $330c, $3033, $0f30, $30cc, $c303, $0030, $cc00, $000c, $0000
word    $557c, $ddf3, $77cc, $dff0, $d5cc, $77f0, $d7c0, $0f00, $5555, $7777, $4444, $cccc, $cccc, $cccc, $0000, $0f00
word    $d57f, $4c31, $700d, $4001, $4003, $c003, $c003, $c003, $55ff, $fff5, $0c05, $030d, $00c7, $003f, $0007, $0007
word    $f555, $5fff, $5030, $70c0, $f300, $7c00, $7000, $f000, $000f, $0007, $0005, $0007, $0004, $000f, $0004, $000c
word    $7000, $f000, $7000, $4000, $7000, $f000, $4000, $4000, $5555, $5555, $5555, $5555, $7575, $7575, $f1f1, $d1d1
word    $0000, $0000, $0000, $0000, $3030, $1010, $d0d0, $d0d0, $4001, $1554, $0054, $1454, $0054, $1554, $0054, $4001
word    $c003, $300c, $cc33, $c043, $c103, $cc33, $300c, $cd73, $fff3, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3
word    $fff3, $fcf3, $ffcf, $ff3f, $3cff, $f3ff, $cfff, $3fff, $fffc, $fcf3, $ffcf, $ff3f, $3cff, $f3ff, $cfff, $3fff
word    $fffc, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3, $fff3, $ff33, $fff3, $fff3
word    $ffff, $0fff, $f3ff, $fcff, $cf3f, $ffcf, $fff3, $ff33, $3fff, $cfff, $f3ff, $fcff, $cf3f, $ffcf, $fff3, $ff3c
word    $ffff, $0000, $ffff, $cfcf, $ffff, $ffff, $ffff, $ffff, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa

mapTable_tiles_2b_tuxor
word    @map_supersidescroll


map_supersidescroll
byte     96,  48  'width, height
byte      0,  0,  0,  0,134,134,134,134,134,134,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,  0,  0,134,134,134,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,  0,134,134,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,134,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    134,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,138,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135, 19,135,135,135,135,135,135,135, 19,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,138,138,138,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,135,134,134,134, 19,134,134,134,134,134,134,134, 19,135,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12, 13, 19, 12, 13, 19, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,135,135,135,134,134,134,134,134,136,136,136,136,136,136,136,136,136,136,134, 19,134,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,134,134,134,134,134,134,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136, 19,134,135,135,  0,  0,  0,  0,  0,  0,  0,  0,138,138,138,  0,  0,  0, 19,  0,  0,138,138,  0,  0,  0,138,138,  0,  0,  0,138,138,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,134,134,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,134,135,135,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,134,  0,  0,  0,  0,136,135,135,135,134,134,134,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,134,135,135,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,134,  0,  0,  0,  0,  0,136,136,135,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,135,135,  0,  0,  0,  0,  0,  0, 19,  0,  0, 17, 17, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 19, 17, 17, 19, 17, 17, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17
byte    136,134,  0,  0,  0,  0,  0,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,136,136,134,134,136,134,136,135,135,135,  0,  0,  0,  0, 19,135,135,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,  0,  0,  0,  0,  0,  0,136,136,136,136,136,  2,  2,136,136,136,136,136,136,136,136,136,136,136,136,134,136,136,136,134,134,134,135,135,135,135,135,135, 19,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,  2,  2,  2,  2,  2,  2,  2,  2,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,134,134,134,134,134,134,134, 19,136,134,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  3,  3,  3,  3,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  3,  2,  2,  2,136,136,136,136,136,136,136,136,136, 19,136,136,136,136,136,136,136,  0,  0,  0,136,136,136,136,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
byte    134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  2,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  2,  3,  3,  3,  2,  2,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136
byte    136,136,134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte    136,136,136,134,134,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,136,136,136,136,135,134,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
byte      0,  0,  0,136,136,136,136,134,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,135,135,135,135,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,136,136,136,134,134,  0,  0,  0,  0,  0,  0,  0,  2,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,135,135,134,134,135,135,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,136,136,136,136,134,134,  0,  0,  0,  2,  0,  2,  2,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,135,135,135,134,134,134,134,135,  2,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,  0,  0,136,136,136,134,135,  0,  2,  2,  2,  2,  2,  2,  3,  3,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,134,134,134,134,136,136,134,134,135,  2,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,  0,  0,  0,  0,136,136,136,134,  2,  3,  3,  3,  2,  2,  3,  3,  3,  2,  2,  2,  2,  0,  0,  0,  0,135,135,135,135,134,134,134,136,136,136,136,136,136,134,135,  2,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,135,135,135,137,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte      0,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,134,135,  3,  3,  2,  2,  2,  3,  3,  3,135,135,135,135,135,135,135,135,134,134,134,136,136,136,  0,  0,  0,  0,  0,136,136,135,135,  2,  2,  2,  4,  0,  0,  0,  0,  0,  0,  0,135,135,135,135,135,134,134,134,134,134,135,137,137,  0,137,  0,  0,  0,  0,137,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte    136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,134,135,135,  2,  2,  3,  3,  3,134,134,134,134,134,134,134,134,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,134,135,135,135,135,  2,  0,  0,  0,  0,  0,  0,135,135,135,134,134,134,134,134,134,134,134,135,135,135,137,137,  0,  0,  0,  0,137,137,  0,  0,  0,  0,  0,137,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte    136,136,136,136,136,134,134,134,  0,  0,134,134,134,136,136,134,135,135,135,135,135,135,136,136,136,136,136,136,136,136,  0,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,134,134,134,135,  2,  0,  0,  0,  0,  0,134,134,134,134,134,134,134,134,134,134,134,134,134,135,135,135,135,137,  0,  0,  0,137,137,137,  0,  0,  0,137,135,  0,137,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0
byte    136,136,136,136,136,136,136,136,136,134,134,134,134,134,136,136,136,136,136,136,136,136,136,134,136,136,  0,  0,  0, 19,  0,  0,  0,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,134,  2,  0,  0,  0,  0,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,135,135,135,135,135,135,135,135,135,135,135,138,138,138,138,138,138,138,138,138,138,  0,  0,  0,  0, 19,  0,  2
byte      3,  3,136,136,136,136,  0,  0,136,136,136,136,134,134,134,134,134,134,134,134,134,134,134,134,  0,  0,  0,  0,  0, 19,  0,  0,  0,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,  2,  0,  0,  0,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,134,135,135,134,134,134,134,134,134, 19,134, 19, 19,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  2
byte      3,  3,  3,  3,  0,  0,  0,  3,  3,  3,136,136,136,134,134,134,136,136,134,134,134,134,136,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,  2,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,134,134,134,134,134,134,134,134,134,136,136,136,136,136,136, 19,  3,  4, 19,  0,  0,  0,  0,  0,  0, 19,  0,  2
byte      3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0,136,136,136,136,136,136,136,136,136,136,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,136,  3,  3,  3,  3,  3,  3,  3,  4,  4,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  3,  3,  3,  3,  3,134,134,134,134,134,134,134,136,136,136,136,136,136,136,136,136,  3,  4, 19,  2,  3,  0,  0,  0,  0, 19,  2,  3
byte      2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,  3,  4,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,134,134,134,134,134,134,136,136,136,  3,  3,136,136,134,136,136,  3,  4, 19,  2,  3,  3,  0,  0,138,138,138,138
byte      2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  3,  4,  2,  0,  0,  0,  0,  0,  3,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  3,  3,  3,134,134,134,134,136,136,136,  3,  3,  3,  3,  3,136,136,134,136,  3,  4, 19,  2,  3,  3,  3,  0,  0, 19,  2,  3
byte      0,  2,  2,  3,  3,  3,  3,  3,  3,  3,  3,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  3,  3,  3,  3,135,134,134,136,136,136,  3,  3,  3,  3,  3,  3, 20,136,134,134,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  2,  2,  3,  3,  3,  3,  3,  3,  3,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,138,138,  0,  0,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  2,  2,  0,  0,  0,  0,  2,  2,  3,  4,  0,  0,  0,135,135,135,135,135,135,135,135,135,135,135,134,134,136,136,136,  3,  3,  3,  3,  3,  3,  0, 20,136,134,134,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  2,  3,  3,  3,  3,  3,  3,  3,  3,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  0,  0,  0,  0,  0,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,134,134,134,134,134,134,134,134,134,136,136,136,  3,  3,  3,  3,  3,  3,  0,  0, 20,136,136,134,138,138,138,138,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  0,  2,  3,  3,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,138,138,  0,  0,  0,  0,  0,  0,  0,  0,134,134,134,134,136,136,136,136,136,  3,  3,  3,  3,  3,  3,  3,  0,  0, 20, 20,136,136,136,136, 19,136,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  0,  2,  3,  3,  4,  3,  3,  3,  3,  3, 19, 12,  0,  0,  0,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,  2,  2,  2,  3,  3,  2,  3,  3,  3,  3,  2,  0,  0,  0, 20, 24,136,136,136,136, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  0,  2,  2,  2,  3,  4,  4,  4,  3,  3,  3, 19,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0,  0,  4,  4,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  2,  3,  2,  2,  3,  3,  3,  2,  2,  0,  0,  0, 20, 24,  3,136,136,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      0,  0,  2,  2,  2,  3,  3,  3,  3,  4,  4,  3,  3, 19,  3,  2,  2,  2,  0,  0,  0,  0,  0,  0,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  3,  4,  4,  4,  5,  5,  5,  5,  5,  5,  0,  0,  0,  2,  3,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  3,  3,  2,  2,  3,  3,  3,  2,  0,  0,  0,  0, 21, 24,  3,  3,  3,  4, 19,  2,  3,  3,  3,138,138,138,138,138
byte      0,  2,  2,  2,  3,  3,  3,  3,  3,  3,  4,  3,  3, 19,  3,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0,  0, 13, 19, 12,  0,  0,  0,  0,  0,  0,  2,  3,  3,  4,  4,  4,  4,  4,  4,  5,  5,  0,  0,  2,  2,  3,  3,  3,  4,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,  2,  2,  2,  3,  3,  2,  2,  0,  0,  0,  2, 20, 23,  3,  3,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte      2,  2,  2,  3,  3,  3,  3,  3,  3,  3,  4,  3,  3, 19,  3,  4,  4,  3,  3,  2,  2,  0,  0,  0,  0,  0,  0,  0,  0, 19,  0,  0,138,  0,138,  0,138,138,138,138,138,138,138,138,138,138,138,138,  0,  0,138,138,138,138,138,138,138,138,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  2,  2,  3,  3,  3,  3,  2,  0,  0,  0,  2,  2, 20, 24,  3,  3,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte    137,137,137,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3, 19,  4,  4,  4,  3,  3,  3,  2,138,138,138,137,  0,  0,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  2, 19,  2,  2, 19,  2,  2, 19,  2,  0,  0,  0,  0,  2, 19,  2,  2, 19,134,134,138,138,138,138,138,138,138,138,138,138,135,135,  3,  3,  3,  2,  2,  0,  0,  2,  3,  3, 20, 24,  3,  3,  3,  4, 19,  2,  3,  3,  3,  3,  4, 19,  2,  3
byte    137,137,137,137,137,137,137,137,137,137,137,137,  3, 19,  4,  4,  4,  4,  3,  3,  3, 19,  0,  0,137,137,137,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  2,  2, 19,  2,  2, 19,  2,137,  0,  0,  0,  2, 19,  2,  3, 19,136,136,137,136,  0,  0,  0,136,136,136,  0,136,138,138,138,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,135,  3,  3,  3,  3,135,135,135,135
byte    137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,137,  0,  0, 19,  0,  0,  0,  0,  0,  0, 19,  0,  0, 19,  0,  0, 19,  2,  0, 19,  0,137,  0,  0,137,  0, 19,  2,  2, 19,  0,137,136,  0,  0,  0,  0,  0,  0,  0,  0,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,134, 17, 17, 17, 17,134,136,136,136

objects
byte        15, 0
byte        16, 44, TANK
byte        43, 41, TANK
byte        77, 43, IBOT
byte        87, 27, IDRONE
byte        63, 22, IBOT
byte        34, 3, TANK
byte        17, 23, IDRONE
byte        27, 19, IBOT
byte        28, 33, IBOT
byte        61, 42, TANK
byte        15, 5, TANK
byte        75, 2, IDRONE
byte        64, 5, IDRONE
byte        88, 2, BOSS
byte        6, 43, PLAYER




song_yeah
byte    2
byte    50
byte    13

byte    0, 27, 27, 27, 29, 29, 29, 31, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF
byte    1, 34, 34, 34, 36, 36, 36, 35, SNOP, SNOP, SNOP, SNOP, SNOP, SOFF

byte    0,1,BAROFF
byte    SONGOFF


song_ohnooo
byte    2
byte    50
byte    7

byte    0, 30, 29, 28, 27, SNOP, SNOP, SOFF
byte    1, 18, 17, 16, 15, SNOP, SNOP, SOFF

byte    0,1,BAROFF
byte    SONGOFF


song_superohnooo
byte    2
byte    100
byte    7

byte    0, 27, 26, 25, 24, SNOP, SNOP, SOFF
byte    1, 15, 14, 13, 12, SNOP, SNOP, SOFF

byte    0,1,BAROFF
byte    SONGOFF

song_boss
byte    2
byte    60
byte    8

byte    0, 26,26,26,SNOP,SNOP,SNOP,27,26
byte    0, 27,26,27,26,SNOP,26,27,SNOP

byte    0,BAROFF
byte    1,BAROFF
byte    SONGOFF


song_sad
byte    14
byte    140
byte    8
'low part
byte    0, 32,  39, 42, 46, 32, 39, 42, 46
byte    0, 28,  35, 37, 42, 28, 35, 37, 42
byte    0, 25,  32, 37, 40, 25, 32, 37, 40
byte    0, 22,  29, 34, 38, 22, 29, 34, 38
byte    0, 27,SNOP, 27, 29, 30, 27, 30, 34 ' do do dooo do doo
'high part
byte    1,   59,SNOP,  59,  58, 58, SNOP, SNOP, SNOP
byte    1, SNOP,  59,  59,  58, 58,   54,   54,   51
byte    1,   54,SNOP,SNOP,  52, 52, SNOP, SNOP, SNOP
byte    1, SNOP,  54,  54,  52, 52,   51,   51,   54
byte    1,   54,SNOP,SNOP,  52, 52, SNOP, SNOP, SNOP
byte    1, SNOP,  54,  54,  51, 51,   47,   47,   51
byte    1,   51,SNOP,SNOP,  50, 50, SNOP, SNOP, SNOP
byte    1, SNOP,SNOP,  51,  53, 54,   51,   54,   58
byte    1,   58,SNOP,SNOP,  56, 56, SNOP, SNOP, SNOP

byte    0,5,BAROFF
byte    0,6,BAROFF
byte    1,7,BAROFF
byte    1,8,BAROFF
byte    2,9,BAROFF
byte    2,10,BAROFF
byte    3,11,BAROFF
byte    4,12,BAROFF
byte    0,13,BAROFF
byte    0,BAROFF

byte    SONGOFF

pixel_theme
byte    14     'number of bars
byte    40     'tempo
byte    8      'bar resolution

'MAIN SECTION
byte    0, 26,  26,  26,  38,   26,  26,  39,  26
byte    0, 26,  36,  26,  26,   36,  26,  36,  38
byte    0, 26,  26,  26,  33,   26,  26,  34,  26
byte    0, 31,  26,  33,  26,   29,  26,  31,  28

byte    1, 14, SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
byte    1,SOFF,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP

byte    2, 33,  33,  33,  36,   33,  33,  36,  33
byte    2, 33,  36,  33,  33,   36,  33,  36,  38

byte    1, 14,  14,  14,  17,   14,  14,  17,  14
byte    1, 14,  17,  14,  14,   17,  14,  17,  19

'UPLIFTING
byte    0, 31,  31,  31,  34,   31,  31,  34,  31
byte    0, 31,  34,  31,  31,   34,  31,  34,  36



byte    1, 19,  19,  19,  22,   19,  19,  22,  19
byte    1, 19,  22,  19,  19,   22,  19,  22,  24




'SONG ------

byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF
byte    0,BAROFF
byte    1,BAROFF
byte    2,BAROFF
byte    3,BAROFF

byte    0,4,BAROFF
byte    1,4,BAROFF
byte    2,5,BAROFF
byte    3,5,BAROFF

byte    0,4,BAROFF
byte    1,4,BAROFF
byte    2,5,BAROFF
byte    3,5,BAROFF

byte    0,6,BAROFF
byte    1,7,BAROFF
byte    2,6,BAROFF
byte    3,7,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    10,12,BAROFF
byte    11,13,BAROFF
byte    10,12,BAROFF
byte    11,13,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    10,12,BAROFF
byte    11,13,BAROFF
byte    10,12,BAROFF
byte    11,13,BAROFF

byte    0,6,8,BAROFF
byte    1,7,9,BAROFF
byte    2,6,8,BAROFF
byte    3,7,9,BAROFF

byte    SONGOFF







{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │
│                                                                                      │                                             
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
