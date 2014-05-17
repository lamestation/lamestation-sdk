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
        lcd     :               "LameLCD" 
        gfx     :               "LameGFX"  
        audio   :               "LameAudio"
        ctrl    :               "LameControl"
        fn      :               "LameFunctions"

VAR

    word    buffer[1024]
                    
    byte    gamestate
    byte    clicked

PUB Main

    dira~
        
    dira[24]~~
        
    gfx.Start(@buffer, lcd.Start) 
    gfx.LoadFont(@gfx_chars_cropped, " ", 8, 8)

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
    gfx.Sprite(@gfx_pixmain, 40, 8, 0)        
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
            gfx.Blit(@gfx_starmap)      
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
            gfx.Blit(@gfx_starmap)
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
        gfx.Blit(@gfx_starmap)
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
        
            gfx.Blit(@gfx_starmap)
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

    if gfx.TestMapCollision(playerx, playery, word[@gfx_player][1], word[@gfx_player][2])
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

    if gfx.TestMapCollision(playerx, playery, word[@gfx_player][1], word[@gfx_player][2])
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
            gfx.Sprite(@gfx_player,playerx-xoffset,playery-yoffset, 5+pos_frame)
        if pos_dir == RIGHT
            gfx.Sprite(@gfx_player,playerx-xoffset,playery-yoffset, pos_frame)

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
        gfx.Sprite(@gfx_head, x<<3, 56, 0)
        
    repeat x from 0 to (playerhealth-1)
        gfx.Sprite(@gfx_healthbar, 124-x<<2, 56, 0)        



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
                    gfx.Sprite(@gfx_boom, effectxtemp , effectytemp, effectframe[index])
                else
                    effecton[index] := 0


' *********************************************************
'  Objects
' *********************************************************
VAR
    word    objectgraphics[8]
    word    objecthealth[8]
    
PUB InitGraphicAssets
    objectgraphics[PLAYER] := @gfx_player
    objectgraphics[TANK] := @gfx_tank
    objectgraphics[IBOT] := @gfx_ibot
    objectgraphics[IDRONE] := @gfx_idrone
    objectgraphics[BOSS] := @gfx_vortex
    
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
              if fn.TestBoxCollision(bulletx[bulletindex], bullety[bulletindex]+4, 8, 1, playerx, playery, word[@gfx_player][1], word[@gfx_player][2])
                  HitPlayer
                  bulleton[bulletindex] := 0
              else
                  gfx.Sprite(@gfx_laser, bulletxtemp , bulletytemp, 0)
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
    
    xoffset := playerx + (word[@gfx_player][1]>>1) - (SCREEN_W>>1)
    if xoffset < 0
        xoffset := 0      
    elseif xoffset > bound_x
        xoffset := bound_x
        
        
    yoffset := playery + (word[@gfx_player][2]>>1) - (SCREEN_H>>1)
    if yoffset < 0
        yoffset := 0      
    elseif yoffset > bound_y
        yoffset := bound_y


DAT

gfx_laser
word    16  'frameboost
word    8, 8   'width, height

word    $aaaa, $aaaa, $aaaa, $aaaa, $d557, $aaaa, $aaaa, $aaaa

gfx_bullet
word    16  'frameboost
word    8, 8   'width, height

word    $aaaa, $aaaa, $a96a, $a7ca, $a7ca, $a82a, $aaaa, $aaaa

gfx_head
word    16  'frameboost
word    8, 8   'width, height

word    $aaaa, $800a, $3f72, $04f2, $04f2, $3fc2, $000a, $aaaa


gfx_healthbar
word    16  'frameboost
word    8, 8   'width, height

word    $aad7, $aa7c, $aa7c, $aa7c, $aa7c, $aa7c, $aa7c, $aac0


gfx_boom
word    16  'frameboost
word    8, 8   'width, height

word    $aaaa, $a16a, $85d2, $8736, $bfce, $a70e, $ac2a, $aaaa, $a0f2, $935e, $354c, $f751, $30d4, $143c, $81f0, $8002
word    $9e7a, $dbdb, $7fbe, $fbdf, $bfee, $ebb7, $9ff6, $a6da





gfx_player
word    32  'frameboost
word    8, 16   'width, height

word    $acaa, $bf2a, $972e, $bc0a, $a071, $a373, $55d3, $5f30, $800a, $a02a, $ac2a, $a72a, $a70a, $a30a, $a00a, $9f2a
word    $acaa, $bf2a, $972e, $bc0a, $a871, $a373, $55d3, $5f30, $800a, $a00a, $80cf, $001f, $30f7, $323c, $8280, $72bc
word    $acaa, $bf2a, $972e, $bc0a, $a871, $a373, $55d3, $5f30, $800a, $a00a, $8c0a, $1702, $1c32, $323c, $0280, $7ebc
word    $ab2a, $afca, $a5ca, $af0a, $a871, $a373, $55d3, $5f30, $800a, $dc2a, $702a, $000a, $1832, $7806, $ea0e, $aafa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $ab2a, $afca, $a5ca, $af71, $55f3, $5f03, $c002, $dc0e, $00c0, $7c3c
word    $aa3a, $a8fe, $b8d6, $a03e, $4d0a, $cdca, $c755, $0cf5, $a002, $a80a, $a83a, $a8da, $a0da, $a0ca, $a00a, $a8f6
word    $aa3a, $a8fe, $b8d6, $a03e, $4d2a, $cdca, $c755, $0cf5, $a002, $a00a, $f302, $f400, $df0c, $3c8c, $0282, $3e8d
word    $aa3a, $a8fe, $a8d6, $a03e, $4d2a, $cdca, $c755, $0cf5, $a002, $a00a, $a032, $80d4, $8c34, $3c8c, $0280, $3efd
word    $a8ea, $a3fa, $a35a, $a0fa, $4d2a, $cdca, $c755, $0cf5, $a002, $a837, $a80d, $a000, $8c24, $902d, $b0ab, $afaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $a8ea, $a3fa, $a35a, $4dfa, $cf55, $c0f5, $8003, $b037, $0300, $3c3d





gfx_pixmain
word    576  'frameboost
word    48, 48   'width, height

word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $5556, $5555, $abd5, $5aaa, $5555, $bd55, $55aa, $5555
word    $aabd, $aaaa, $5556, $aaf5, $5aaa, $5555, $aaaf, $aaaa, $555a, $aaaf, $aaaa, $d555, $aaab, $aaaa, $d55a, $aaab
word    $aaaa, $d556, $aaab, $aaaa, $f55a, $aaaa, $aaaa, $5556, $000f, $0000, $bd54, $aaaa, $aaaa, $555a, $000f, $0000
word    $af54, $aaaa, $aaaa, $556a, $003d, $0000, $abd5, $aaaa, $aaaa, $55aa, $00f5, $4000, $abd5, $aaaa, $aaaa, $55ea
word    $00f5, $4000, $acf5, $aaaa, $2aaa, $5700, $f7d5, $5fff, $03fd, $aaa0, $2aaa, $5f00, $ff55, $57ff, $03ff, $aaa0
word    $2aaa, $7f00, $fd55, $d5ff, $03ff, $aaa0, $2aaa, $7f00, $fd55, $f57f, $03ff, $aaa0, $2aaa, $ff00, $f555, $f55f
word    $03ff, $aaa0, $2aaa, $ff00, $d557, $7d53, $0000, $aaa0, $2aaa, $ff00, $555f, $5f57, $0000, $aaa0, $2aaa, $ff00
word    $555f, $57d5, $0000, $aaa0, $2aaa, $ff00, $557f, $55f5, $0000, $aaa0, $2aaa, $ff00, $55ff, $55f5, $0000, $aaa0
word    $2aaa, $ff00, $57ff, $57d5, $0000, $aaa0, $2aaa, $ff00, $57ff, $57d5, $0000, $aaa0, $2aaa, $ff00, $55ff, $5f55
word    $0000, $aaa0, $2aaa, $ff00, $757f, $7d55, $0000, $aaa0, $2aaa, $ff00, $3d5f, $f555, $0000, $aaa0, $2aaa, $0000
word    $ff54, $d557, $03ff, $aaa0, $2aaa, $0000, $ff55, $d557, $03ff, $aaa0, $2aaa, $0000, $ffd5, $555f, $03ff, $aaa0
word    $2aaa, $4000, $fff5, $557f, $03fd, $aaa0, $2aaa, $5000, $fffd, $55ff, $03f5, $aaa0, $aaaa, $54aa, $000f, $5500
word    $00f5, $aaa0, $aaaa, $d5aa, $0003, $5400, $03d5, $aaa0, $aaaa, $d56a, $0003, $5000, $0f55, $aaa0, $aaaa, $f56a
word    $0000, $5000, $0f55, $aaa0, $aaaa, $3d5a, $0000, $4000, $3d55, $aaa0, $aaaa, $af56, $aaaa, $aaaa, $f555, $aaaa
word    $aaaa, $af55, $aaaa, $aaaa, $d555, $aaab, $6aaa, $abd5, $aaaa, $aaaa, $d555, $aaab, $56aa, $abd5, $aaaa, $6aaa
word    $5555, $aabd, $556a, $af55, $aaaa, $5aaa, $5555, $aaf5, $5556, $d555, $aaab, $55aa, $5555, $bd55, $aaaa, $aaaa
word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa





gfx_chars_cropped

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0140, $0550, $0550, $0140, $0140, $0000, $0140, $0000
word    $1450, $1450, $1450, $0000, $0000, $0000, $0000, $0000, $1450, $1450, $5554, $1450, $5554, $1450, $1450, $0000
word    $0140, $1550, $0014, $0550, $1400, $0554, $0140, $0000, $0014, $1414, $0500, $0140, $0050, $1414, $1400, $0000
word    $0150, $1414, $1414, $5550, $1414, $1414, $5150, $0000, $0540, $0140, $0050, $0000, $0000, $0000, $0000, $0000
word    $0500, $0140, $0050, $0050, $0050, $0140, $0500, $0000, $0050, $0140, $0500, $0500, $0500, $0140, $0050, $0000
word    $0000, $1414, $0550, $5555, $0550, $1414, $0000, $0000, $0000, $0140, $0140, $1554, $0140, $0140, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0140, $0140, $0050, $0000, $0000, $0000, $1554, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0140, $0140, $0000, $0000, $1400, $0500, $0140, $0050, $0014, $0000, $0000
word    $0550, $1414, $1514, $1554, $1454, $1414, $0550, $0000, $0140, $0150, $0140, $0140, $0140, $0140, $1554, $0000
word    $0550, $1414, $1400, $0540, $0050, $1414, $1554, $0000, $0550, $1414, $1400, $0540, $1400, $1414, $0550, $0000
word    $1500, $1540, $1450, $1414, $5554, $1400, $5500, $0000, $1554, $0014, $0014, $0554, $1400, $1414, $0550, $0000
word    $0540, $0050, $0014, $0554, $1414, $1414, $0550, $0000, $1554, $1414, $1400, $0500, $0140, $0140, $0140, $0000
word    $0550, $1414, $1414, $0550, $1414, $1414, $0550, $0000, $0550, $1414, $1414, $1550, $1400, $0500, $0150, $0000
word    $0000, $0000, $0140, $0140, $0000, $0140, $0140, $0000, $0000, $0000, $0140, $0140, $0000, $0140, $0140, $0050
word    $0500, $0140, $0050, $0014, $0050, $0140, $0500, $0000, $0000, $0000, $1554, $0000, $1554, $0000, $0000, $0000
word    $0050, $0140, $0500, $1400, $0500, $0140, $0050, $0000, $0550, $1414, $1400, $0500, $0140, $0000, $0140, $0000
word    $0550, $1414, $1514, $1114, $1514, $0014, $0550, $0000, $0550, $1414, $1414, $1554, $1414, $1414, $1414, $0000
word    $0554, $1414, $1414, $0554, $1414, $1414, $0554, $0000, $0550, $1414, $0014, $0014, $0014, $1414, $0550, $0000
word    $0154, $0514, $1414, $1414, $1414, $0514, $0154, $0000, $1554, $0014, $0014, $0554, $0014, $0014, $1554, $0000
word    $1554, $0014, $0014, $0554, $0014, $0014, $0014, $0000, $0550, $1414, $0014, $1514, $1414, $1414, $0550, $0000
word    $1414, $1414, $1414, $1554, $1414, $1414, $1414, $0000, $0550, $0140, $0140, $0140, $0140, $0140, $0550, $0000
word    $1500, $1400, $1400, $1400, $1414, $1414, $0550, $0000, $1414, $1414, $0514, $0154, $0514, $1414, $1414, $0000
word    $0014, $0014, $0014, $0014, $0014, $0014, $1554, $0000, $5014, $5454, $5554, $5554, $5114, $5014, $5014, $0000
word    $1414, $1454, $1554, $1554, $1514, $1414, $1414, $0000, $0550, $1414, $1414, $1414, $1414, $1414, $0550, $0000
word    $0554, $1414, $1414, $0554, $0014, $0014, $0014, $0000, $0550, $1414, $1414, $1414, $1514, $0550, $1500, $0000
word    $0554, $1414, $1414, $0554, $0514, $1414, $1414, $0000, $0550, $1414, $0014, $0550, $1400, $1414, $0550, $0000
word    $1554, $0140, $0140, $0140, $0140, $0140, $0140, $0000, $1414, $1414, $1414, $1414, $1414, $1414, $0550, $0000
word    $1414, $1414, $1414, $1414, $1414, $0550, $0140, $0000, $5014, $5014, $5014, $5114, $5554, $5454, $5014, $0000
word    $1414, $1414, $0550, $0140, $0550, $1414, $1414, $0000, $1414, $1414, $1414, $0550, $0140, $0140, $0140, $0000
word    $1554, $1400, $0500, $0140, $0050, $0014, $1554, $0000, $1550, $0050, $0050, $0050, $0050, $0050, $1550, $0000
word    $0000, $0014, $0050, $0140, $0500, $1400, $0000, $0000, $1550, $1400, $1400, $1400, $1400, $1400, $1550, $0000
word    $0100, $0540, $1450, $5014, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $5555, $0000
word    $0150, $0140, $0500, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0550, $1400, $1550, $1414, $1550, $0000
word    $0014, $0014, $0554, $1414, $1414, $1414, $0554, $0000, $0000, $0000, $0550, $1414, $0014, $1414, $0550, $0000
word    $1400, $1400, $1550, $1414, $1414, $1414, $1550, $0000, $0000, $0000, $0550, $1414, $1554, $0014, $0550, $0000
word    $1540, $0050, $0050, $0554, $0050, $0050, $0050, $0000, $0000, $0000, $1550, $1414, $1414, $1550, $1400, $0550
word    $0014, $0014, $0554, $1414, $1414, $1414, $1414, $0000, $0140, $0000, $0150, $0140, $0140, $0140, $0550, $0000
word    $0140, $0000, $0150, $0140, $0140, $0140, $0140, $0050, $0014, $0014, $1414, $0514, $0154, $0514, $1414, $0000
word    $0150, $0140, $0140, $0140, $0140, $0140, $0500, $0000, $0000, $0000, $1450, $5554, $5114, $5114, $5014, $0000
word    $0000, $0000, $0554, $1414, $1414, $1414, $1414, $0000, $0000, $0000, $0550, $1414, $1414, $1414, $0550, $0000
word    $0000, $0000, $0554, $1414, $1414, $0554, $0014, $0014, $0000, $0000, $1550, $1414, $1414, $1550, $1400, $5400
word    $0000, $0000, $0554, $1414, $0014, $0014, $0014, $0000, $0000, $0000, $1550, $0014, $0550, $1400, $0554, $0000
word    $0050, $0050, $0554, $0050, $0050, $0050, $0540, $0000, $0000, $0000, $1414, $1414, $1414, $1414, $1550, $0000
word    $0000, $0000, $1414, $1414, $1414, $0550, $0140, $0000, $0000, $0000, $5014, $5114, $5114, $5554, $1450, $0000
word    $0000, $0000, $1414, $0550, $0140, $0550, $1414, $0000, $0000, $0000, $1414, $1414, $1414, $1550, $1400, $0550
word    $0000, $0000, $1554, $0500, $0140, $0050, $1554, $0000, $0540, $0050, $0050, $0014, $0050, $0050, $0540, $0000
word    $0140, $0140, $0140, $0000, $0140, $0140, $0140, $0000, $0150, $0500, $0500, $1400, $0500, $0500, $0150, $0000
word    $0000, $0000, $5150, $1514, $0000, $0000, $0000, $0000, $0000, $0100, $0540, $1450, $5014, $5014, $5554, $0000






gfx_starmap
word    2048  'frameboost
word    128, 64   'width, height

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0100, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0300, $0000, $0000, $0004, $0000, $0000
word    $0000, $0000, $0000, $0000, $3000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0300, $0000, $0000, $0000, $0100, $0000, $0000, $0000, $0000, $0000, $0000, $0300, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0c00, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $3c00, $3000, $0000, $0000, $0000, $0000, $0000, $3000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $d700, $0000, $0000, $0300, $0000, $0000, $0000, $0000, $0000, $0400, $0000, $0000
word    $0000, $0000, $0000, $0000, $d700, $0000, $0000, $0000, $0000, $0300, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0003, $1000, $3c00, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0100, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0004, $0000, $0000, $0000, $0000, $3000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0003, $3000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0400, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $000c, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $00c0, $0000, $0000, $0000, $0000, $0001, $0000, $0000, $0000, $0000
word    $0300, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $c000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0001, $0000, $0000, $0000, $0300, $c000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $000c, $0000, $0000, $0000, $0000, $0030, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $3000, $0000, $4000, $0000, $0000, $0100, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0400, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0300, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0001, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0004
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $3000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $1000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $3000, $0000, $0100, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0300, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $00c0, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0004, $0000, $0000, $0000, $0010, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $c000, $0000, $0000, $0000, $0000, $0c00, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0300, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0030, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0040, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0400, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0030, $0000, $0000, $0000, $0000, $0c00, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0c00, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0400, $0000, $0000, $0000, $0000, $0000, $0000, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $c000, $000d, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $3000, $4000, $0000, $0030, $0000, $0000, $0000, $0000, $0030, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $3000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0300, $0000, $0000, $0000, $0000, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0c00, $0000, $0000
word    $0000, $0000, $000c, $0000, $0000, $0000, $0000, $0000, $0000, $0100, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $00c0, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0030
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $3000, $0000, $0000, $0000, $0000







gfx_tank
word    64  'frameboost
word    16, 16   'width, height

word    $00aa, $a8fc, $552a, $a350, $552a, $a3dc, $000a, $a0f4, $57ca, $bfc1, $57ca, $b551, $0000, $bff0, $fffc, $b553
word    $5554, $8771, $fffc, $b573, $0000, $8ff0, $001a, $8000, $c1ce, $91c1, $0306, $b303, $003a, $a400, $776a, $ab77
word    $3f2a, $aa00, $05ca, $a855, $37ca, $a855, $1f0a, $a000, $43fe, $a3d5, $455e, $a3d5, $0ffe, $0000, $c55e, $3fff
word    $4dd2, $1555, $cd5e, $3fff, $0ff2, $0000, $0002, $a400, $4346, $b343, $c0ce, $90c0, $001a, $ac00, $ddea, $a9dd



gfx_ibot
word    16  'frameboost
word    8, 8   'width, height

word    $ab29, $adcb, $8303, $d554, $3d7c, $8002, $a30a, $a82a


gfx_idrone
word    64  'frameboost
word    16, 16   'width, height

word    $caa2, $aaad, $7ca2, $aa35, $5722, $ab55, $5fc2, $ad55, $fff2, $8d7f, $5f02, $8ff5, $f155, $555c, $7003, $c011
word    $7003, $c0d1, $d371, $7d5f, $0002, $8030, $0002, $b000, $000a, $a00c, $c02a, $a83f, $00aa, $aa00, $0aaa, $aaa0



gfx_vortex
word    1024  'frameboost
word    64, 64   'width, height

word    $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $00aa, $0000, $0000, $aa80
word    $aaaa, $aaaa, $aaaa, $aaaa, $002a, $0000, $3d5f, $aa80, $aaaa, $aaaa, $aaaa, $aaaa, $540a, $1550, $5540, $aa03
word    $aaaa, $aaaa, $aaaa, $aaaa, $5402, $1571, $5444, $aa0d, $aaaa, $aaaa, $aaaa, $2aaa, $fc03, $15c3, $4344, $aa3d
word    $aaaa, $aaaa, $aaaa, $00aa, $0000, $4700, $0d44, $a835, $aaaa, $aaaa, $02aa, $0000, $ffc0, $4f0f, $3d44, $a834
word    $aaaa, $aaaa, $f2aa, $57ff, $5555, $4035, $fd44, $a0f4, $aaaa, $aaaa, $5caa, $5555, $5555, $0fd5, $f541, $80d0
word    $aaaa, $aaaa, $570a, $f555, $d557, $3d57, $3550, $03d4, $aaaa, $aaaa, $5542, $5555, $5555, $ff55, $0150, $0fd5
word    $aaaa, $aaaa, $d570, $555f, $5555, $ffd5, $5354, $ff55, $aaaa, $aaaa, $55f2, $0055, $57d4, $3ff5, $5c54, $ff55
word    $aaaa, $aaaa, $5f02, $54d5, $5550, $0ffd, $54d5, $fff5, $aaaa, $aaaa, $f002, $54d5, $d551, $43ff, $550d, $003f
word    $aaaa, $aaaa, $0002, $5357, $f551, $10ff, $f570, $4103, $aaaa, $aaaa, $3fc2, $4d5c, $fd45, $0c3f, $3555, $0054
word    $aaaa, $aaaa, $d570, $0570, $fc15, $50c3, $cd55, $0005, $aaaa, $aaaa, $5570, $35f3, $c155, $5430, $43d5, $0005
word    $aaaa, $aaaa, $5ff2, $35f1, $0555, $5500, $73d5, $0005, $aaaa, $aaaa, $5002, $37cd, $0554, $5550, $53f5, $0035
word    $aaaa, $aaaa, $5052, $ff33, $555c, $1555, $73ff, $0015, $aaaa, $aaaa, $5402, $fc3c, $555c, $0155, $7000, $00d5
word    $aaaa, $aaaa, $d572, $f0cc, $555c, $4055, $47c0, $0355, $aaaa, $aaaa, $100a, $f3f3, $555c, $5035, $c7f4, $3555
word    $aaaa, $aaaa, $c5ca, $0f54, $555c, $c001, $05d0, $1555, $aaaa, $aaaa, $f1ca, $0f54, $d55c, $0050, $1544, $5557
word    $aaaa, $aaaa, $3c02, $0f55, $3557, $c154, $1400, $557c, $aaaa, $aaaa, $4f02, $03d5, $0d57, $ccd5, $03f0, $7fc0
word    $aaaa, $aaaa, $53f2, $30f5, $4155, $103c, $fd50, $0000, $aaaa, $aaaa, $543c, $3cf5, $c05f, $1d03, $5554, $fffd
word    $aaaa, $aaaa, $554f, $373d, $f0df, $1743, $4155, $5455, $aaaa, $aaaa, $55f0, $35cf, $4037, $17c0, $5155, $5455
word    $aaaa, $aaaa, $d5fc, $3553, $0537, $c5f0, $5055, $5455, $aaaa, $aaaa, $d5f2, $3553, $f5f7, $c5f0, $5c55, $5c55
word    $aaaa, $aaaa, $f7f2, $0554, $3d0f, $c57c, $7c55, $5c55, $aaaa, $aaaa, $3fca, $0355, $4cf3, $c570, $7c55, $7c55
word    $aaaa, $aaaa, $0f0a, $43d5, $4740, $0500, $f05f, $7055, $aaaa, $aaaa, $730a, $54fd, $047d, $0001, $c0ff, $f0ff
word    $aaaa, $aaaa, $dc02, $5407, $45f5, $0005, $0000, $0000, $aaaa, $aaaa, $7f02, $55f3, $55d5, $5555, $0000, $0000
word    $a800, $aaaa, $ff00, $55fc, $57fd, $5555, $5555, $5555, $00fc, $0aa8, $0ff0, $d5ff, $55f5, $5555, $5555, $0555
word    $3f5c, $0000, $c000, $f17f, $05f5, $0030, $1000, $fc30, $d55c, $ffff, $f3ff, $c14f, $c7f5, $ffff, $5fff, $fffd
word    $555e, $5555, $f355, $5557, $c3d5, $5517, $5555, $fd7d, $1572, $5000, $f055, $5575, $4dd5, $5555, $5555, $fd77
word    $5572, $5555, $f0d5, $f755, $71d5, $5501, $5555, $ff77, $1fca, $5554, $c0f1, $dfd5, $f1d5, $5501, $5555, $c337
word    $ffea, $1550, $c0fc, $d7d5, $c1d7, $5535, $5555, $c0f3, $fc2a, $1503, $c0ff, $cdf7, $cdd7, $5535, $7515, $f0f7
word    $f0aa, $54ff, $c0ff, $c3f7, $ccd7, $5c35, $7415, $000f, $02aa, $17f0, $c03f, $c017, $43f7, $7c31, $7407, $000f
word    $aaaa, $ffc0, $c00f, $c03f, $c3f7, $7017, $7c05, $0007, $aaaa, $f002, $003f, $c03c, $c037, $f41f, $7c01, $0000
word    $aaaa, $002a, $000c, $c03c, $003f, $f01f, $fc01, $0000, $aaaa, $00aa, $0000, $40f0, $000f, $f00f, $3c07, $0000
word    $aaaa, $2aaa, $0000, $00c0, $000f, $c03c, $300f, $0004, $aaaa, $2aaa, $0000, $0000, $0000, $0000, $300d, $0000
word    $aaaa, $aaaa, $0000, $0000, $0000, $0000, $0400, $0000, $aaaa, $aaaa, $0000, $0000, $0000, $0000, $0000, $0000
word    $aaaa, $aaaa, $0002, $0000, $0000, $0000, $0000, $0000, $aaaa, $aaaa, $0002, $0000, $0000, $0000, $0000, $0000







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
