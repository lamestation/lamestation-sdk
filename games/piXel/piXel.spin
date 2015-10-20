CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000


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
    txt     : "LameText"
    map     : "LameMap"
    audio   : "LameAudio"
    music   : "LameMusic"
    ctrl    : "LameControl"
    fn      : "LameFunctions"
    
    efx     : "piXel_Effects"
    sfx     : "piXel_Sound"
    
    gfx_player      : "gfx_player_small"
    gfx_ibot        : "gfx_ibot"
    gfx_idrone      : "gfx_idrone"
    gfx_tank        : "gfx_tank"    
    gfx_macrosoth   : "gfx_macrosoth"
    gfx_laser       : "gfx_laser"
    gfx_bullet      : "gfx_bullet"        
    gfx_head        : "gfx_head"
    gfx_healthbar   : "gfx_healthbar"
    gfx_starmap     : "gfx_starmap"
    gfx_pixmain     : "gfx_pixmain"
    
    font            : "font8x8"
    
    gfx_tiles_pixel : "gfx_tiles_pixel"

    song_theme      : "song_pixeltheme"
    song_sad        : "song_sad"
    song_ohno       : "song_ohno"
    song_superohno  : "song_superohno"
    song_boss       : "song_boss"
    song_yeah       : "song_yeah"


VAR
    byte    gamestate
    byte    clicked

PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#FULLSPEED)
    txt.Load(font.Addr, " ", 8, 8)

    audio.Start
    music.Start
    ctrl.Start
    sfx.Start

    InitGraphicAssets

    InitGame
    InitLevel
    
    music.Load(song_theme.Addr)
    music.Loop

    gamestate := TITLE
    clicked := 0
    repeat
        case gamestate
            TITLE:      TitleScreen
            INTRO:      GameIntro
                        gamestate := STARTLEVEL
            STARTLEVEL: InitLevel                
                        music.Stop                        
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
    gfx.ClearScreen(0)

    txt.Str(string("p  i      e  l"), 8, 30)
    gfx.Sprite(gfx_pixmain.Addr, 40, 8, 0)        
    txt.Str(string("press A/B"), 28, 56)

    if ctrl.A or ctrl.B
        if not clicked
            gamestate := INTRO
            clicked := 1
        else
            clicked := 0
    lcd.DrawScreen

PUB GameLoop
    ctrl.Update
    gfx.Blit(gfx_starmap.Addr)
    HandlePlayer                        
    ControlOffset
    map.Draw(xoffset, yoffset)
    DrawPlayer
    HandleBullets
    HandleEnemies
    efx.Handle(xoffset,yoffset)
    HandleStatusBar
    lcd.DrawScreen
            
PUB Victory
    music.Stop
    fn.Sleep(100)
    music.Load(song_yeah.Addr)
    music.Play
    
    ShowGameView
    txt.Box(string("YOU WIN"), 40, 30, 100, 60)
    lcd.DrawScreen
    fn.Sleep(2000)
    
    music.Stop
    music.Load(song_theme.Addr)
    music.Loop            
    StarWarsReel(string("Looks like",10,"the galaxy",10,"is safe once",10,"again, thanks",10,"to you!"),110)

PUB ShowGameView
    gfx.Blit(gfx_starmap.Addr)
    HandlePlayer                        
    ControlOffset
    map.Draw(xoffset, yoffset)
    HandleBullets
    HandleEnemies
    HandleStatusBar

PUB PlayerDied
    playerlives--
    
    music.Load(song_ohno.Addr)
    music.Play         
    
    ShowGameView
    txt.Box(string("Macrosoth",10,"lives yet..."), 20, 20, 100, 60)
    lcd.DrawScreen
    fn.Sleep(2000)

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
        playerx := 55 << 6
        playery := 5 << 6
        pos_dir := LEFT

         
        ControlOffset
        gfx.Blit(gfx_starmap.Addr)
        map.Draw(xoffset, yoffset)
        DrawPlayer

        
        txt.Box(text, 16, 64-x, 108, 64) 
    
        lcd.DrawScreen
        fn.Sleep(70)
        x++

PUB ItsGameOver
    music.Load(song_superohno.Addr)
    music.Play     
    
    ShowGameView
    txt.Box(string("GAME OVER"), 30, 28, 100, 60)
    lcd.DrawScreen
    fn.Sleep(2000)
    
    jumping := 0
    crouching := 1
    pos_frame := 4
    
    music.Stop   
    music.Load(song_sad.Addr)
    music.Loop    
    
    StarWarsReel(string("There was",10,"nothing you",10,"could do to",10,"stop him..."),100)
    
    gfx.Blit(gfx_starmap.Addr)
    map.Draw(xoffset, yoffset)
    DrawPlayer            
    txt.Str(string("Press A and "),18,24)
    txt.Str(string("try again..."),18,32)
    lcd.DrawScreen
    
    repeat until ctrl.A
        ctrl.Update

PUB GameIntro
    jumping := 0
    crouching := 0
    pos_frame := 0
    
    music.Stop   
    music.Load(song_sad.Addr)
    music.Loop    

    StarWarsReel(string("You have",10,"escaped",10,"the evil",10,"experiments",10,"of the one",10,"they call",10,"Macrosoth.",10,10,"Now you must",10,"defeat him",10,"once and for",10,"all..",10,10,"Before it's",10,"too late..."),200)


' *********************************************************
'  Levels
' *********************************************************  
CON
    LEVELS = 1

OBJ

    map_pixel   :       "map_pixel"

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

    tilemap := gfx_tiles_pixel.Addr
    leveldata[0] := map_pixel.Addr

    ControlOffset
    InitPlayer
    InitBullets
    InitEnemies
    efx.Init
        
    map.Load(tilemap, leveldata[currentlevel])
    ReadObjects(map_pixel.objAddr)

            
' *********************************************************
'  Player
' *********************************************************
CON
    TERMINAL_VELOCITY = 120
    GRAVITY = 4
    JUMP = 50
    FRICTION = 3
    PLAYER_SPEED = 20
    PLAYER_ACCEL = 6
    STARTING_HEALTH = 5
    STARTING_LIVES = 3
    
VAR
    long    playerx
    long    playery
    long    pos_oldx
    long    pos_oldy

    byte    pos_dir
    long    pos_speedx
    long    pos_speedy
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

PUB HandlePlayer | adjust, sx, sy
    pos_oldx := playerx ~> 3
    pos_oldy := playery ~> 3
            
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
                if pos_speedx > -PLAYER_SPEED
                    pos_speedx -= PLAYER_ACCEL
                pos_dir := LEFT
                
            if ctrl.Right
                if pos_speedx < PLAYER_SPEED
                    pos_speedx += PLAYER_ACCEL
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

    if pos_speedx > 0
        pos_speedx -= FRICTION
    elseif pos_speedx < 0
        pos_speedx += FRICTION

    playerx += pos_speedx
    sx := playerx ~> 3
    
    adjust := map.TestMoveX(pos_oldx, pos_oldy, word[gfx_player.Addr][1], word[gfx_player.Addr][2], sx)
    if adjust
        sx += adjust
        playerx := sx << 3
        pos_speedx := 0
        
    if sx < 0
        sx := 0
    if sx > (map.Width << 3 - word[gfx_player.Addr][1]) << 3
        sx := (map.Width << 3 - word[gfx_player.Addr][1]) << 3

    if ctrl.A
        if not jumping               
            pos_speedy := -JUMP
            jumping := 1
            sfx.RunSound(1, sfx#_JUMP)

    if ctrl.B
        if not playershoot_timeout
            playershoot_timeout := SHOOT_TIMEOUT
            
            if crouching
                if pos_dir == LEFT
                    SpawnBullet(sx, pos_oldy+7, LEFT)
                if pos_dir == RIGHT
                    SpawnBullet(sx, pos_oldy+7, RIGHT)    
            else
                if pos_dir == LEFT
                    SpawnBullet(sx, pos_oldy+2, LEFT)
                if pos_dir == RIGHT
                    SpawnBullet(sx, pos_oldy+2, RIGHT)    
        else
            playershoot_timeout--
    else
        playershoot_timeout := 0

    if pos_speedy < TERMINAL_VELOCITY
        pos_speedy += GRAVITY
        
    playery += pos_speedy
    sy := playery ~> 3

    adjust := map.TestMoveY(sx, pos_oldy, word[gfx_player.Addr][1], word[gfx_player.Addr][2], sy)
    if adjust
        if  pos_speedy > 0
            jumping := 0
        sy += adjust
        pos_speedy := 0
        playery := sy << 3
    
    if pos_speedy > 8
        jumping := 1
        
    if sy > (map.Height << 3)
        KillPlayer
                
    if playerhealth_timeout > 0
        playerhealth_timeout--
        
        
PUB TestPlayerCollision(x, y, w, h)
    return fn.TestBoxCollision(x, y, w, h, playerx ~> 3, playery ~> 3, word[gfx_player.Addr][1], word[gfx_player.Addr][2])

PUB DrawPlayer | sx, sy
    sx := playerx ~> 3
    sy := playery ~> 3
    if not playerhealth_timeout or (playerhealth_timeout & $2)
        if pos_dir == LEFT
            gfx.Sprite(gfx_player.Addr,sx-xoffset,sy-yoffset, 5+pos_frame)
        if pos_dir == RIGHT
            gfx.Sprite(gfx_player.Addr,sx-xoffset,sy-yoffset, pos_frame)

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
            PLAYER:     playerx := objx << 3
                        playery := objy << 3
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

    sfx.RunSound(2, sfx#_LASER)

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

          bulletxtemp := (bulletx[bulletindex] - xoffset)
          bulletytemp := (bullety[bulletindex] - yoffset)

          if (bulletxtemp => 0) and (bulletxtemp =< SCREEN_W-1) and (bulletytemp => 0) and (bulletytemp =< SCREEN_H - 1)
              if TestPlayerCollision(bulletx[bulletindex], bullety[bulletindex]+4, 8, 1)
                  HitPlayer
                  bulleton[bulletindex] := 0
              else
                  gfx.Sprite(gfx_laser.Addr, bulletxtemp, bulletytemp, 0)
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
    
    dx := (playerx ~> 3) - enemyx[index]
    dy := (playery ~> 3) - enemyy[index]
    
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

    if map.TestCollision(enemyx[index], enemyy[index], 16, 16)
        enemyx[index] := pos_oldx
        enemyspeedx[index] := -enemyspeedx[index]
    
    enemyspeedy[index] += 1
    enemyy[index] += enemyspeedy[index]

    if map.TestCollision(enemyx[index], enemyy[index], 16, 16)
        enemyy[index] := pos_oldy
        enemyspeedy[index] := 0
    
    if enemydir[index] == LEFT
        enemyframe[index] := 0
    else
        enemyframe[index] := 1




PUB EnemyEye(index) | dx, dy
    dx := (playerx ~> 3) - enemyx[index]
    dy := (playery ~> 3) - enemyy[index]
    
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
    dx := (playerx ~> 3) - enemyx[index]
    dy := (playery ~> 3) - enemyy[index]

    if not bossspawned
        bossspawned := 1
    
        music.Load(song_boss.Addr)
        music.Loop    


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
                        efx.Spawn(enemyx[index]+(x<<3), enemyy[index]+(y<<3), efx#EXPLOSION)
                        
                if enemyon[index] == BOSS
                    gamestate := WIN

                enemyon[index] := 0
            bulleton[bulletindex] := 0
                
    if fn.TestBoxCollision(playerx ~> 3, playery ~> 3, GetObjectWidth(PLAYER), GetObjectHeight(PLAYER), enemyx[index], enemyy[index], GetObjectWidth(enemyon[index]), GetObjectHeight(enemyon[index]))
        HitPlayer


PUB ControlOffset | bound_x, bound_y, sx, sy

    sx := playerx ~> 3
    sy := playery ~> 3

    bound_x := map.Width << 3 - SCREEN_W
    bound_y := map.Height << 3 - SCREEN_H
    
    xoffset := sx + (word[gfx_player.Addr][1]>>1) - (SCREEN_W>>1)
    if xoffset < 0
        xoffset := 0      
    elseif xoffset > bound_x
        xoffset := bound_x

    yoffset := sy + (word[gfx_player.Addr][2]>>1) - (SCREEN_H>>1)
    if yoffset < 0
        yoffset := 0      
    elseif yoffset > bound_y
        yoffset := bound_y
