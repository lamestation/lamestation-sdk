CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    

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
    enemies     : "Enemies"

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
    
    star.Init
    explosion.SetGraphics (0, gfx_explosion.Addr)
    
    bullets.SetType (cc#_LASER1,   gfx_laser.Addr,     0,  false,  false,   1)
    bullets.SetType (cc#_LASER2,   gfx_laser.Addr,     1,  false,  false,   2)
    bullets.SetType (cc#_LASER3,   gfx_laser.Addr,     2,  false,  false,   3)
    bullets.SetType (cc#_MISSILE,  gfx_missile.Addr,   0,  true,   true,    10)
    
    nextstate := cc#_LOGO    
    repeat
        case nextstate
            cc#_LOGO:   LogoScreen
                        nextstate := cc#_INTRO
            cc#_INTRO:  TitleIntro
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

PUB TitleIntro

    music.Load(song_zeroforce.Addr)
    music.Loop
    
    ShipWhoosh(16, -160, 300, 12)
    ShipWhoosh(48, -160, 300, 12)
    ShipWhoosh(32, -20, 50, 3)

    fn.Sleep (500)
    
    TitleSwoop(40)
    
PUB TitleScreen | blink, i    

    repeat
        gfx.Clear
        ctrl.Update
        
        star.Handle

        ShipWhooshFrame(50, 32, true)
        TitleSwoopFrame(0, 32)
        
        blink++
        if (blink >> 4) & $1
            txt.Str (string("PRESS A"), constant(64 - 4*7), 48)
        '
        lcd.Draw
        
        if ctrl.A
            quit
            
    star.SetLightSpeed (true)
    
    PlayerMove(50, 32, 5, 32, 1, true, false)
    PlayerMove(5, 32, 25, 32, 1, true, true)
    PlayerMove(25, 32, 400, 32, 12, true, true)
    
    repeat 20
        gfx.Clear
        star.Handle
        lcd.Draw
        
    gfx.Clear
    lcd.Draw
    fn.Sleep (700)

    TextSwoop(string("MISSION 2"), 64, 32)
        
    PlayerMove(-32, 32, 16, 32, 4, true, true)
    star.SetLightSpeed (false)
    
    PlayerMove(16, 32, 24, 32, 2, true, true)
    
    music.Stop
    
PUB TextSwoop(text, x, y) | len, i

    len := 0
    repeat until text[len] == 0
        len++
        
    x -= 7*len

    i := -96
    repeat i from -96 to x step 8
        gfx.Clear
        star.Handle
        txt.Str (text, i, 30)
        lcd.Draw

    repeat 60
        gfx.Clear
        star.Handle
        txt.Str (text, x, 30)
        lcd.Draw

        
    repeat i from x to 129 step 8
        gfx.Clear
        star.Handle
        txt.Str (text, i, 30)
        lcd.Draw


PUB TitleSwoop(y) | i

    repeat i from (y << 1) to 0
        gfx.Clear
        ShipWhooshFrame(50, 32, true)
        TitleSwoopFrame(i >> 1, 32)
        lcd.Draw

PUB TitleSwoopFrame(y, desty) | h

    h := gfx.Height (gfx_logo_zeroforce.Addr) >> 1
    gfx.Sprite (gfx_logo_zeroforce.Addr, 0, desty - h + y, 0)
    gfx.Sprite (gfx_logo_zeroforce.Addr, 67, desty - h - y, 1)

PUB PlayerMove(x1, y1, x2, y2, speed, staring, whooshing) | dx, dy, xmet, ymet

    dx := x2 - x1
    dy := y2 - y1
    
    xmet := false
    ymet := false

    repeat
        if not xmet
            if dx > 0
                if x1 < x2
                    x1 += speed
                else
                    x1 := x2
                    xmet := true
            elseif dx < 0
                if x1 > x2
                    x1 -= speed
                else
                    x1 := x2
                    xmet := true
            else
                xmet := true

        if not ymet
            if dy > 0
                if y1 < y2
                    y1 += speed
                else
                    y1 := y2
                    ymet := true
            elseif dy < 0
                if y1 > y2
                    y1 -= speed
                else
                    y1 := y2
                    ymet := true
            else
                ymet := true

        gfx.Clear

        if staring
            star.Handle
            
        ShipWhooshFrame(x1, y1, whooshing)

        lcd.Draw

        if xmet and ymet
            quit
        
    gfx.Clear
    ShipWhooshFrame(x2, y2, whooshing)
    lcd.Draw

PUB ShipWhoosh(y, start, end, speed) | x

    repeat x from start to end step speed
        gfx.Clear
        ShipWhooshFrame(x, y, true)
        lcd.Draw
        
    gfx.Clear
    ShipWhooshFrame(end, y, true)
    lcd.Draw

PUB ShipWhooshFrame(x, y, whooshing)
    if whooshing
        whoosh.Draw (x, y, whoosh#RIGHT) 

    player.SetPosition (x, y - gfx.Height (gfx_zeroforce.Addr) >> 1)
    player.Draw

PUB InitLevel

    InitBoss
    player.Init
    bullets.Init
    enemies.Init
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


    enemies.CreateRandomEnemies
 '   CreateFixedEnemies
'    currentenemiesoffset++
'    if currentenemiesoffset > 100
'        CreateRandomEnemies
'        currentenemiesoffset := 0

        
    enemies.Handle

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
        
        

