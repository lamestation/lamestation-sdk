{{
Tank Battle
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2011 LameStation.
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


CON
    _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
    _xinfreq        = 5_000_000                ' External oscillator = 5 MHz
                     
    SCREEN_W = 128
    SCREEN_H = 64
            
    DIR_L = 0
    DIR_R = 1
    DIR_U = 2
    DIR_D = 3
    
    LEVELS = 1
    LEVELSMASK = LEVELS-1
    
    GO_GAME = 1
    GO_MENU = 2
    
    PAUSEMENU1_CHOICES = 3
    
    WIFI_RX = 22
    WIFI_TX = 23

    
    
    'DECIDES WHO CLICKED TO INITIALIZE THE GAME
    'if this message is sent, you start in starting location 1.
    'if it's received by an opponent, you start in location 2.
    'UPDATEADVANCE = 10


    'SONG PLAYER
    ENDOFSONG = 0
    TIMEWAIT = 1
    NOTEON = 2
    NOTEOFF = 3
    
    SONGS = 2
    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252
    
    BARRESOLUTION = 8
    MAXBARS = 18
        

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    audio   :               "LameAudio"
    pst     :               "LameSerial"
    ctrl    :               "LameControl"
    fn      :               "LameFunctions"

VAR

    word    buffer[1024]
    word    screen



    long    x
    long    y    
    long    tile
    long    tilecnt
    long    tilecnttemp





    byte    score[TANKS]
    byte    oldscore

    byte    yourtank
    byte    theirtank
    byte    yourtype
    byte    oldtype
    byte    theirtype
    byte    tankindex
    byte    levelindex
    word    bulletindex

    byte    choice
    byte    menuchoice
    byte    clicked           
    byte    joyclicked

    byte    intarray[3]


    'WIFI HANDLING VARIABLES
    byte    receivebyte
    byte    bulletspawned
    byte    tankspawned
    byte    respawnindex
    byte    respawnindexsaved

PUB Main

    dira~
    screen := lcd.Start
    gfx.Start(@buffer, screen)
    pst.StartRxTx(31, 30, 0, 115200)

    audio.Start
    ctrl.Start

    gfx.ClearScreen
    gfx.DrawScreen

    gfx.LoadFont(@gfx_chars_cropped, " ", 8, 8)
    InitData

    clicked := 0
    
    'LogoScreen
    TitleScreen
    TankSelect
    'LevelSelect                          
    'TankFaceOff          

    menuchoice := GO_GAME
    repeat
        if menuchoice == GO_GAME
            menuchoice := GameLoop
        elseif menuchoice == GO_MENU
            menuchoice := PauseMenu


' *********************************************************
'  Scenes
' *********************************************************   
PUB LogoScreen

    gfx.ClearScreen
    gfx.DrawScreen
    gfx.ClearScreen
    gfx.Sprite(@gfx_logo_teamlame, -2, 24, 0)
    gfx.DrawScreen

    audio.SetWaveform(3, 127)
    audio.SetADSR(127, 10, 0, 10)
    audio.PlaySequence(@logoScreenSound)  

    fn.Sleep(15000)

    audio.StopSong

PUB TitleScreen

    audio.SetWaveform(1, 127)
    audio.SetADSR(127, 127, 100, 127) 
    audio.LoadSong(@titleScreenSong)
    audio.PlaySong



    choice := 1
    repeat until not choice
        ctrl.Update
        gfx.DrawScreen

        gfx.Blit(@gfx_logo_tankbattle)   

        if ctrl.A or ctrl.B
              if not clicked
                choice := 0
                clicked := 1
               
                yourtank := 0
                theirtank := 1
                pst.Char(UPDATEORDER) 

        else
              clicked := 0

        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATEORDER
              yourtank := 1
              theirtank := 0

              choice := 0
              clicked := 1


PUB TankSelect         

    choice := 1
    joyclicked := 0
    repeat until not choice

        ctrl.Update
        gfx.DrawScreen       
        gfx.ClearScreen

        if ctrl.Up or ctrl.Down
           if joyclicked == 0
              joyclicked := 1 
              if ctrl.Up
                if yourtype <> 0
                  yourtype--
                else
                  yourtype := TANKTYPESMASK
              if ctrl.Down
                yourtype++
                if yourtype > TANKTYPESMASK
                  yourtype := 0

              pst.Char(UPDATETYPE)
              pst.Char(yourtype) 
        else
            joyclicked := 0

      
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1

            pst.Char(UPDATEADVANCE)
            
        else
          clicked := 0


        'MULTIPLAYER HANDLING
        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                        
           if receivebyte == UPDATETYPE
              theirtype := pst.CharIn
    
           elseif receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1          
        


        gfx.Sprite(@gfx_logo_tankbattle_name, 0, 0, 0)
        gfx.PutString(string("CHOOSE"), 48, 16)
           
        gfx.PutString(string("vs."),56,40)
                
        gfx.Sprite(@gfx_tankstand, 20, 44, 0) 
        gfx.Sprite(@gfx_tankstand, 86, 44, 0) 
            
        gfx.Sprite(tanktypegfx[yourtype], 24, 32, 3) 
        gfx.Sprite(tanktypegfx[theirtype], 88, 32, 2) 

        
        gfx.PutString(tanktypename[yourtype],0,24)
        gfx.PutString(tanktypename[theirtype],56,56)


PUB LevelSelect

    choice := 1
    joyclicked := 0
    repeat until not choice

        ctrl.Update
        gfx.DrawScreen
        gfx.ClearScreen         


        if ctrl.Up or ctrl.Down
           if not joyclicked
              joyclicked := 1 
              if ctrl.Up
                if currentlevel <> 0
                  currentlevel--
                else
                  currentlevel := LEVELSMASK
              if ctrl.Down
                currentlevel++
                if currentlevel > LEVELSMASK
                  currentlevel := 0

              pst.Char(UPDATELEVEL)
              pst.Char(currentlevel)
        else
            joyclicked := 0
              

        
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1

            pst.Char(UPDATELEVEL)
            pst.Char(currentlevel)
            pst.Char(UPDATEADVANCE)
            
        else
          clicked := 0

        'MULTIPLAYER HANDLING
        
        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATELEVEL
              currentlevel := pst.CharIn

           elseif receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1       
              

        gfx.Sprite(@gfx_logo_tankbattle_name, 0, 0, 0)
        gfx.PutString(string("Level:"),0,16)                  
        gfx.PutString(levelname[currentlevel],40,16)
        
        gfx.LoadMap(tilemap,leveldata[currentlevel])
        gfx.DrawMap(xoffset,yoffset,0,3,16,8)


PUB TankFaceOff
         
    choice := 1
    repeat until not choice

        ctrl.Update 
        gfx.DrawScreen        
        gfx.ClearScreen

        gfx.Sprite(@gfx_logo_tankbattle_name, 0, 0, 0)
        gfx.PutString(string("Prepare for battle..."),0,24)
     
        if ctrl.A or ctrl.B
          if not clicked
            choice := 0
            clicked := 1

            pst.Char(UPDATEADVANCE)
        else
          clicked := 0  

        'MULTIPLAYER HANDLING
        repeat while pst.RxCount > 0
           receivebyte := pst.CharIn
                    
           if receivebyte == UPDATEADVANCE
              choice := 0
              clicked := 1   


PUB GameLoop : menureturn

    audio.StopSong
    audio.SetWaveform(4, 127)
    audio.SetADSR(127, 70, 0, 70)
  
    InitLevel

    clicked := 0
    choice := 0                               
    repeat while not choice

        ctrl.Update
        gfx.DrawScreen
        gfx.ClearScreen

        if tankon[yourtank]
            ControlTank 
            ControlOffset(yourtank)     
        else
            GhostMode
            
            
        'HandleNetworking
        gfx.DrawMap(xoffset,yoffset,0,0,16,8)

        DrawTanks
        HandleBullets
        HandleStatusBar

    menureturn := choice
    


PUB ControlTank
   
    tankoldx := tankx[yourtank]
    tankoldy := tanky[yourtank]
    tankolddir := tankdir[yourtank]
    oldscore := score[yourtank]

    ' Left/Right
    if ctrl.Left
       tankdir[yourtank] := 0        

       tankx[yourtank] -= tanktypespeed[yourtype]
        if tankx[yourtank] < 0
            tankx[yourtank] := 0
    if ctrl.Right
        tankdir[yourtank] := 1
    
        tankx[yourtank] += tanktypespeed[yourtype]
        if tankx[yourtank] > levelw<<3 - tankw[yourtank]
            tankx[yourtank] := levelw<<3 - tankw[yourtank] 


    ' map collision
    if gfx.TestMapCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank])
        tankx[yourtank] := tankoldx
    
    ' Tank-to-tank collision
    
    repeat tankindex from 0 to TANKSMASK
        if tankon[tankindex] and tankindex <> yourtank
            if fn.TestBoxCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank], tankx[tankindex], tanky[tankindex], tankw[tankindex], tankh[tankindex])
                tankx[yourtank] := tankoldx
    
    ' Up/Down
    if ctrl.Up
        tankdir[yourtank] := 2
        
        tanky[yourtank] -= tanktypespeed[yourtype]
        if tanky[yourtank] < 0
            tanky[yourtank] := 0
    if ctrl.Down
        tankdir[yourtank] := 3  

        tanky[yourtank] += tanktypespeed[yourtype]
        if tanky[yourtank] > levelh<<3 - tankh[yourtank]
            tanky[yourtank] := levelh<<3 - tankh[yourtank]
 
    ' map collision
    if gfx.TestMapCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank])
        tanky[yourtank] := tankoldy
        
    repeat tankindex from 0 to TANKSMASK
        if tankon[tankindex] and tankindex <> yourtank
            if fn.TestBoxCollision(tankx[yourtank], tanky[yourtank], tankw[yourtank], tankh[yourtank], tankx[tankindex], tanky[tankindex], tankw[tankindex], tankh[tankindex])
                tanky[yourtank] := tankoldy  
 
    if ctrl.A
      if not clicked
        clicked := 1
        tankhealth[yourtank]--
     
       ' choice := GO_MENU 'Go to menu
        
      '  yourtank++
       ' yourtank &= TANKSMASK

    elseif ctrl.B
        if tankon[yourtank] == 1
          SpawnBullet(yourtank)
          bulletspawned := 1
      
    else
        clicked := 0      

PUB GhostMode  
    if ctrl.Left
        xoffset--
        if xoffset < 0
            xoffset := 0 
    if ctrl.Right
        xoffset++
        if xoffset > levelw<<3-SCREEN_W
            xoffset := levelw<<3-SCREEN_W


    
    'UP AND DOWN   
    if ctrl.Up
        yoffset-- 
        if yoffset < 0
            yoffset := 0  
    if ctrl.Down
        yoffset++
        if yoffset > levelh<<3-SCREEN_H
            yoffset := levelh<<3-SCREEN_H  

     
    if ctrl.A or ctrl.B
      if clicked == 0
        SpawnTank(yourtank, 0, 1)
        tankspawned := 1      
        
        clicked := 1
    else
        clicked := 0    
    

PUB PauseMenu : menureturn

    choice := 0
    repeat while not choice
           
        ctrl.Update 
        gfx.DrawScreen         
        gfx.ClearScreen

        gfx.Sprite(@gfx_logo_tankbattle_name, 0, 0, 0)
        gfx.PutString(string(" PAUSE!"),40,16)


        if ctrl.Up or ctrl.Down
           if not joyclicked
              joyclicked := 1 
              if ctrl.Up
                if menuchoice <> 0
                  menuchoice--
                else
                  menuchoice := PAUSEMENU1_CHOICES
              if ctrl.Down
                menuchoice++
                if menuchoice > PAUSEMENU1_CHOICES
                  menuchoice := 0 
        else
            joyclicked := 0
             

        if ctrl.A or ctrl.B
          if not clicked
            choice := GO_GAME
            clicked := 1
        else
          clicked := 0
          
        gfx.Sprite(@gfx_bullet, 3, 4+menuchoice, 0)
        gfx.PutString(string("Return to Game"),4,4)
        gfx.PutString(string("Change Level"),4,5)
        gfx.PutString(string("Change Tank"),4,6)
        gfx.PutString(string("Give Up?"),4,7)


    if menuchoice == 1
        LevelSelect

    elseif menuchoice == 2
        TankSelect

    menureturn := GO_GAME



PUB InitData

    currentlevel := 0
    yourtype := 0
    theirtype := 1

    tilemap := @gfx_tiles_2b_poketron

    leveldata[0] := @map_supercastle  
    'leveldata[0] := @MoonManLevel   
    'leveldata[1] := @WronskianDelta
    'leveldata[2] := @TheCastle
    'leveldata[3] := @thehole
    'leveldata[4] := @pokemon
               
    levelname[0] := @level0name
    'levelname[1] := @level1name
    'levelname[2] := @level2name
    'levelname[3] := @level3name
    'levelname[4] := @level4name

    levelw := byte[leveldata[currentlevel]][0] 
    levelh := byte[leveldata[currentlevel]][1]

    tanktypename[0] := @gfx_supertankname   
    tanktypename[1] := @gfx_superthangname
    tanktypename[2] := @gfx_class16name
    tanktypename[3] := @gfx_happyfacename
    tanktypename[4] := @gfx_moonmanname

    tanktypegfx[0] := @gfx_supertank
    tanktypegfx[1] := @gfx_superthang
    tanktypegfx[2] := @gfx_class16
    tanktypegfx[3] := @gfx_happyface
    tanktypegfx[4] := @gfx_moonman


    tanktypespeed[0] := 5
    tanktypespeed[1] := 10
    tanktypespeed[2] := 2
    tanktypespeed[3] := 6
    tanktypespeed[4] := 7

              
' *********************************************************
'  Levels
' *********************************************************  
VAR
    long    levelw
    long    levelh
    byte    currentlevel
    word    leveldata[LEVELS]
    word    levelname[LEVELS]
    word    tilemap
    byte    levelstarts[LEVELS*TANKS]
    
    long    xoffset
    long    yoffset
      
PUB InitLevel



    levelw := byte[leveldata[currentlevel]][0] 
    levelh := byte[leveldata[currentlevel]][1]

    'INITIALIZE START LOCATIONS         
    repeat tankindex from 0 to TANKSMASK
        score[tankindex] := 0 
        SpawnTank(tankindex, tankindex, 0)

    tankspawned := 0
    respawnindex := yourtank

    ControlOffset(yourtank)

    InitBullets
    InitTanks
    
    'gfx.LoadMap(tilemap,leveldata[currentlevel])
    gfx.LoadMap(tilemap,leveldata[currentlevel])

    

PUB ControlOffset(tankindexvar) | bound_x, bound_y

    bound_x := levelw<<3 - SCREEN_W
    bound_y := levelh<<3 - SCREEN_H
    
    xoffset := tankx[tankindexvar] + (tankw[tankindexvar]>>1) - (SCREEN_W>>1)
    if xoffset < 0
        xoffset := 0      
    elseif xoffset > bound_x
        xoffset := bound_x
                  
    yoffset := tanky[tankindexvar] + (tankh[tankindexvar]>>1) - (SCREEN_H>>1)
    if yoffset < 0
        yoffset := 0      
    elseif yoffset > bound_y
        yoffset := bound_y



              
' *********************************************************
'  Tanks
' *********************************************************
CON
    TANKS = 2   'must be power of 2
    TANKSMASK = TANKS-1
    
    TANKTYPES = 5 'must be power of 2
    TANKTYPESMASK = TANKTYPES-1
    
    TANKHEALTHMAX = 10
    
VAR

    long    tankgfx[TANKS]
    long    tankx[TANKS]
    long    tanky[TANKS]
    long    tankoldx
    long    tankoldy
    byte    tankolddir
    byte    tankstartx[TANKS]
    byte    tankstarty[TANKS]

    long    tankw[TANKS]
    long    tankh[TANKS]
    byte    tankdir[TANKS]
    byte    tankhealth[TANKS]
    byte    tankon[TANKS]

    long    tankxtemp
    long    tankytemp
    long    tankwtemp
    long    tankhtemp

    long    tanktypegfx[TANKTYPES]
    word    tanktypename[TANKTYPES]
    byte    tanktypespeed[TANKTYPES]


PUB InitTanks
    tankgfx[yourtank] := tanktypegfx[yourtype]
    tankgfx[theirtank] := tanktypegfx[theirtype]

    repeat tankindex from 0 to TANKSMASK
       tankw[tankindex] := word[tankgfx[tankindex]][1]
       tankh[tankindex] := word[tankgfx[tankindex]][2]
    
    

PUB SpawnTank(tankindexvar, respawnindexvar, respawnflag)
    if respawnflag == 1
       respawnindex := (respawnindex + 1) & TANKSMASK
       tankx[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindex<<1)+0] <<3
       tanky[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindex<<1)+1] <<3
    else
       tankx[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindexvar<<1)+0] <<3 
       tanky[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindexvar<<1)+1] <<3
    
    tankon[tankindexvar] := 1
    tankhealth[tankindexvar] := TANKHEALTHMAX
    tankdir[tankindexvar] := 0


PUB DrawTanks    
    repeat tankindex from 0 to TANKSMASK
        if tankon[tankindex]
            tankxtemp := tankx[tankindex] - xoffset
            tankytemp := tanky[tankindex] - yoffset
            tankwtemp := tankw[tankindex]
            tankhtemp := tankh[tankindex]        
                                                                                 
            if (tankxtemp => 0) and (tankxtemp =< SCREEN_W-tankw[tankindex]) and (tankytemp => 0) and (tankytemp =< SCREEN_H - tankh[tankindex])

                if tankdir[tankindex] == DIR_D
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 0)
                elseif tankdir[tankindex] == DIR_U       
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 1)
                elseif tankdir[tankindex] == DIR_L       
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 2)
                elseif tankdir[tankindex] == DIR_R       
                    gfx.Sprite(tankgfx[tankindex], tankxtemp, tankytemp, 3)




' *********************************************************
'  Networking
' *********************************************************  
CON
    UPDATETANKX = 1
    UPDATETANKY = 2
    UPDATETANKDIR = 3
    UPDATEBULLETSPAWN = 4
    
    'CONTROLS LIFE AND DEATH
    UPDATETANKSPAWN = 5
    UPDATETANKDIED = 6
    UPDATESCORE = 7
    UPDATEADVANCE = 8
    UPDATEORDER = 9
    UPDATETYPE = 10
    UPDATELEVEL = 11

PUB HandleNetworking

    'WIRELESS STUFF
    if tankoldx <> tankx[yourtank]
       pst.Char(UPDATETANKX)
       pst.Char(tankx[yourtank])

    if tankoldy <> tanky[yourtank]
       pst.Char(UPDATETANKY)
       pst.Char(tanky[yourtank])

    if tankolddir <> tankdir[yourtank]
       pst.Char(UPDATETANKDIR)
       pst.Char(tankdir[yourtank])

    if bulletspawned == 1
       pst.Char(UPDATEBULLETSPAWN)
       bulletspawned := 0

    if tankspawned == 1
       pst.Char(UPDATETANKSPAWN)
       pst.Char(respawnindex)
       tankspawned := 0

    if oldscore <> score[yourtank]
       pst.Char(UPDATESCORE)
       pst.Char(score[yourtank])


    repeat while pst.RxCount > 0
          receivebyte := pst.CharIn

          if receivebyte == UPDATETANKX
             tankx[theirtank] := pst.CharIn

          elseif receivebyte == UPDATETANKY
             tanky[theirtank] := pst.CharIn

          elseif receivebyte == UPDATETANKDIR
             tankdir[theirtank] := pst.CharIn

          elseif receivebyte == UPDATEBULLETSPAWN
             SpawnBullet(theirtank)

          elseif receivebyte == UPDATETANKSPAWN
             receivebyte := pst.CharIn
             SpawnTank(theirtank,receivebyte,0)

          elseif receivebyte == UPDATESCORE
             score[theirtank] := pst.CharIn

          elseif receivebyte == UPDATETANKDIED
             receivebyte := pst.CharIn
             tankon[receivebyte] := 0
                  
   
' *********************************************************
'  Bullets
' *********************************************************      
CON 
    BULLETS = 20
    BULLETSMASK = BULLETS-1
    BULLETINGSPEED = 15
  
VAR
    word    bullet
    long    bulletx[BULLETS]
    long    bullety[BULLETS]
    byte    bulletspeed[BULLETS]
    byte    bulletdir[BULLETS]
    byte    bulleton[BULLETS]

    long    bulletxtemp
    long    bulletytemp


PUB InitBullets
    bullet := 0
    repeat bulletindex from 0 to BULLETSMASK
        bulleton[bulletindex] := 0 
        bulletx[bulletindex] := 0
        bullety[bulletindex] := 0
        bulletspeed[bulletindex] := 0
        bulletdir[bulletindex] := 0
    bulletspawned := 0   
    

PUB SpawnBullet(tankindexvar)

    bulleton[bullet] := 1 
    bulletdir[bullet] := tankdir[tankindexvar]

    if bulletdir[bullet] == DIR_L
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_R
        bulletx[bullet] := tankx[tankindexvar] + tankw[tankindexvar] - 8
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_U
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar]
          
    if bulletdir[bullet] == DIR_D
        bulletx[bullet] := tankx[tankindexvar]
        bullety[bullet] := tanky[tankindexvar] + tankh[tankindexvar] - 8
                      
    bullet++
    if bullet > BULLETSMASK
        bullet := 0

    audio.PlaySound(2+tankindexvar,40)
          

PUB HandleBullets

    repeat bulletindex from 0 to BULLETS-1
        if bulleton[bulletindex]

          if bulletdir[bulletindex] == DIR_L
             bulletx[bulletindex] -= BULLETINGSPEED
          
          elseif bulletdir[bulletindex] == DIR_R
             bulletx[bulletindex] += BULLETINGSPEED   
          
          elseif bulletdir[bulletindex] == DIR_U
             bullety[bulletindex] -= BULLETINGSPEED    
          
          elseif bulletdir[bulletindex] == DIR_D
             bullety[bulletindex] += BULLETINGSPEED  

          bulletxtemp := bulletx[bulletindex] - xoffset
          bulletytemp := bullety[bulletindex] - yoffset

          if (bulletxtemp => 0) and (bulletxtemp =< SCREEN_W-1) and (bulletytemp => 0) and (bulletytemp =< SCREEN_H - 1)
          
             gfx.Sprite(@gfx_bullet, bulletxtemp , bulletytemp, 0)

             repeat tankindex from 0 to TANKSMASK
                if tankon[tankindex]
                    if fn.TestBoxCollision(bulletx[bulletindex], bullety[bulletindex], 8, 8, tankx[tankindex], tanky[tankindex], tankw[tankindex], tankh[tankindex])
                       if tankhealth[tankindex] > 1
                           tankhealth[tankindex]--
                       else
                           tankon[tankindex] := 0
                           score[(tankindex+1) & TANKSMASK]++ 
                           pst.Char(UPDATETANKDIED)
                           pst.Char(tankindex)
                           
                       bulleton[bulletindex] := 0
          else
              bulleton[bulletindex] := 0




PUB HandleStatusBar

   
    'STATUS HUD
    if tankon[yourtank]
        repeat x from 0 to (tankhealth[yourtank]-1)
            if x == (tankhealth[yourtank]-1)
                if x & 1
                    gfx.SetClipRectangle(0, 56, (x + 1) << 2 ,64) 
                else
                    gfx.Sprite(@gfx_heart, x<<2, 56, 0)
            else
                if not x & 1
                    gfx.Sprite(@gfx_heart, x<<2, 56, 0)
        gfx.SetClipRectangle(0, 0, 128,64)

    intarray[0] := 48+(score[yourtank]/10)
    intarray[1] := 48+(score[yourtank]//10)
    intarray[2] := 0

    gfx.PutString(@intarray, 0, 0)


    intarray[0] := 48+(score[theirtank]/10)
    intarray[1] := 48+(score[theirtank]//10)
    intarray[2] := 0

    gfx.PutString(@intarray, 112, 0)


DAT


gfx_tiles_2b_poketron

word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $575d, $5515, $5d57, $d555, $45d5, $5557, $7551, $5d55
word    $4771, $dd1d, $cccf, $33f4, $4cf1, $d3cf, $3cd1, $771d, $f1f1, $0001, $7c7c, $0000, $f1f1, $0001, $7c7c, $0000
word    $31f1, $0000, $4c7c, $4000, $31f1, $0000, $4c7c, $4000, $575d, $5515, $5005, $4711, $0df0, $0f10, $01c0, $1300
word    $575d, $5515, $5005, $4711, $0df0, $0f10, $01c0, $1307, $575d, $5515, $5005, $4711, $0df0, $0f10, $11c0, $3307
word    $575d, $5515, $5d57, $d555, $45d5, $1557, $c151, $7c15, $575d, $1515, $c157, $7c15, $d7c1, $3d7c, $c3d7, $7c3d
word    $75d5, $5454, $d543, $543d, $43d7, $3d7c, $d7c3, $7c3d, $575d, $5515, $5d57, $d555, $45d5, $5554, $5d43, $543d
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $4001, $3ffc, $30cc, $3ffc, $4001, $5415, $5714, $1575
word    $5440, $5c4c, $fc0c, $0043, $1533, $57cf, $3c3f, $03ff, $0d15, $3335, $303f, $c340, $c354, $f3d4, $fc3c, $ffc0
word    $5535, $5535, $0cf3, $4010, $1145, $1555, $3ff3, $4404, $43c5, $1551, $f55c, $3554, $f554, $3554, $0ff4, $50c1
word    $f000, $1001, $c015, $0005, $0711, $0df0, $0f10, $11c0, $f00d, $100f, $c011, $0003, $0710, $0df0, $0f10, $11c0
word    $000d, $400f, $5c11, $5003, $4710, $0df0, $0f10, $11c0, $d7c0, $3d7c, $c3d4, $7c3f, $d7c0, $3d7c, $c3d4, $7c3f
word    $d7c3, $3d7c, $c3d7, $7c3d, $d7c3, $3d7c, $c3d7, $7c3d, $c3d7, $3d7c, $d7c3, $7c3d, $c3d7, $3d7c, $d7c3, $7c3d
word    $03d7, $3d7c, $17c3, $fc3d, $03d7, $3d7c, $17c3, $fc3d, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $015d, $5115, $0157, $5155, $f015, $0100, $5414, $5514, $0340, $5105, $0140, $5005, $f14f, $0000, $5555, $5555
word    $5740, $5545, $5d40, $d545, $540f, $0040, $1415, $1455, $5454, $5454, $fcfc, $0000, $5554, $5554, $fffc, $0000
word    $1455, $1455, $3cff, $0000, $1554, $1554, $3ffc, $0000, $3300, $0000, $c001, $7c15, $54dd, $7715, $4cf1, $5d55
word    $3300, $0000, $c003, $7c3f, $54dd, $7715, $4cf1, $5d55, $3300, $0000, $4003, $5c3f, $54dd, $7715, $4cf1, $5d55
word    $d7c3, $3d7c, $c3d7, $3c3d, $43c3, $543c, $0003, $fffc, $03c3, $003c, $1143, $1154, $1155, $1155, $1000, $03ff
word    $c3c0, $3c00, $c144, $1544, $5544, $5544, $0004, $ffc0, $c3d7, $3d7c, $d7c3, $7c3c, $c3c1, $3c15, $c000, $3fff
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $553c, $5500, $5514, $5514, $5500, $5514, $5514, $5514
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $3c55, $0055, $1455, $1455, $0055, $1455, $1455, $1455
word    $00ff, $1501, $3510, $0c54, $00d1, $000d, $0003, $0000, $5500, $4015, $0537, $45cc, $5300, $f000, $c000, $0000
word    $000d, $000f, $c011, $f003, $4710, $0df0, $0f10, $11c0, $f000, $1000, $c003, $000f, $0711, $0df0, $0f10, $11c0
word    $575d, $5515, $5005, $4711, $0df0, $0f10, $11c0, $3300, $0000, $0000, $4444, $4444, $0000, $0000, $1554, $0000
word    $1554, $0000, $0000, $0000, $0ccc, $3330, $1ddc, $5555, $0000, $3ffc, $355c, $355c, $03fc, $355c, $3ffc, $0000
word    $0000, $3ffc, $355c, $355c, $3fc0, $355c, $3ffc, $0000, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5500, $5514, $013c, $5100, $0050, $514c, $f00c, $0140, $5555, $5555, $0140, $5145, $0140, $5005, $f14f, $0000
word    $0055, $1455, $3c40, $0045, $0500, $3145, $1c0f, $0500, $0000, $0000, $0000, $0000, $4444, $1111, $4545, $5555
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $000d, $400f, $5c11, $5003, $4710, $0df0, $0f10, $11c0
word    $f000, $1001, $c015, $0005, $0711, $0df0, $0f10, $11c0, $0000, $4001, $5c17, $d4dd, $7715, $4cf3, $7551, $5d55
word    $0000, $5555, $5555, $5555, $5555, $5555, $0000, $ffff, $d73c, $3d00, $c314, $7c14, $d700, $3d14, $c314, $7c14
word    $3cd7, $007c, $14c3, $143d, $00d7, $147c, $14c3, $143d, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5540, $57cc, $fc3c, $00d0, $5470, $544c, $fc0c, $01c0
word    $355c, $dc37, $d007, $d007, $dc37, $dc37, $355c, $ffff, $0d15, $3335, $303f, $0340, $01d4, $3354, $343c, $0d00
word    $013c, $5100, $0114, $5114, $f000, $0100, $5414, $5514, $3c40, $0045, $1440, $1445, $000f, $0040, $1415, $1455
word    $5555, $5555, $5005, $4711, $0df0, $0f10, $11c0, $3300, $7fff, $f3ff, $cf77, $f5f3, $7dff, $555f, $7377, $5d7f
word    $ffcf, $ddff, $fffd, $f3f7, $f7dd, $fd57, $fd1d, $fff5, $0000, $1111, $5555, $1111, $0000, $0000, $0410, $0000
word    $d7c3, $3d7c, $03c0, $5005, $03c0, $5005, $f14f, $0000, $c3d7, $3d7c, $03c0, $5005, $03c0, $5005, $f14f, $0000
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5440, $5c4c, $fc0c, $0041, $1531, $57c5, $3c15, $0155, $5455, $5455, $fcff, $0000, $5554, $5554, $fffc, $0000
word    $0d15, $3335, $303f, $4340, $4354, $53d4, $543c, $5540, $1554, $4001, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $5555, $0000, $4001, $5c15, $54dd, $7715, $4cf1, $5555, $5555
word    $57f7, $577f, $7f7f, $f5f3, $4fdf, $5dff, $ff37, $ffff, $f5dd, $fd75, $7fdf, $c774, $fdf5, $cf57, $f7df, $ffff
word    $c3c0, $3c00, $c144, $7c04, $d7c0, $3d7c, $c3d4, $7c3f, $ffff, $0000, $ffff, $5555, $ffff, $0000, $ffff, $5555
word    $03c3, $003c, $1143, $103d, $03d7, $3d7c, $17c3, $fc3d, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $ffff, $5fff, $f5ff, $3f7f, $03df, $0cdf, $40f7, $5337
word    $ffff, $fff5, $ff5f, $fdfc, $f7c3, $f730, $df01, $dc05, $55d5, $5555, $0557, $c015, $0315, $f017, $7cc5, $dc05
word    $5d75, $5555, $0550, $c00c, $0cc0, $f00f, $5ff5, $f55f, $5d75, $5555, $5550, $d40c, $54c0, $540f, $503d, $5337
word    $575d, $5515, $5f57, $f555, $cdd5, $d5d7, $fd51, $fd55, $575d, $5515, $dd57, $f5d5, $4dfd, $71f7, $ff51, $fff7
word    $575d, $5515, $5d57, $d555, $45f5, $55d7, $7753, $5d5f, $03ff, $53ff, $03ff, $53ff, $f03f, $0100, $5414, $5514
word    $03c0, $53c5, $03c0, $5005, $f14f, $0000, $5555, $5555, $ffc0, $ffc5, $ffc0, $ffc5, $fc0f, $0040, $1415, $1455
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5037, $40f7, $0cdf, $c3df, $3f7f, $f5ff, $5fff, $ffff, $dcc5, $df01, $f730, $f7c0, $fdfc, $ff5f, $fff5, $ffff
word    $dcc5, $dc07, $7315, $7035, $7315, $7015, $dccd, $dc05, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff, $ffff
word    $d037, $5337, $5c0d, $74cd, $540d, $54cd, $7037, $5337, $d75d, $7d15, $7fd7, $fcd5, $cdd5, $ffd7, $f751, $dd55
word    $f73f, $7fdc, $73ff, $cfff, $ff47, $dfff, $f7fd, $f33d, $577d, $5517, $5d77, $f77f, $47f7, $57cf, $75d7, $5fc7
word    $1144, $0140, $1144, $1004, $1144, $0140, $1144, $1004, $0410, $1144, $4551, $1554, $1554, $4551, $1144, $0410
word    $4444, $1111, $4444, $1111, $4444, $1111, $4444, $1111, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555
word    $ffff, $fc0f, $f153, $c554, $c554, $c55c, $cff3, $f00f, $dcc5, $7c05, $f015, $0315, $3017, $0555, $5555, $5d75
word    $f55f, $5ff5, $f00f, $0330, $3003, $0550, $5555, $5d75, $5037, $573d, $d40f, $54c0, $5503, $d550, $5555, $5755
word    $f7dd, $dd15, $5dd7, $f555, $c7d5, $5557, $7551, $5d55, $ff77, $7fdf, $cfdf, $dd73, $c5c7, $55f7, $755f, $5d55
word    $55ff, $553f, $5d5d, $d5ff, $45df, $5557, $7551, $5d55, $1004, $4144, $0140, $1444, $1504, $0004, $5150, $0000
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $1004, $1141, $0140, $1114, $1054, $1000, $0545, $0000
word    $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555, $5555

mapTable_tiles_2b_poketron
word    @map_supercastle


map_supercastle
byte     50,  50  'width, height
byte    108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108
byte    228,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,230
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,170
byte    168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte    168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte    168, 41, 41, 41, 41,170,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,168, 41, 41, 41, 41,170
byte    168, 41, 41, 41,182,183,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,181,182, 41, 41, 41,170
byte    168, 41, 41, 41,170,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,194,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,194,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,144,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,143,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,228,229,229,229,229,229,229,229,229,230,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41,114, 41, 41, 41,114,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,228,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,168, 41,114, 41, 41,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115, 41,114, 41,114,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,115, 41, 41, 41,114,114, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,229,229,229,229, 41, 41, 41,114, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,115, 41, 41, 41,114,114, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,155,156,157, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,155,156,157, 41,114, 41, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,168, 41,170, 41, 41,115,115,115,115,115,115,115,115,115,115, 41, 41,168, 41,170,114, 41, 41, 41,114, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,181,182,183, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,181,182,183, 41, 41, 41, 41, 41, 41,170,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,194,208,209,156,156,156,156,156,156,156,156,156,156,156,156,156,156,207,208,196, 41, 41, 41, 41,182,182,183,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114, 41, 41,168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,170,115,115,115,115,208,208,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,197,156,157, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,155,156,198, 41, 41, 41, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,168, 41,170,170, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,168, 41,170, 41, 41, 41, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,181,182,183,182,182,182,182,182,182,182,182,182,182,182,182,182,182,181,182,183, 41, 41,114, 41, 41,170,196,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,208,208,208,208,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,144,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,115,115,115,115,168, 41, 41,114, 41, 41,194,208,196,195,208,208,208,195,208,208,208,208,195,208,208,208,195,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,159,171,172,158,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168, 41, 41,114, 41, 41,194,208,196,208,208,208,208,208,159, 57, 57,158,208,208,208,208,208,194,208,196, 41, 41,114, 41, 41,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,115,114,115,115,194,208,196,208,208,208,208,208,159, 57, 57,158,208,208,208,208,208,194,208,196,115,115,114,115,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,114, 41,114,115,207,208,209, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,207,208,209,115,114, 41,114,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115, 41,114, 41,115,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,115, 41,114, 41,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,114, 41,114,115,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,114,115,114, 41,114,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,168,115,115,115,115,115, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,115,115,115,115,115,170,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,181,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,183,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,143,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,144,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,170,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,168, 41, 41, 41,170
byte    168, 41, 41, 41,156,230,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,108,228,156, 41, 41, 41,170
byte    168, 41, 41, 41, 41,170,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,229,168, 41, 41, 41, 41,170
byte    168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte    168, 41,114,114, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,114,114, 41,170
byte    168, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41,170
byte    181,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,182,183
byte    194,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,208,196
byte    194,208,208,208,196,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,158,159,108,108,108,108,108,194,208,208,208,196


startlocations

byte    1, 2
byte    46, 44
byte    46, 3







DAT 'SPRITE DATA


gfx_supertank
word    64  'frameboost
word    16, 16   'width, height

word    $70aa, $aa0d, $00c2, $9c00, $5c5c, $5435, $545c, $5715, $54f0, $7c15, $507c, $df05, $00f0, $3c30, $f0dc, $3737
word    $c0dc, $3707, $005c, $1700, $f103, $40cf, $c100, $4003, $0300, $c000, $a0c3, $f00a, $a855, $552a, $aaff, $ffaa
word    $52de, $b785, $54dc, $3715, $00dc, $3700, $573c, $3f55, $57d0, $37d5, $5f1c, $d5d5, $fc3c, $df3f, $0010, $f400
word    $c03c, $d403, $f03c, $d40d, $c03c, $3c01, $0000, $0000, $7055, $550d, $c0ff, $ff03, $0855, $5520, $aaff, $ffaa
word    $00aa, $a8fc, $552a, $a350, $552a, $a3dc, $000a, $a0f4, $57ca, $bfc1, $57ca, $b551, $0000, $bff0, $fffc, $b553
word    $5554, $8771, $fffc, $b573, $0000, $8ff0, $001a, $8000, $c1ce, $91c1, $0306, $b303, $003a, $a400, $776a, $ab77
word    $3f2a, $aa00, $05ca, $a855, $37ca, $a855, $1f0a, $a000, $43fe, $a3d5, $455e, $a3d5, $0ffe, $0000, $c55e, $3fff
word    $4dd2, $1555, $cd5e, $3fff, $0ff2, $0000, $0002, $a400, $4346, $b343, $c0ce, $90c0, $001a, $ac00, $ddea, $a9dd




gfx_superthang
word    64  'frameboost
word    16, 16   'width, height

word    $002a, $a800, $55ca, $a355, $c003, $c003, $1554, $1554, $1554, $1554, $1414, $1414, $1414, $1414, $1554, $1554
word    $0554, $1550, $5003, $c005, $157a, $ad54, $ffea, $abff, $02aa, $0280, $f02a, $a00f, $0caa, $aa30, $80aa, $aa02
word    $002a, $a800, $000a, $a000, $0003, $c000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0003, $c000, $000f, $f000, $00fa, $af00, $ffea, $abff, $0280, $aa80, $f00a, $a00f, $0caa, $aa30, $80aa, $aa02
word    $002a, $aa00, $000a, $a000, $550e, $a000, $5550, $8001, $0000, $8005, $5510, $803c, $5510, $8035, $5550, $803d
word    $5557, $8017, $555e, $b005, $543a, $af0d, $ffc0, $abff, $000a, $aa80, $f2aa, $aa8f, $c2aa, $aa83, $0aaa, $aaa0
word    $00aa, $a800, $000a, $a000, $000a, $b055, $4002, $0555, $5002, $0000, $3c02, $0455, $5c02, $0455, $7c02, $0555
word    $d402, $d555, $500e, $b555, $70fa, $ac15, $ffea, $03ff, $02aa, $a000, $f2aa, $aa8f, $c2aa, $aa83, $0aaa, $aaa0



gfx_class16
word    144  'frameboost
word    24, 24   'width, height

word    $aaaa, $aaaa, $a9aa, $aaaa, $8002, $a9aa, $aaaa, $0ff0, $a5ea, $aaaa, $0000, $74c2, $aaaa, $0000, $77c2, $2aaa
word    $0550, $b7c9, $c14a, $0000, $b7c7, $c7f2, $0000, $b7c7, $cf02, $c003, $b7c3, $0002, $ffff, $b7c0, $000e, $0000
word    $b7c0, $cff2, $0c30, $b7c3, $c55e, $0c30, $9cc3, $3ff2, $0140, $b030, $155e, $cc33, $b034, $3ff2, $0000, $b03c
word    $d55e, $0ff0, $8fc7, $3ff2, $0ff0, $8cfc, $3ff2, $0000, $8cfc, $d55e, $0000, $b457, $d55e, $0000, $b557, $3ff2
word    $0000, $8ffc, $3ff2, $a00a, $8ffc, $800a, $aaaa, $a002, $a93a, $aaaa, $aaaa, $a53e, $aaaa, $aaaa, $ad32, $8002
word    $aaaa, $adf2, $0ff0, $aaaa, $adf2, $0000, $aaaa, $adf2, $0000, $aaaa, $2df2, $0000, $aaa9, $cdf2, $0000, $a143
word    $cdf2, $0000, $87f3, $cd72, $c003, $8fc3, $0d72, $ffff, $8000, $0732, $0000, $b000, $0c0e, $0000, $b554, $1c0c
word    $0000, $8ffc, $1c0c, $0ff0, $b554, $33f2, $0ff0, $8ffc, $d51e, $0ff0, $b557, $3ff2, $0000, $8ffc, $3ff2, $0000
word    $8ffc, $d55e, $0000, $b557, $d55e, $0000, $b557, $3ff2, $a00a, $8ffc, $3ff2, $aaaa, $8ffc, $800a, $aaaa, $a002
word    $aaaa, $f2aa, $aaa8, $aaaa, $00aa, $aaa0, $a9aa, $00aa, $aaa0, $a36a, $05aa, $a5a0, $fffa, $ffff, $afff, $555a
word    $5555, $a555, $fffa, $ffff, $afff, $000a, $0000, $a000, $030a, $0000, $af00, $bdaa, $03ca, $a080, $b3aa, $002a
word    $aa80, $bdaa, $036a, $aaa0, $b3aa, $0c6a, $aaa0, $bdaa, $032a, $aaa0, $aaaa, $3cca, $aa80, $ffc6, $000f, $b3c0
word    $0001, $ff00, $c003, $f5f4, $f5f5, $c5f5, $0f04, $0f0f, $3f0f, $005d, $5005, $c500, $40f7, $f40f, $0f40, $40f4
word    $f40f, $cf40, $0002, $0000, $b000, $f0fa, $f0f0, $a0f0, $2aaa, $aa8f, $aaaa, $0aaa, $aa00, $aaaa, $0aaa, $aa00
word    $aa6a, $0a5a, $aa50, $a9ca, $0ffa, $ff00, $afff, $005a, $5000, $a555, $c4fa, $f1d7, $afff, $f00a, $0f70, $a000
word    $30fa, $01c0, $a0c0, $020a, $a3c0, $aa7e, $02aa, $a800, $aace, $0aaa, $a9c0, $aa7e, $0aaa, $a930, $aace, $0aaa
word    $a8c0, $aa7e, $02aa, $a33c, $aaaa, $03ce, $f000, $93ff, $c003, $00ff, $4000, $5f53, $5f5f, $1f5f, $f0fc, $f0f0
word    $10f0, $0053, $5005, $7500, $01f0, $f01f, $df01, $01f3, $f01f, $1f01, $000e, $0000, $8000, $0f0a, $0f0f, $af0f


gfx_happyface
word    64  'frameboost
word    16, 16   'width, height

word    $00aa, $aa00, $7ffa, $affd, $1c02, $8035, $5002, $8004, $4002, $8001, $ccce, $b333, $cdde, $b773, $0cc0, $0330
word    $0000, $0000, $33f0, $0fcc, $0d50, $0570, $fd1e, $b47f, $547a, $ad15, $017a, $ad40, $55ea, $ab55, $ffaa, $aaff
word    $00aa, $aa00, $fffa, $afff, $f002, $800f, $c002, $8003, $c002, $8003, $c002, $8003, $c002, $8003, $c000, $0003
word    $c000, $0003, $c000, $0003, $c000, $0003, $c00e, $8003, $c00a, $a003, $c03a, $ac03, $f0ea, $ab0f, $ffaa, $aaff
word    $0002, $aa00, $fffd, $abff, $003c, $ac00, $000d, $b000, $0001, $b000, $ccce, $b000, $ddde, $b000, $ccc0, $c000
word    $0000, $c000, $3f03, $c000, $15c0, $c000, $117f, $b000, $1456, $ac00, $f502, $ac00, $fd56, $ab03, $fffe, $aaff
word    $00aa, $8000, $ffea, $7fff, $003a, $3c00, $000e, $7000, $000e, $4000, $000e, $b333, $000e, $b777, $0003, $0333
word    $0003, $0000, $0003, $c0fc, $0003, $0354, $000e, $fd44, $003a, $9514, $003a, $805f, $c0ea, $957f, $ffaa, $bfff


gfx_moonman
word    64  'frameboost
word    16, 16   'width, height

word    $eaaa, $aaad, $5eaa, $aab5, $7a2a, $aad5, $705a, $aad5, $750e, $ab55, $0d0e, $a800, $00fa, $a804, $082a, $a804
word    $722a, $ab5d, $7aaa, $a315, $7aaa, $8ac1, $57aa, $8ad5, $5eaa, $8a35, $faaa, $aa2f, $2aaa, $aa2a, $0aaa, $a82a
word    $7aaa, $aaab, $5eaa, $aab5, $57aa, $a8ad, $57aa, $a015, $55ea, $b57c, $55ea, $bf7c, $55ea, $af01, $55ea, $a82d
word    $57ea, $a880, $57ca, $aaad, $7fa2, $aaad, $fca2, $aad4, $fca2, $aabc, $f8aa, $aaac, $a8aa, $aaa8, $a82a, $aaa0
word    $7aaa, $aaab, $5faa, $aab5, $7a8a, $aad5, $c3f2, $8f55, $f55e, $bd55, $0ff2, $8d00, $0002, $8514, $0a0a, $a554
word    $560a, $ad15, $6aaa, $a851, $0aaa, $a354, $557a, $a2d5, $57ea, $a237, $feaa, $aa2f, $2aaa, $aa2a, $0aaa, $aa0a
word    $eaaa, $aaad, $5eaa, $aaf5, $57aa, $a2ad, $55f2, $8fc3, $557e, $b55f, $0072, $8ff0, $1452, $8000, $155a, $a0a0
word    $547a, $a095, $452a, $aaa9, $15ca, $aaa0, $578a, $ad55, $dc8a, $abd5, $f8aa, $aabf, $a8aa, $aaa8, $a0aa, $aaa0



gfx_bullet
word    16  'frameboost
word    8, 8   'width, height

word    $aaaa, $a57a, $9dce, $97f2, $9fc2, $b332, $ac0a, $aaaa




gfx_heart
word    16  'frameboost
word    8, 8   'width, height

word    $b4de, $d7d4, $5757, $d557, $f55c, $8d72, $a3ca, $a82a
  



gfx_tankstand
word    96  'frameboost
word    24, 16   'width, height

word    $7aaa, $5555, $aaad, $35ea, $c30c, $ab50, $dfde, $7df7, $b7df, $30c1, $c30c, $4c30, $df7f, $7df7, $f7df, $30dc
word    $c30c, $3430, $f5f0, $7df7, $0f5f, $7f00, $5555, $00fd, $c00c, $ffff, $3003, $033c, $0000, $3cc0, $cf32, $ffff
word    $8cf3, $cc2a, $ffff, $a833, $0aaa, $ffff, $aaa0, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa, $aaaa



gfx_logo_teamlame
word    512  'frameboost
word    128, 16   'width, height

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $5555, $5545, $0155, $0054, $0015, $0015, $0050, $0000, $0054, $0015, $5515, $4555, $1145, $0000
word    $0000, $0000, $0500, $0140, $0000, $0054, $0015, $0015, $0050, $0000, $0054, $0015, $0515, $0000, $4441, $0000
word    $0000, $0000, $0500, $0140, $0000, $0145, $4055, $0015, $0050, $0000, $0145, $4055, $0515, $0000, $4441, $0000
word    $0000, $0000, $0500, $5500, $0155, $0145, $4055, $0015, $0050, $0000, $0145, $4055, $5415, $0555, $0000, $0000
word    $0000, $0000, $0500, $0140, $4000, $0501, $5155, $0015, $0050, $4000, $0501, $5155, $0515, $0000, $0000, $0000
word    $0000, $0000, $0500, $0140, $4000, $0501, $5145, $0014, $0050, $4000, $0501, $5145, $0514, $0000, $0000, $0000
word    $0000, $0000, $0500, $0140, $5000, $1400, $5545, $0014, $0050, $5000, $1400, $5545, $0514, $0000, $0000, $0000
word    $0000, $0000, $0500, $5500, $5555, $5400, $1505, $0014, $5540, $5455, $5400, $1505, $5414, $0555, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000






gfx_logo_tankbattle_name
word    512  'frameboost
word    128, 16   'width, height

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $c350, $4057, $1555, $5540, $0035, $f500, $0000, $5570, $3401, $0170, $5f55, $5c05, $0555, $0005, $5400, $0555
word    $00d0, $507f, $5555, $f550, $10c3, $d540, $0000, $5fc0, $d505, $05c0, $f0f5, $f005, $0555, $0005, $5500, $0c0f
word    $0000, $0000, $5000, $0050, $5000, $0140, $0000, $0000, $0005, $0500, $0000, $0000, $0000, $000d, $0500, $0000
word    $c000, $0000, $5000, $0070, $5000, $0150, $0000, $000c, $0005, $0500, $0000, $0000, $000c, $0003, $0500, $0000
word    $f000, $0000, $5000, $0070, $50c0, $00d4, $0000, $000f, $0005, $0500, $0000, $0000, $000f, $0000, $0500, $0000
word    $7000, $d000, $5703, $0070, $5070, $0035, $0000, $5557, $5505, $0555, $0000, $0000, $000f, $0000, $d500, $0000
word    $5000, $5000, $5c0f, $00c0, $7070, $000d, $0000, $ffd5, $5505, $0555, $0c00, $0000, $0007, $0000, $5500, $0003
word    $5000, $5000, $d000, $0000, $7050, $0001, $0000, $0005, $0507, $0500, $0700, $0000, $0005, $0003, $0500, $0000
word    $5000, $5000, $d000, $0030, $7050, $3c00, $0000, $0005, $0d07, $0500, $0700, $0000, $0005, $000d, $0500, $0000
word    $5000, $5000, $f000, $00f0, $f050, $dc00, $0000, $c3f5, $0d0f, $0700, $0700, $0000, $0005, $5555, $5505, $0fd5
word    $5000, $5000, $f000, $0050, $c050, $5000, $0000, $00ff, $0d03, $0f00, $0500, $0000, $0005, $c3d4, $5407, $00ff
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000

         
gfx_logo_tankbattle
word    2048  'frameboost
word    128, 64   'width, height

word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
word    $c350, $4057, $1555, $5540, $0035, $f500, $1000, $5570, $3401, $0170, $5f55, $5c05, $0555, $0005, $5400, $0155
word    $00d0, $507f, $5555, $f550, $10c3, $d540, $0000, $5fc0, $d505, $05c0, $f0f5, $f005, $0555, $4005, $5500, $000f
word    $0000, $0000, $5000, $0050, $5000, $0140, $0000, $0000, $0005, $0500, $0000, $0000, $0000, $000d, $053c, $0000
word    $c000, $0000, $5000, $0070, $5000, $0150, $0000, $000c, $3c05, $0500, $0003, $0000, $000c, $0003, $053c, $0000
word    $f001, $0000, $5000, $0070, $50c0, $00d4, $00c0, $000f, $0ff5, $0500, $0000, $0004, $000f, $0000, $050f, $3000
word    $7000, $d0c0, $5703, $0070, $5070, $0035, $0000, $5557, $5535, $0555, $0000, $03c0, $030f, $f000, $d50f, $0000
word    $5000, $5000, $5c0f, $00c0, $7070, $000d, $0000, $ffd5, $5505, $0555, $0c00, $03c0, $0007, $3f00, $5500, $0003
word    $5000, $5000, $d000, $0000, $7050, $0001, $0000, $3f05, $0507, $0500, $0700, $00ff, $0005, $00f3, $0500, $0000
word    $5000, $5000, $d000, $0030, $7050, $3c00, $0000, $0f05, $0d07, $0500, $f700, $003c, $0005, $000d, $0500, $0000
word    $5000, $5000, $f000, $00f0, $f050, $dc00, $f000, $c3f5, $0d0f, $0700, $0700, $000f, $0005, $5555, $5505, $03d5
word    $5000, $5000, $f000, $0c50, $c050, $5000, $fc00, $00ff, $0d03, $0f00, $0500, $0000, $3005, $c3d4, $5407, $00ff
word    $0010, $0000, $0000, $0fc0, $0000, $0000, $fff0, $03ff, $0000, $0000, $000f, $0000, $3f00, $0000, $0000, $0000
word    $0000, $0000, $0000, $00c0, $0000, $f000, $0fff, $0000, $0000, $c000, $003f, $0000, $0fc0, $00c0, $0000, $3c30
word    $0000, $0000, $c000, $00ff, $f000, $ffff, $000f, $0000, $0030, $fffc, $000f, $0000, $33f0, $0000, $0000, $0fff
word    $0000, $0000, $ff00, $000f, $fc00, $3ffc, $0003, $0000, $0000, $fcff, $0000, $0000, $000f, $0000, $f000, $003f
word    $3000, $0300, $ffc0, $0003, $cfc0, $0fff, $0000, $0030, $0000, $03ff, $0000, $f3f0, $f00f, $f003, $fc03, $000f
word    $0000, $0000, $c3ff, $0000, $fffc, $003f, $00c0, $0000, $fc00, $003f, $00c0, $ffff, $0300, $0550, $ffc0, $0000
word    $0000, $c000, $c03f, $0000, $3fff, $0000, $0000, $0c00, $f3f0, $3000, $c003, $cff3, $0000, $0f55, $3fcc, $0000
word    $0000, $ffc3, $000f, $ff00, $0cf0, $0c0c, $0000, $0000, $000f, $0000, $3c00, $0c30, $40c0, $f0d5, $03c0, $0c00
word    $3000, $3ff0, $ff00, $3f33, $0cff, $3f3f, $033c, $0000, $0000, $0000, $0000, $00f0, $50f3, $fcf5, $0c33, $0000
word    $0030, $3fff, $0000, $0000, $cffc, $000f, $0000, $0000, $ffff, $f003, $f03f, $07ff, $5400, $ff3d, $f03f, $300f
word    $00f3, $0000, $fffc, $03ff, $c000, $0000, $fffc, $ffff, $d555, $557f, $ffff, $f575, $5505, $fc0d, $f0ff, $00ff
word    $0fff, $5f00, $5fd5, $fdd5, $000f, $0000, $ffff, $5557, $5555, $5555, $ffd5, $5557, $5545, $014d, $000f, $03f0
word    $c0ff, $555f, $5555, $f555, $0fff, $0f3c, $fc00, $5d5f, $5555, $5555, $5555, $0015, $5540, $0005, $0550, $0f05
word    $7c03, $5555, $5555, $5555, $0555, $c300, $c003, $5fff, $555f, $5555, $5555, $5545, $5571, $5551, $4555, $ff10
word    $5f00, $5555, $5555, $5555, $5555, $0f05, $3d5c, $7ffc, $5557, $5555, $5555, $5551, $5571, $5551, $1155, $fc40
word    $57f3, $1555, $5400, $5555, $5555, $7c3f, $70f5, $fc01, $7fff, $5555, $5555, $5551, $5571, $5551, $1101, $fc40
word    $55ff, $0155, $0000, $5555, $5555, $5035, $cc1f, $0055, $77ff, $555d, $5555, $1571, $0000, $1500, $1100, $fc40
word    $555f, $0055, $0000, $5555, $5555, $50f5, $55f0, $1540, $fff0, $5d5d, $5555, $1571, $0071, $5500, $13ff, $fc40
word    $5557, $f015, $000f, $5554, $d555, $c3f5, $fffd, $f7fd, $ffc1, $5d7f, $5555, $ffc5, $0043, $ff01, $403f, $ff10
word    $5577, $5145, $0151, $5554, $5555, $cfdd, $77c3, $fc37, $fc17, $ff77, $5557, $ffc5, $0043, $ff01, $010f, $ff05
word    $5555, $4551, $0554, $5550, $5555, $4fdd, $d7f7, $3f57, $01d5, $5d7f, $555f, $0015, $5540, $0005, $0000, $ffc3
word    $5555, $0411, $0504, $5550, $d555, $cfdd, $57cd, $0155, $57f7, $fff0, $57ff, $5555, $5540, $5505, $5105, $fc0f
word    $5555, $0411, $c504, $1550, $d500, $4fff, $170d, $0000, $0000, $ff04, $55ff, $1555, $5040, $5045, $5005, $c3f5
word    $5555, $c411, $c504, $0150, $5500, $43ff, $01cd, $5554, $5555, $f014, $77d7, $4555, $4145, $4515, $5101, $3f55
word    $5555, $4551, $c554, $0054, $fd50, $543f, $4400, $0154, $5500, $0551, $7fdf, $5155, $15c5, $1510, $5104, $f555
word    $5555, $53c5, $13f1, $4055, $fd55, $d543, $454f, $f154, $013f, $1540, $5dfc, $515f, $5715, $5515, $5005, $d555
word    $5555, $5415, $3405, $5055, $3f5f, $0554, $5150, $3154, $0400, $5415, $5fc0, $535f, $5c55, $5455, $5555, $5555
word    $5555, $1155, $4d54, $d005, $03ff, $f555, $5153, $415c, $5155, $d140, $fc17, $517f, $5c55, $5155, $5555, $5555
word    $5555, $c555, $53ff, $0050, $5000, $7f55, $5454, $415c, $0455, $4400, $00ff, $f3c0, $7155, $4555, $5555, $5555
word    $1555, $1540, $0000, $c3d5, $5555, $f0fd, $545c, $055c, $0455, $4400, $fd55, $f3c7, $c17d, $1555, $5554, $5555
word    $5755, $0015, $3f3f, $30ff, $0000, $0000, $551c, $055c, $0117, $1000, $f555, $fc15, $05ff, $5557, $5554, $5555
word    $5f5d, $1575, $3f3f, $c403, $5555, $3555, $5533, $c55c, $013c, $1000, $0000, $4054, $1ff0, $55c0, $d501, $77f5
word    $dffd, $3f7d, $0000, $0550, $0000, $0000, $55cc, $c55c, $04c3, $c400, $d555, $0003, $3f00, $5005, $d545, $7ffd
word    $ff7f, $00ff, $0000, $47f5, $5555, $5555, $ffc1, $c7fc, $043f, $0400, $0003, $1550, $0054, $00ff, $f550, $7ffd
word    $ffdf, $5400, $4000, $457d, $5555, $5555, $000d, $3f00, $5000, $1140, $5570, $5555, $0543, $c000, $ffff, $7fff
word    $03fd, $0554, $00c0, $c557, $ffff, $5557, $ffcd, $00fc, $0000, $0015, $55c4, $5555, $143d, $1455, $ff00, $ffff
word    $5000, $d555, $ffff, $057f, $0000, $fffc, $fc0f, $fffc, $ffff, $3fc0, $ffc5, $00ff, $3c00, $5455, $0015, $ffff
word    $5554, $557f, $5555, $455d, $5555, $0001, $c000, $fff0, $ffff, $03ff, $0004, $5500, $33f5, $547f, $1555, $f000
word    $d555, $d555, $f55f, $45ff, $5555, $5555, $c035, $ffc0, $ffff, $00ff, $55c4, $5555, $1155, $00f0, $5555, $0055
word    $7fff, $ffd5, $5f55, $717d, $5555, $5555, $0035, $ff30, $ffff, $0000, $55cc, $5555, $5155, $57ff, $5555, $5555
word    $55d5, $557d, $d5ff, $71f7, $5555, $5555, $0035, $cfc0, $c003, $000f, $55cc, $5555, $4555, $5fff, $dfd5, $557f
word    $f555, $d557, $755f, $715f, $5555, $5555, $0335, $0000, $0000, $c000, $573f, $5555, $4555, $57d5, $757f, $7ff5
word    $7575, $ff55, $0155, $f154, $ffff, $5557, $3f35, $0000, $0000, $0300, $ff3f, $ffff, $4fff, $5555, $5555, $7d55
word    $543d, $5fdd, $3555, $0154, $0000, $fffc, $f30f, $ffff, $ffff, $f003, $ff30, $03ff, $4000, $5d55, $0155, $5554
word    $5507, $5575, $5f55, $3555, $0000, $0000, $f300, $3ff3, $c0ff, $003f, $0000, $0000, $5400, $fd55, $0fff, $5554
word    $5507, $555f, $57f5, $1555, $0000, $0000, $f3f0, $3ff3, $0fff, $00ff, $00f3, $5400, $5455, $7d55, $d555, $555f
word    $f555, $5557, $555f, $37d5, $5554, $1555, $ffcc, $fff3, $3fff, $0ffc, $5000, $0155, $5400, $d555, $ffff, $5555
word    $7fd5, $0015, $5555, $f5f5, $0000, $0000, $fffc, $3ff0, $ffff, $fffc, $00c0, $fc00, $5503, $5555, $5555, $5555
word    $55fd, $0035, $5555, $f55f, $fffc, $003f, $fdfc, $f540, $d5ff, $fff0, $fc03, $0003, $fd54, $ffff, $5555, $5555
word    $555d, $500d, $d555, $c557, $0000, $0000, $5d5f, $5400, $5557, $d5fd, $0003, $5554, $5555, $4015, $ffff, $5557
word    $5555, $5405, $7555, $5555, $5555, $5555, $5d57, $5400, $5557, $5555, $5555, $5555, $5555, $0155, $5555, $5555












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





DAT 'SONG DATA

logoScreenSound
byte    NOTEON,0,72
byte    TIMEWAIT,8

byte    NOTEON,1,70
byte    TIMEWAIT,8

byte    NOTEON,2,68
byte    TIMEWAIT,8

byte    NOTEON,3,63
byte    TIMEWAIT,8

byte    NOTEON,4,51
byte    TIMEWAIT,7
byte    NOTEON,5,75
byte    TIMEWAIT,6
byte    NOTEON,6,87
byte    TIMEWAIT,5

byte    ENDOFSONG




titleScreenSong
byte    15     'number of bars
byte    28    'tempo
byte    8    'bar resolution

'ROOT BASS
byte    0, 36,SOFF,  36,SOFF,   34,  36,SOFF,  34
byte    1, 24,SOFF,  24,SOFF,   22,  24,SOFF,  22

'DOWN TO SAD
byte    0, 32,SNOP,  32,SOFF,   31,  32,SOFF,  31
byte    1, 20,SNOP,  20,SOFF,   19,  20,SOFF,  19 

'THEN FOURTH
byte    0, 29,SNOP,  29,SOFF,   27,  29,SOFF,  27
byte    1, 17,SNOP,  17,SOFF,   15,  17,SOFF,  15



byte    2,   48,SNOP,SOFF,  50, SNOP,SOFF,  51,SNOP
byte    2, SNOP,SOFF,  48,SNOP,   51,SNOP,  48,SNOP
byte    2,   53,SNOP,SNOP,  51, SNOP,SNOP,  50,SNOP
byte    2, SNOP,  51,SNOP,SNOP,   50,  51,  50,SNOP  

'melody
byte    2,   48,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
byte    2, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF      

'harmonies
byte    3,   44,SNOP,SNOP,  43, SNOP,SNOP,  41,SNOP
byte    3, SNOP,  39,SNOP,SNOP,   38,SNOP,SNOP,SNOP
byte    3, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF  


'SONG ------

byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF
byte    0,1,BAROFF

'verse 
byte    0,1,6,BAROFF
byte    0,1,7,BAROFF
byte    0,1,8,BAROFF
byte    0,1,9,BAROFF

byte    2,3,10,12,BAROFF
byte    2,3,13,BAROFF
byte    4,5,BAROFF
byte    4,5,11,14,BAROFF

'verse
byte    0,1,6,BAROFF
byte    0,1,7,BAROFF
byte    0,1,8,BAROFF
byte    0,1,9,BAROFF

byte    2,3,10,12,BAROFF
byte    2,3,13,BAROFF
byte    4,5,BAROFF
byte    4,5,11,14,BAROFF

byte    SONGOFF




DAT  'STRING DATA



'TANK NAMES
gfx_supertankname         byte    "Tank Tock",0
gfx_superthangname        byte    "Super Thang",0
gfx_class16name           byte    "Class XVI",0
gfx_happyfacename           byte    "Happy Face",0
gfx_moonmanname             byte    "Moon Man",0
  

'LEVEL NAMES
level0name              byte    "Moon Man's Lair",0
level1name              byte    "Wronskian Delta",0
level2name              byte    "Castle Destruction",0
'level3name              byte    "Hole",0
'level4name              byte    "Pokemon",0


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
