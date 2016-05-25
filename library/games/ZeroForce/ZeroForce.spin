CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    
    FP_OFFSET = 3

OBJ
    lcd         : "LameLCD"
    gfx         : "LameGFX"
    txt         : "LameText"
    audio       : "LameAudio"
    music       : "LameMusic"
    ctrl        : "LameControl"
    fn          : "LameFunctions"

    cc          : "Constants"
    player      : "Player"
    bullets     : "Bullets"

    star        : "StarEffect"
    static      : "StaticEffect"
    explosion   : "ExplosionEffect"
    whoosh      : "WhooshEffect"

    song_logo           : "song_logo"
    song_lastboss       : "song_lastboss"
    song_zeroforce      : "song_zeroforce"

    gfx_zeroforce       : "gfx_zeroforce"
    gfx_logo_zeroforce  : "gfx_logo_zeroforce"
    gfx_logo_teamlame   : "gfx_logo_teamlame"
    
    gfx_explosion       : "gfx_explosion"
    
    gfx_laser           : "gfx_laser"
    gfx_missile         : "gfx_missile"
    
    font                : "gfx_font6x6_g"


VAR
    word    buffer
    
    long    xoffset
    
    byte    blinkon
    word    blinkcount
    byte    collided
    byte    bosshealth
    
    byte    nextstate

PUB Main

    lcd.Start(buffer := gfx.Start)
    lcd.SetFrameLimit (lcd#FULLSPEED)
    
    txt.Load (font.Addr, " ", 8, 6)

    audio.Start
    music.Start
    
    explosion.SetGraphics (0, gfx_explosion.Addr)
    
    bullets.SetType (cc#_LASER1,   gfx_laser.Addr,     0,  false,  false,   1)
    bullets.SetType (cc#_LASER2,   gfx_laser.Addr,     1,  false,  false,   2)
    bullets.SetType (cc#_LASER3,   gfx_laser.Addr,     2,  false,  false,   3)
    bullets.SetType (cc#_MISSILE,  gfx_missile.Addr,   0,  true,   true,    10)
    
    nextstate := cc#_LOGO
    
    repeat
        case nextstate
            cc#_LOGO:   LogoScreen
                        nextstate := cc#_TITLE
            cc#_TITLE:  TitleScreen
                        nextstate := cc#_LEVEL
            cc#_LEVEL:  LevelStage
            cc#_BOSS:   BossStage


PUB LogoScreen | x

    static.Play (buffer, 30, 1)
    
    gfx.Clear
    lcd.Draw
    
    fn.Sleep (500)
    
    gfx.Clear
    gfx.Sprite(gfx_logo_teamlame.Addr, 14, 28, 0)
    lcd.Draw

    audio.SetWaveform(3,3)
    audio.SetADSR(3,127, 10, 0, 10)
    music.Load(song_logo.Addr)  
    music.Play

    fn.Sleep (1500)

    music.Stop    

PUB TitleScreen | blink, i

    music.Load(song_zeroforce.Addr)
    music.Loop
    
    star.Init
    
    ShipWhoosh(16, -160, 300, 12)
    ShipWhoosh(48, -160, 300, 12)
    ShipWhoosh(32, -150, 50, 12)

    fn.Sleep (500)
    
    TitleSwoop(40)

    repeat
        gfx.Clear
        ctrl.Update
        
        star.Handle

        ShipWhooshFrame(50, 32)
        TitleSwoopFrame(0, 32)
        
        blink++
        if (blink >> 4) & $1
            txt.Str (string("PRESS START"), constant(64 - 4*10), 48)
        '
        lcd.Draw
        
        if ctrl.A
            quit
            
    star.SetLightSpeed (true)
    
    i := 50
    repeat while i > 5
        gfx.Clear
        star.Handle
        ShipWhooshFrame(i, 32)
        lcd.Draw
        i--
        
    repeat while i < 20
        gfx.Clear
        star.Handle
        ShipWhooshFrame(i, 32)
        lcd.Draw
        i++
        
    repeat while i < 400
        gfx.Clear
        star.Handle
        ShipWhooshFrame(i, 32)
        lcd.Draw
        i += 12

    music.Stop

PUB TitleSwoop(y) | i

    repeat i from (y << 1) to 0
        gfx.Clear
        ShipWhooshFrame(50, 32)
        TitleSwoopFrame(i >> 1, 32)
        lcd.Draw

PUB TitleSwoopFrame(y, desty) | h
    h := gfx.Height (gfx_logo_zeroforce.Addr) >> 1
    gfx.Sprite (gfx_logo_zeroforce.Addr, 0, desty - h + y, 0)
    gfx.Sprite (gfx_logo_zeroforce.Addr, 67, desty - h - y, 1)

PUB ShipWhoosh(y, start, end, speed) | x

    repeat x from start to end step speed
        gfx.Clear
        ShipWhooshFrame(x, y)
        lcd.Draw
        
    gfx.Clear
    ShipWhooshFrame(end, y)
    lcd.Draw

PUB ShipWhooshFrame(x, y)
    whoosh.Draw (x, y, whoosh#RIGHT) 

    player.SetPosition (x, y - gfx.Height (gfx_zeroforce.Addr) >> 1)
    player.Draw

' *********************************************************
'  Enemies
' *********************************************************
CON
    ENEMIES = 16

VAR           
  
    byte    enemyindex
    byte    enemycount
    byte    nextenemy
    byte    enemyon[ENEMIES]    
    long    enemyx[ENEMIES]
    long    enemyy[ENEMIES] 
    byte    enemyhealth[ENEMIES]
    word    enemyspeed[ENEMIES] 
    
    word    enemygraphics[3]
    byte    enemytypespeed[3]
    byte    enemytypeacceleration[3]
    
    word    currentenemies
    word    currentenemiestmp
    word    currentenemiesoffset


PUB InitEnemies

    enemygraphics[0] := @gfx_spacetank
    enemygraphics[1] := @gfx_krakken
    enemygraphics[2] := @gfx_blackhole

    enemytypespeed[0] := 6
    enemytypespeed[1] := 3
    enemytypespeed[2] := 2
    
    currentenemiesoffset := 0
    enemycount := 0
    
    repeat enemyindex from 0 to constant(ENEMIES-1)
        enemyon[enemyindex] := 0
        enemyx[enemyindex] := 0
        enemyy[enemyindex] := 0
        
                
PUB HandleEnemies

    repeat enemyindex from 0 to constant(ENEMIES-1)
        if enemyon[enemyindex]
            enemyx[enemyindex] -= enemytypespeed[enemyon[enemyindex]-1]
            if enemyx[enemyindex] => -(24 << FP_OFFSET)
                gfx.Sprite(enemygraphics[enemyon[enemyindex]-1], enemyx[enemyindex] >> FP_OFFSET, enemyy[enemyindex] >> FP_OFFSET, 0)
            else
                enemyon[enemyindex] := 0
                enemycount--


PUB SpawnEnemy(dx, dy, type)
    if enemycount < ENEMIES-1
        enemyon[nextenemy] := type
        enemyx[nextenemy] := dx << FP_OFFSET
        enemyy[nextenemy] := dy << FP_OFFSET
        enemyhealth[nextenemy] := 1
        
        nextenemy++
        if nextenemy => ENEMIES
            nextenemy := 0
            
        enemycount++
        
        
{PUB CreateFixedEnemies | x
        currentenemies := word[@level1][currentenemiesoffset]
        currentenemiestmp := currentenemies
        repeat x from 0 to 5
            currentenemiestmp := currentenemies & $3
            if currentenemiestmp > 0
                SpawnEnemy(gfx#SCREEN_W, x << 3, currentenemiestmp)
            currentenemies >>= 2
}
PUB CreateRandomEnemies | ran, x
    ran := cnt
    
    currentenemies := ran? & ran?
    repeat x from 0 to 7
        currentenemiestmp := currentenemies & $3
        if currentenemiestmp > 0
            SpawnEnemy(gfx#SCREEN_W,x << 3,currentenemiestmp)    
        currentenemies >>= 2


PUB InitLevel

    InitBoss
    player.Init
    bullets.init
    InitEnemies
    star.Init
    explosion.Init
    
PUB LevelStage
    
    InitLevel
    
    repeat
        GameLoop
    
PUB GameLoop

    gfx.Clear
    ctrl.Update
   
    if ctrl.B
        star.SetLightSpeed (true)
    else
        star.SetLightSpeed (false)
   
    star.Handle
   
    player.Handle


 '   CreateFixedEnemies
'    currentenemiesoffset++
'    if currentenemiesoffset > 100
'        CreateRandomEnemies
'        currentenemiesoffset := 0

        
    HandleEnemies                

    bullets.Handle
    
    explosion.Handle(0, 0)

    lcd.Draw


' *********************************************************
'  Boss
' *********************************************************
VAR
    byte bosshand1_x
    byte bosshand1_y


    
PUB InitBoss
    blinkon := 0
    blinkcount := 0
    bosshealth := 10

PUB HandleBoss

{{
    repeat bulletindex from 0 to constant(BULLETS-1)
        if bulleton[bulletindex]
            collided := 1
            if bulletx[bulletindex] < 8
                collided := 0
            if bosshealth > 0
                if collided == 1
                    bulleton[bulletindex] := 0
                    blinkon := 1
                  
                    bosshealth--
}}



PUB BossStage

    music.Load(song_lastboss.Addr)
    music.Play
    
    InitLevel
    
    repeat

        lcd.Draw
        
        gfx.Clear
        
        'gfx.Sprite(@gfx_planet, 20,48, 0)
              
        HandleBoss
        player.Handle
        bullets.Handle
        
          
        
    music.Stop
        
        



' *********************************************************
'  Data
' *********************************************************
DAT

gfx_blackhole
word    144  'frameboost
word    24, 24   'width, height

word    $aaaa, $aaaa, $aaaa, $ff5a, $aaaa, $a5fa, $eaa5, $aaaf, $9abf, $aaa9, $ffff, $9aab, $daa9, $0003, $9aa7, $5aa9
word    $5001, $a6b5, $4ea6, $5405, $a5c1, $cf96, $1f17, $a900, $435a, $0d03, $ab50, $056a, $0000, $ab14, $15aa, $5000
word    $ab01, $57aa, $5500, $ab00, $f7aa, $5f55, $ab00, $d3aa, $17d7, $ab00, $53aa, $05d7, $af00, $d3ea, $0755, $bfc0
word    $55fe, $1555, $faf0, $1d6d, $5537, $dab5, $fd55, $d437, $6aa5, $b5a5, $d7f7, $6a57, $a5aa, $deb6, $55aa, $a5aa
word    $9e96, $aaaa, $a6aa, $9696, $aaaa, $aaaa, $aaaa, $aaaa


gfx_krakken
word    96  'frameboost
word    24, 16   'width, height

word    $aaaa, $af5f, $aaaa, $aaaa, $4114, $aaab, $57aa, $5104, $aab0, $757a, $d7f5, $aa14, $c0de, $7555, $af0d, $c006
word    $5555, $c575, $4047, $555d, $d1d7, $500d, $57d5, $1755, $557d, $dd75, $4545, $5d55, $555f, $5545, $d57f, $1554
word    $0dcd, $ff02, $1554, $0305, $3556, $1554, $a80c, $000a, $555d, $aa8c, $2aaa, $75dd, $aaa8, $aaaa, $01d0, $aaaa


gfx_rocket
word    96  'frameboost
word    24, 16   'width, height

word    $aaaa, $aaaa, $5aaa, $aaaa, $aaaa, $d5aa, $5555, $aaa9, $bd56, $5555, $6aa1, $abd5, $ffff, $568f, $abff, $ffff
word    $f54f, $aaff, $ffff, $554f, $a955, $ffff, $0fcf, $a000, $ffff, $000f, $ffff, $ffff, $0fcf, $ac00, $ffff, $5543
word    $a955, $0000, $d580, $aaff, $0000, $5aa0, $abfd, $0000, $aaa8, $abd5, $aaaa, $aaaa, $ad5a, $aaaa, $aaaa, $95aa


gfx_spacetank
word    32  'frameboost
word    16, 8   'width, height

word    $aaaa, $a002, $0ffa, $83fc, $c0aa, $8d57, $3000, $f511, $503c, $1555, $d7f3, $055f, $0000, $03f0, $00aa, $a000
