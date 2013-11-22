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
                        
  FRAMES = 2
  FRAMERATE = 10
  FRAMEPERIOD = 6000000 

  SCREEN_W = 128
  SCREEN_H = 64
  BITSPERPIXEL = 2
  SCREEN_BW = 16   
  SCREEN_BH = 8
  SCREENSIZE = SCREEN_W*SCREEN_H
  SCREENSIZEB = SCREEN_W*SCREEN_BH*BITSPERPIXEL*FRAMES

  SW1 = 1 << 24
  SW2 = 1 << 25
  SW3 = 1 << 26

  J_U = 1 << 12
  J_D = 1 << 13
  J_R = 1 << 14
  J_L = 1 << 15

  DIR_U = 2
  DIR_D = 3
  DIR_L = 0
  DIR_R = 1

  NL = 10
  TANKS = 2   'must be power of 2
  TANKSMASK = TANKS-1

  TANKTYPES = 5 'must be power of 2
  TANKTYPESMASK = TANKTYPES-1

  TANKHEALTHMAX = 10

  BULLETS = 20
  BULLETSMASK = BULLETS-1

  BULLETINGSPEED = 2

  XOFFSET1 = 16
  YOFFSET1 = 20

  COLLIDEBIT = $80
  TILEBYTE = COLLIDEBIT-1

  LEVELS = 3
  LEVELSMASK = LEVELS-1

  GO_GAME = 1
  GO_MENU = 2

  PAUSEMENU1_CHOICES = 3

  WIFI_RX = 22
  WIFI_TX = 23

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
  

  'DECIDES WHO CLICKED TO INITIALIZE THE GAME
  'if this message is sent, you start in starting location 1.
  'if it's received by an opponent, you start in location 2.
 ' UPDATEADVANCE = 10


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
        lcd     :               "lame_lcd"
        grfx    :               "lame_graphics"
        audio   :               "lame_audio_synth"
        pst     :               "lame_serial"

VAR
long    screenframe
long    screen[SCREENSIZEB/4]

byte    levelw
byte    levelh
byte    currentlevel
word    leveldata[LEVELS]
word    levelname[LEVELS]
byte    levelstarts[LEVELS*TANKS]

long    x
long    y    
long    tile
long    tilecnt
long    tilecnttemp

long    controls

long    xoffset
long    yoffset

long    tankgrfx[TANKS]
long    tankx[TANKS]
long    tanky[TANKS]
long    tankoldx
long    tankoldy
byte    tankolddir
byte    tankstartx[TANKS]
byte    tankstarty[TANKS]

byte    tankw[TANKS]
byte    tankh[TANKS]
byte    tankdir[TANKS]
byte    tankhealth[TANKS]
byte    tankon[TANKS]

long    tankxtemp
long    tankytemp
byte    tankwtemp
byte    tankhtemp

long    tanktypegrfx[TANKTYPES]
word    tanktypename[TANKTYPES]

byte    score[TANKS]
byte    oldscore

word    bullet
long    bulletx[BULLETS]
long    bullety[BULLETS]
byte    bulletspeed[BULLETS]
byte    bulletdir[BULLETS]
byte    bulleton[BULLETS]

long    bulletxtemp
long    bulletytemp

long    bacon

byte    collided
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
grfx.enableGrfx(@bacon, @screen, @screenframe)
lcd.start(@screen)
pst. StartRxTx(WIFI_RX, WIFI_TX, 0, 115200)

audio.Start

grfx.clearScreen
grfx.switchFrame

InitData

clicked := 0
LogoScreen
TitleScreen
TankSelect
LevelSelect                          
TankFaceOff          



menuchoice := GO_GAME
repeat
    if menuchoice == GO_GAME
        menuchoice := GameLoop
    elseif menuchoice == GO_MENU
        menuchoice := PauseMenu


PUB LogoScreen

grfx.clearScreen
grfx.switchFrame
grfx.clearScreen
grfx.sprite_trans(@teamlamelogo, 0, 3, 0)
grfx.switchFrame

audio.SetWaveform(3, 127)
audio.SetADSR(127, 10, 0, 10)
audio.PlaySequence(@logoScreenSound)  

repeat x from 0 to 150000 

audio.StopSong

PUB TitleScreen

audio.SetWaveform(1, 127)
audio.SetADSR(127, 127, 100, 127) 
audio.LoadSong(@titleScreenSong)
audio.PlaySong


choice := 1
repeat until choice == 0  
    controls := ina   
    grfx.switchFrame

    grfx.blit(@excitingtank)   

    if controls & (SW1+SW2+SW3) <> 0
          if clicked == 0
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
repeat until choice == 0

    controls := ina   
    grfx.switchFrame         
    grfx.clearScreen

    if controls & (J_U+J_D) <> 0
       if joyclicked == 0
          joyclicked := 1 
          if controls & J_U <> 0
            if yourtype <> 0
              yourtype--
            else
              yourtype := TANKTYPESMASK
          if controls & J_D <> 0
            yourtype++
            if yourtype > TANKTYPESMASK
              yourtype := 0

          pst.Char(UPDATETYPE)
          pst.Char(yourtype) 
    else
        joyclicked := 0

  
    if controls & (SW1+SW2+SW3) <> 0
      if clicked == 0
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
        


    grfx.sprite_trans(@tanklogo, 0, 0, 0)
    grfx.textbox(string("CHOOSE"), 6, 2)

    grfx.textbox(string("You"),2,3)
    grfx.textbox(string("Enemy"),10,3)
    
    grfx.textbox(tanktypename[yourtype],0,7)
    grfx.textbox(tanktypename[theirtype],9,7)
       
    grfx.textbox(string("vs."),7,5)
        
    grfx.sprite_trans(tanktypegrfx[yourtype], 3, 4, 3) 
    grfx.sprite_trans(tanktypegrfx[theirtype], 11, 4, 2) 

   ' grfx.textbox(string("At"),3,7)   
    'grfx.textbox(levelname[currentlevel],5,7)  


tankgrfx[yourtank] := tanktypegrfx[yourtype]
tankgrfx[theirtank] := tanktypegrfx[theirtype]

repeat tankindex from 0 to TANKSMASK
   tankw[tankindex] := word[tankgrfx[tankindex]][1]
   tankh[tankindex] := word[tankgrfx[tankindex]][2]







PUB LevelSelect

choice := 1
joyclicked := 0
repeat until choice == 0

    controls := ina   
    grfx.switchFrame
    grfx.clearScreen         


    if controls & (J_U+J_D) <> 0
       if joyclicked == 0
          joyclicked := 1 
          if controls & J_U <> 0
            if currentlevel <> 0
              currentlevel--
            else
              currentlevel := LEVELSMASK
          if controls & J_D <> 0
            currentlevel++
            if currentlevel > LEVELSMASK
              currentlevel := 0

          pst.Char(UPDATELEVEL)
          pst.Char(currentlevel)
    else
        joyclicked := 0
          

    
    if controls & (SW1+SW2+SW3) <> 0
      if clicked == 0
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


    grfx.sprite_trans(@tanklogo, 0, 0, 0)
    grfx.textbox(string("Level:"),0,2)                  
    grfx.textbox(levelname[currentlevel],5,2)

    'DRAW TILES TO SCREEN
    xoffset := 5
    yoffset := 2

    levelw := byte[leveldata[currentlevel]][0] 
    levelh := byte[leveldata[currentlevel]][1]
        
    tilecnt := 0
    tilecnttemp := 2
    if yoffset > 0
      repeat y from 0 to yoffset-1
        tilecnttemp += levelw
    repeat y from yoffset to yoffset+constant(5-1)
        repeat x from xoffset to xoffset+constant(SCREEN_BW-1)   
            tilecnt := tilecnttemp + x
            tile := (byte[leveldata[currentlevel]][tilecnt] & TILEBYTE) -  1
            grfx.box(@tilemap + (tile << 4), x-xoffset,y-yoffset+3)

        tilecnttemp += levelw

    
InitLevel




PUB TankFaceOff
         
choice := 1
repeat until choice == 0

    controls := ina   
    grfx.switchFrame         
    grfx.clearScreen

    grfx.sprite_trans(@tanklogo, 0, 0, 0)
    grfx.textbox(string("Prepare for battle..."),2,3)
    
    if controls & (SW1+SW2+SW3) <> 0
      if clicked == 0
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

clicked := 0
choice := 0                               
repeat while choice == 0

    controls := ina
    grfx.switchFrame 

      if tankon[yourtank] == 1   
          tankoldx := tankx[yourtank]
          tankoldy := tanky[yourtank]
          tankolddir := tankdir[yourtank]
          oldscore := score[yourtank]

          'TANK CONTROL
          'LEFT AND RIGHT   
          if controls & J_L <> 0
             tankdir[yourtank] := 0        

             tankx[yourtank]--
              if tankx[yourtank] < 0
                  tankx[yourtank] := 0
          if controls & J_R <> 0
              tankdir[yourtank] := 1
          
              tankx[yourtank]++
              if tankx[yourtank] > levelw - tankw[yourtank]
                  tankx[yourtank] := levelw - tankw[yourtank] 


          tankxtemp := tankx[yourtank] 
          tankytemp := tanky[yourtank]
          tilecnt := 0
          tilecnttemp := 2
          if tanky[yourtank] > 0
              repeat y from 0 to tanky[yourtank]-1
                   tilecnttemp += levelw
          repeat y from tankytemp to tankytemp+tankh[yourtank]-1
              repeat x from tankxtemp to tankxtemp+tankw[yourtank]-1 
                  tilecnt := tilecnttemp + x
           
                  tile := (byte[leveldata[currentlevel]][tilecnt] & COLLIDEBIT)
                  if tile <> 0
                         tankx[yourtank] := tankoldx 
              tilecnttemp += levelw

          repeat tankindex from 0 to TANKSMASK
              if tankon[tankindex]
                  if tankindex <> yourtank
                      collided := 1
                      if tankxtemp+tankw[yourtank]-1 < tankx[tankindex]
                         collided := 0
                      if tankxtemp > tankx[tankindex]+tankw[tankindex]-1
                         collided := 0
                      if tankytemp+tankh[yourtank]-1 < tanky[tankindex]
                         collided := 0
                      if tankytemp > tanky[tankindex]+tankh[tankindex]-1
                         collided := 0

                      if collided == 1
                         tankx[yourtank] := tankoldx    



       
      'UP AND DOWN   
          if controls & J_U <> 0
              tankdir[yourtank] := 2
              
              tanky[yourtank]--
              if tanky[yourtank] < 0
                  tanky[yourtank] := 0
          if controls & J_D <> 0
              tankdir[yourtank] := 3  

              tanky[yourtank]++
              if tanky[yourtank] > levelh - tankh[yourtank]
                  tanky[yourtank] := levelh - tankh[yourtank]
   
          tankxtemp := tankx[yourtank] 
          tankytemp := tanky[yourtank]
          tilecnt := 0
          tilecnttemp := 2
          if tanky[yourtank] > 0
              repeat y from 0 to tanky[yourtank]-1
                  tilecnttemp += levelw
          repeat y from tankytemp to tankytemp+tankw[yourtank]-1
              repeat x from tankxtemp to tankxtemp+tankh[yourtank]-1 
                  tilecnt := tilecnttemp + x
           
                  tile := (byte[leveldata[currentlevel]][tilecnt] & COLLIDEBIT)
                  if tile <> 0
                        tanky[yourtank] := tankoldy
              tilecnttemp += levelw

          repeat tankindex from 0 to TANKSMASK
              if tankon[tankindex] 
                  if tankindex <> yourtank
                      collided := 1
                      if tankxtemp+tankw[yourtank]-1 < tankx[tankindex]
                         collided := 0
                      if tankxtemp > tankx[tankindex]+tankw[tankindex]-1
                         collided := 0
                      if tankytemp+tankh[yourtank]-1 < tanky[tankindex]
                         collided := 0
                      if tankytemp > tanky[tankindex]+tankh[tankindex]-1
                         collided := 0

                      if collided == 1
                         tanky[yourtank] := tankoldy    


          'OFFSET CONTROL
          ControlOffset(yourtank)
 
    

 
           
           
          if controls & SW1 <> 0
            if clicked == 0
              clicked := 1
           
             ' choice := GO_MENU 'Go to menu
              
            '  yourtank++
             ' yourtank &= TANKSMASK

          elseif controls & SW2 <> 0
              if tankon[yourtank] == 1
                SpawnBullet(yourtank)
                bulletspawned := 1
            
          elseif controls & SW3 <> 0
            if clicked == 0
              clicked := 1
              {
              yourtype++
              if yourtype > TANKTYPESMASK
                yourtype := 0
              tankgrfx[yourtank] := tanktypegrfx[yourtype]
              tankw[yourtank] := word[tankgrfx[yourtank]][1]
              tankh[yourtank] := word[tankgrfx[yourtank]][2]
               }
          else
              clicked := 0
           



  
      else

          'TANK CONTROL
          'LEFT AND RIGHT   
          if controls & J_L <> 0
              xoffset--
              if xoffset < 0
                  xoffset := 0 
          if controls & J_R <> 0
              xoffset++
              if xoffset > levelw-SCREEN_BW
                  xoffset := levelw-SCREEN_BW


                  
          'UP AND DOWN   
          if controls & J_U <> 0
              yoffset-- 
              if yoffset < 0
                  yoffset := 0  
          if controls & J_D <> 0
              yoffset++
              if yoffset > levelh-SCREEN_BH
                  yoffset := levelh-SCREEN_BH  

           
          if controls & (SW1+SW2+SW3) <> 0
            if clicked == 0
              SpawnTank(yourtank, 0, 1)
              tankspawned := 1      
              
              clicked := 1
          else
            clicked := 0
           




      'HANDLE OPPONENT TANKS
      UpdateHandler
   
      'DRAW TILES TO SCREEN
      DrawMap

      

      'DRAW TANKS TO SCREEN        
      repeat tankindex from 0 to TANKS-1
          if tankon[tankindex] == 1
              tankxtemp := tankx[tankindex] - xoffset
              tankytemp := tanky[tankindex] - yoffset
              tankwtemp := tankw[tankindex]
              tankhtemp := tankh[tankindex]        
                                                                                    
              if (tankxtemp => 0) and (tankxtemp =< SCREEN_BW-tankw[yourtank]) and (tankytemp => 0) and (tankytemp =< SCREEN_BH - tankh[yourtank])

                if tankdir[tankindex] == DIR_D
                    grfx.sprite_trans(tankgrfx[tankindex], tankxtemp, tankytemp, 0)
                elseif tankdir[tankindex] == DIR_U       
                    grfx.sprite_trans(tankgrfx[tankindex], tankxtemp, tankytemp, 1)
                elseif tankdir[tankindex] == DIR_L       
                    grfx.sprite_trans(tankgrfx[tankindex], tankxtemp, tankytemp, 2)
                elseif tankdir[tankindex] == DIR_R       
                    grfx.sprite_trans(tankgrfx[tankindex], tankxtemp, tankytemp, 3)
          
                                                         
      'CONTROL EXISTING BULLETS -----
      BulletHandler

      'HUD OVERLY
      StatusOverlay

menureturn := choice

PUB PauseMenu : menureturn

choice := 0
repeat while choice == 0
       
    controls := ina   
    grfx.switchFrame         
    grfx.clearScreen

    grfx.sprite_trans(@tanklogo, 0, 0, 0)
    grfx.textbox(string(" PAUSE!"),5,2)


    if controls & (J_U+J_D) <> 0
       if joyclicked == 0
          joyclicked := 1 
          if controls & J_U <> 0
            if menuchoice <> 0
              menuchoice--
            else
              menuchoice := PAUSEMENU1_CHOICES
          if controls & J_D <> 0
            menuchoice++
            if menuchoice > PAUSEMENU1_CHOICES
              menuchoice := 0 
    else
        joyclicked := 0
         

    if controls & (SW1+SW2+SW3) <> 0
      if clicked == 0
        choice := GO_GAME
        clicked := 1
    else
      clicked := 0
      
    grfx.sprite_trans(@bulletgrfx, 3, 4+menuchoice, 0)
    grfx.textbox(string("Return to Game"),4,4)
    grfx.textbox(string("Change Level"),4,5)
    grfx.textbox(string("Change Tank"),4,6)
    grfx.textbox(string("Give Up?"),4,7)


if menuchoice == 1
    LevelSelect

elseif menuchoice == 2
    TankSelect

menureturn := GO_GAME



PUB InitData

currentlevel := 0
yourtype := 0
theirtype := 0

leveldata[0] := @MoonManLevel   
leveldata[1] := @WronskianDelta
leveldata[2] := @TheCastle
'leveldata[3] := @thehole
'leveldata[4] := @pokemon
           
levelname[0] := @level0name
levelname[1] := @level1name
levelname[2] := @level2name
'levelname[3] := @level3name
'levelname[4] := @level4name

levelw := byte[leveldata[currentlevel]][0] 
levelh := byte[leveldata[currentlevel]][1]

tanktypename[0] := @extremetankname   
tanktypename[1] := @extremethangname
tanktypename[2] := @gianttankname
tanktypename[3] := @happyfacename
tanktypename[4] := @moonmanname

tanktypegrfx[0] := @extremetank
tanktypegrfx[1] := @extremethang
tanktypegrfx[2] := @gianttank
tanktypegrfx[3] := @happyface
tanktypegrfx[4] := @moonman


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


bullet := 0
repeat bulletindex from 0 to BULLETSMASK
    bulleton[bulletindex] := 0 
    bulletx[bulletindex] := 0
    bullety[bulletindex] := 0
    bulletspeed[bulletindex] := 0
    bulletdir[bulletindex] := 0
bulletspawned := 0



PUB SpawnTank(tankindexvar, respawnindexvar, respawnflag)
    if respawnflag == 1
       respawnindex := (respawnindex + 1) & TANKSMASK
       tankx[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindex<<1)+0] 
       tanky[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindex<<1)+1]
    else
       tankx[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindexvar<<1)+0] 
       tanky[tankindexvar] := byte[@startlocations][(currentlevel<<2)+(respawnindexvar<<1)+1]
    tankon[tankindexvar] := 1
    tankhealth[tankindexvar] := TANKHEALTHMAX
    tankdir[tankindexvar] := 0
    

PUB DrawMap
       
      'DRAW TILES TO SCREEN           
      tilecnt := 0
      tilecnttemp := 2
      if yoffset > 0
        repeat y from 0 to yoffset-1
          tilecnttemp += levelw
      repeat y from yoffset to yoffset+constant(SCREEN_BH-1)
          repeat x from xoffset to xoffset+constant(SCREEN_BW-1)   
              tilecnt := tilecnttemp + x
              tile := (byte[leveldata[currentlevel]][tilecnt] & TILEBYTE) -  1
              grfx.box(@tilemap + (tile << 4), x-xoffset,y-yoffset)

          tilecnttemp += levelw


PUB ControlOffset(tankindexvar)

          xoffset := tankx[tankindexvar] - 7
          if xoffset < 0
              xoffset := 0      
          elseif xoffset > levelw-SCREEN_BW
              xoffset := levelw-SCREEN_BW
                        
          yoffset := tanky[tankindexvar] - 3
          if yoffset < 0
              yoffset := 0      
          elseif yoffset > levelh-SCREEN_BH
              yoffset := levelh-SCREEN_BH 


PUB UpdateHandler

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
                   
   
    

PUB SpawnBullet(tankindexvar)

      bulleton[bullet] := 1 
      bulletdir[bullet] := tankdir[tankindexvar]

      if bulletdir[bullet] == DIR_L
          bulletx[bullet] := tankx[tankindexvar]
          bullety[bullet] := tanky[tankindexvar]
            
      if bulletdir[bullet] == DIR_R
          bulletx[bullet] := tankx[tankindexvar] + tankw[tankindexvar] - 1
          bullety[bullet] := tanky[tankindexvar]
            
      if bulletdir[bullet] == DIR_U
          bulletx[bullet] := tankx[tankindexvar]
          bullety[bullet] := tanky[tankindexvar]
            
      if bulletdir[bullet] == DIR_D
          bulletx[bullet] := tankx[tankindexvar]
          bullety[bullet] := tanky[tankindexvar] + tankh[tankindexvar] - 1
                        
      bullet++
      if bullet > BULLETSMASK
          bullet := 0

      audio.PlaySound(6+tankindexvar,40)
          

PUB BulletHandler

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

            if (bulletxtemp => 0) and (bulletxtemp =< SCREEN_BW-1) and (bulletytemp => 0) and (bulletytemp =< SCREEN_BH - 1)            
  
            


               grfx.sprite_trans(@bulletgrfx, bulletxtemp , bulletytemp, 0)


               repeat tankindex from 0 to TANKSMASK
                  if tankon[tankindex]
                     collided := 1
                     if bulletx[bulletindex] < tankx[tankindex]
                         collided := 0
                     if bulletx[bulletindex] > tankx[tankindex]+tankw[tankindex]-1
                         collided := 0
                     if bullety[bulletindex] < tanky[tankindex]
                         collided := 0
                     if bullety[bulletindex] > tanky[tankindex]+tankh[tankindex]-1
                         collided := 0
                
                     if collided == 1
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




PUB StatusOverlay

   
    'STATUS HUD
    if tankon[yourtank] == 1   
        repeat x from 0 to ((tankhealth[yourtank]-1)) step 1
             if x < ((tankhealth[yourtank]-1)>>1)
                 grfx.box(@heartbox, x>>1, 7)
             else
                 if x & $1 == 0
                     grfx.box_ex(@heartbox, x>>1, 7, 3)
                 else
                     grfx.box(@heartbox, x>>1, 7)


    intarray[0] := 48+(score[yourtank]/10)
    intarray[1] := 48+(score[yourtank]//10)
    intarray[2] := 0

    grfx.textbox(@intarray, 0, 0)


    intarray[0] := 48+(score[theirtank]/10)
    intarray[1] := 48+(score[theirtank]//10)
    intarray[2] := 0

    grfx.textbox(@intarray, 14, 0)


DAT 'LEVEL DATA


tilemap
byte    $FF, $DB, $FF, $A5, $FF, $42, $FF, $81, $FF, $81, $FF, $42, $FF, $A5, $FF, $DB, $0, $0, $FF, $55, $FF, $AA, $FF, $FF, $0, $0, $FF, $55, $FF, $AA, $FF, $FF
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $55, $FF, $AA, $FF, $55, $FF, $AA, $FF, $55, $FF, $AA, $FF, $55, $FF, $AA
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $77, $33, $77, $55, $77, $33, $77, $55, $77, $33, $77, $55, $77, $33, $77, $55
byte    $0, $0, $40, $40, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $10, $10, $0, $0, $0, $0, $40, $40, $0, $0, $2, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $40, $40, $0, $0, $2, $2, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $0, $0, $0, $0, $40, $0, $0, $0, $0, $0
byte    $D0, $0, $A4, $0, $D0, $0, $E4, $0, $D0, $0, $A4, $0, $D0, $0, $E4, $0, $0, $0, $0, $0, $80, $0, $20, $0, $40, $0, $A8, $0, $D0, $0, $E4, $0
byte    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $E4, $0, $D0, $0, $A8, $0, $40, $0, $20, $0, $80, $0, $0, $0, $0, $0
byte    $FF, $0, $DD, $0, $AA, $0, $55, $0, $0, $0, $AA, $0, $0, $0, $0, $0, $2, $2, $2, $2, $2, $0, $6, $4, $6, $4, $2, $0, $2, $2, $2, $2
byte    $0, $0, $0, $0, $55, $0, $0, $0, $AA, $0, $55, $0, $BB, $0, $FF, $0, $1, $0, $2, $0, $4, $0, $8, $0, $10, $0, $20, $0, $40, $0, $80, $0
byte    $40, $40, $40, $40, $40, $0, $60, $20, $60, $20, $40, $0, $40, $40, $40, $40, $0, $0, $0, $0, $1, $0, $4, $0, $2, $0, $15, $0, $B, $0, $27, $0
byte    $27, $0, $B, $0, $15, $0, $2, $0, $4, $0, $1, $0, $0, $0, $0, $0, $27, $0, $B, $0, $25, $0, $B, $0, $27, $0, $B, $0, $25, $0, $B, $0
byte    $7, $0, $13, $10, $5D, $8, $B9, $B8, $ED, $44, $5D, $58, $B3, $0, $7, $0, $FF, $24, $BF, $1, $FF, $0, $FD, $10, $FF, $1, $FF, $84, $EF, $40, $FF, $8
byte    $CC, $0, $90, $10, $50, $50, $60, $40, $61, $41, $78, $58, $A9, $1, $D4, $0, $FF, $E3, $3D, $35, $CB, $A, $F5, $C4, $6B, $63, $1B, $12, $9D, $19, $CD, $9
byte    $CD, $9, $9D, $19, $1B, $12, $6B, $62, $F7, $C5, $CB, $A, $3D, $35, $FF, $CB, $F7, $24, $AE, $A6, $DB, $19, $7D, $7C, $AB, $A9, $D7, $56, $EA, $C8, $B7, $26
byte    $FF, $E7, $BC, $AC, $D3, $50, $EF, $23, $D6, $46, $D8, $C8, $B9, $98, $B3, $90, $B3, $B0, $B9, $98, $D8, $48, $D6, $56, $EF, $23, $D3, $D0, $AC, $AC, $FF, $CB
byte    $83, $0, $7D, $4, $7E, $40, $FF, $C1, $7F, $41, $7E, $40, $BE, $3C, $95, $14, $FF, $2, $FF, $40, $3C, $8, $41, $41, $14, $14, $C3, $C3, $FF, $3C, $FF, $C3
byte    $FF, $FF, $FF, $FC, $FF, $F3, $FE, $EE, $F8, $D8, $F4, $D4, $F1, $B0, $EB, $A8, $E3, $A0, $EB, $A8, $C7, $41, $D7, $50, $C7, $40, $D7, $51, $E3, $A0, $EB, $A8
byte    $E3, $A0, $EB, $68, $C7, $C1, $17, $10, $87, $80, $3F, $1, $FF, $0, $FF, $8, $FF, $24, $FF, $0, $3F, $0, $47, $41, $17, $10, $C7, $C0, $E3, $60, $EB, $A8
byte    $E3, $A0, $F1, $B0, $F4, $D4, $F9, $D9, $FE, $EE, $FF, $F3, $FF, $FC, $FF, $FF, $C7, $C7, $BB, $A3, $7D, $41, $7D, $41, $7D, $41, $7B, $43, $87, $87, $FF, $FF
byte    $FF, $C3, $FF, $3C, $C3, $C3, $28, $28, $82, $82, $3C, $4, $FF, $48, $FF, $1, $FF, $FF, $FF, $3F, $FF, $CF, $7F, $77, $9F, $9B, $2F, $2B, $8F, $D, $C7, $5
byte    $D7, $15, $C7, $5, $EB, $8A, $E3, $2, $EB, $A, $E3, $82, $D7, $15, $C7, $5, $D7, $15, $8F, $D, $2F, $2B, $1F, $1B, $7F, $77, $FF, $CF, $FF, $3F, $FF, $FF
byte    $D7, $15, $C7, $6, $E3, $3, $E8, $8, $F2, $82, $FE, $0, $FF, $0, $FF, $24, $FF, $10, $FF, $0, $FC, $80, $E1, $1, $E8, $8, $E3, $83, $D7, $16, $C7, $5
byte    $B1, $0, $EE, $E, $EA, $8A, $8E, $E, $CA, $4A, $EA, $A, $EE, $E, $71, $0, $0, $0, $FF, $1, $FB, $F9, $FB, $A9, $FB, $51, $3, $1, $FF, $1, $FE, $FE
byte    $0, $0, $FF, $0, $FF, $FF, $FF, $AA, $FF, $55, $0, $0, $FF, $0, $FF, $FF, $FF, $24, $BF, $1, $FF, $0, $7D, $10, $7F, $1, $BF, $84, $AF, $80, $DF, $48
byte    $DF, $44, $EF, $A1, $EF, $A0, $75, $50, $77, $51, $BB, $A8, $BB, $A8, $DD, $54, $DD, $54, $BB, $A8, $BB, $A8, $77, $51, $75, $50, $EF, $A0, $EF, $A1, $DF, $44
byte    $DF, $44, $BF, $81, $BF, $80, $7D, $10, $7F, $1, $FF, $44, $EF, $0, $FF, $8, $88, $88, $EE, $AA, $EE, $AA, $77, $55, $77, $55, $BB, $AA, $BB, $AA, $DD, $55
byte    $DD, $55, $EE, $AA, $EE, $AA, $77, $55, $77, $55, $BB, $AA, $BB, $AA, $DD, $55, $11, $10, $FE, $98, $FE, $14, $FE, $14, $FE, $14, $FE, $14, $FE, $58, $11, $10
byte    $DD, $55, $BB, $AA, $BB, $AA, $77, $55, $77, $55, $EE, $AA, $EE, $AA, $88, $88, $0, $0, $6F, $20, $6F, $27, $6F, $26, $6F, $25, $6C, $24, $6F, $20, $1F, $1F
byte    $DD, $55, $BB, $AA, $BB, $AA, $77, $55, $77, $55, $EE, $AA, $EE, $AA, $DD, $55, $8, $8, $AE, $AA, $AE, $AA, $97, $95, $97, $95, $AB, $8A, $AB, $8A, $B5, $85
byte    $B5, $85, $BA, $82, $BA, $82, $BD, $81, $BD, $81, $38, $38, $FE, $82, $3F, $3F, $3F, $3F, $FE, $82, $38, $38, $BD, $81, $BD, $81, $BA, $82, $BA, $82, $B5, $85
byte    $B5, $85, $AB, $8A, $AB, $8A, $97, $95, $97, $95, $AE, $AA, $AE, $AA, $8, $8, $1F, $11, $5F, $5B, $5F, $11, $5F, $5B, $5F, $51, $5F, $1B, $5F, $51, $1F, $1B
byte    $80, $0, $D1, $50, $E1, $20, $D1, $50, $E1, $20, $D1, $50, $E1, $20, $80, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $0, $0, $ED, $1, $ED, $1, $0, $0
byte    $7, $4, $77, $44, $77, $46, $38, $10, $BB, $2A, $C1, $81, $66, $66, $0, $0, $7, $4, $77, $44, $77, $44, $77, $44, $70, $40, $77, $44, $77, $44, $77, $44
byte    $0, $0, $ED, $1, $ED, $1, $0, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $0, $0, $66, $66, $1C, $14, $BB, $8A, $83, $2, $77, $44, $77, $44, $77, $44
byte    $73, $41, $29, $21, $1D, $1, $19, $11, $6, $0, $E, $8, $6, $4, $0, $0, $6, $4, $E, $8, $6, $4, $8, $8, $1D, $10, $D, $0, $31, $20, $7B, $60
byte    $0, $0, $66, $64, $16, $4, $B0, $0, $AF, $0, $3, $0, $6B, $40, $6B, $40, $6B, $40, $6B, $40, $3, $0, $2F, $0, $B0, $0, $D6, $44, $66, $24, $0, $0
byte    $E0, $0, $D0, $0, $A0, $0, $D0, $0, $E0, $0, $D0, $0, $A0, $0, $D0, $0, $F8, $0, $E6, $6, $DC, $1C, $BB, $29, $83, $0, $77, $52, $77, $61, $77, $40
byte    $7, $4, $77, $44, $77, $46, $B8, $20, $BB, $3A, $C1, $1, $E6, $6, $F8, $0, $55, $55, $55, $0, $55, $0, $55, $0, $55, $0, $55, $0, $55, $0, $55, $55
byte    $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $0, $0, $77, $44, $77, $44, $77, $44, $70, $40, $77, $44, $77, $44, $77, $44
byte    $7, $4, $77, $44, $77, $44, $77, $44, $70, $40, $77, $44, $77, $44, $0, $0, $33, $0, $44, $44, $55, $55, $55, $11, $11, $0, $44, $44, $55, $55, $55, $11
byte    $11, $0, $44, $44, $55, $55, $55, $11, $11, $0, $44, $44, $11, $11, $CC, $0, $BE, $BE, $FF, $C1, $F3, $B2, $C1, $80, $C1, $80, $F3, $B2, $FF, $C1, $BE, $BE
byte    $DD, $55, $EB, $AA, $EB, $AA, $77, $55, $77, $55, $BA, $AA, $BA, $AA, $DD, $55, $DD, $55, $BA, $AA, $BA, $AA, $75, $51, $75, $51, $E8, $A8, $EE, $A2, $8F, $8F
byte    $5D, $55, $AE, $AA, $AE, $AA, $97, $95, $97, $95, $AB, $8A, $AB, $8A, $B5, $85, $B5, $85, $AB, $8A, $AB, $8A, $97, $95, $97, $95, $AE, $AA, $AE, $AA, $5D, $55
byte    $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $BE, $80, $C, $C, $5E, $12, $4C, $C, $5E, $12, $4C, $C, $5E, $12, $4C, $C, $1E, $12
byte    $0, $0, $7E, $7E, $7E, $52, $7E, $52, $7E, $52, $6E, $42, $6E, $6E, $0, $0, $0, $0, $6E, $6E, $6E, $42, $7E, $52, $7E, $52, $7E, $52, $7E, $7E, $0, $0
byte    $11, $0, $6F, $21, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $25, $6F, $21, $7F, $6E
byte    $7F, $7F, $FF, $81, $7F, $7F, $FF, $81, $7F, $7F, $FF, $81, $7F, $7F, $FF, $81, $7F, $7F, $FF, $81, $7F, $7F, $FF, $55, $AA, $AA, $FF, $84, $EF, $40, $FF, $8
byte    $FF, $24, $BF, $1, $FF, $0, $FF, $55, $AA, $AA, $FF, $81, $7F, $7F, $FF, $81, $FF, $CF, $E0, $A0, $DE, $5E, $DF, $41, $DF, $41, $DE, $5E, $E0, $A0, $FF, $CF
byte    $FF, $24, $BF, $1, $FF, $0, $FF, $55, $AA, $AA, $FF, $84, $EF, $40, $FF, $8, $0, $0, $3F, $4, $5F, $1F, $6F, $21, $77, $21, $7B, $63, $7D, $24, $7E, $3C
byte    $FF, $24, $BF, $1, $FF, $0, $7F, $7F, $FF, $81, $FF, $84, $EF, $40, $FF, $8, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF



'tileset: monotiles 
'levelname MoonManLevel
MoonManLevel
byte    32, 32
byte        1,  1,  1,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  3,  4,  3,  4,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  1,  1,  1
byte        1,  3,  3,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  4,  3,  4,  3,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  3,  3,  1
byte        1,  3,  3,  1,  2,  2,  2,  4,  4,  4,  2,  2,  2,  1,  3,  4,  3,  4,  1,  2,  2,  2,  4,  4,  4,  2,  2,  2,  1,  3,  3,  1
byte        1,  1,  1,  1,133,133,133,  6,  6,  6,133,133,133,  1,  4,  3,  4,  3,  1,133,133,133,  6,  6,  6,133,133,133,  1,  1,  1,  1
byte        6,  6,  6,133,133,  7,  7,  8,  9, 10,  5,  8,133,  1,  1,  1,  1,  1,  1,133, 10, 10,  5,  7,  7,  8,  5,133,133,  6,  6,  6
byte        6,  6,  6,133,  8,  8,  8,  5, 10,  5,  7,  5,133,133,  6,  6,  6,  6,133,133,  8,  7,  5, 10,  5,  5,  8,  8,133,  6,  6,  6
byte        6,  6,  6,133,  9,  5,  7,  5, 10,  5,  9,  8,  8,133,  6,  6,  6,  6,133,  5, 10,  5,  5,  5,  7,  7,  7,  5,133,  6,  6,  6
byte        3,  3,  4,  2,  5,  7, 10,  8,  9,  5,  9,  8,  8,  2,  4,  3,  3,  4,  2,  5,  5,  5,  5, 10,  7,  8, 10,  5,  2,  4,  3,  3
byte        3,  3,  4,  2,  5,  9,  7,  8,  9,  5,  8,  9,  7,  2,  4,  3,  3,  4,  2, 10,  5,  5,  5,  7,  7,  7,  5,  5,  2,  4,  3,  3
byte        3,  3,  4,  2,  7,  7,  7,  7,  7,  7,  9,  5,  7,  2,  4,  4,  4,  4,  2,  7,  7, 10,  5,  7,  5,  5,  5, 10,  2,  4,  3,  3
byte        6,  6,  6,133,  5,  5,  5,  9,  7,  7,  5,  5,  7,  9,  6,  6,  6,  6,  5,  7,  7,  7,  5,  5, 10,  7,  7,  8,133,  6,  6,  6
byte        6,  6,  6,133,  8,  9, 10,  7,  7,  8,  7,  8,  9,133,133,133,133,133,133,  8,  8,  8,  7,  7, 10,  7,  7,  7,133,  6,  6,  6
byte        6,  6,  6,133,133,133,  8,  5,  7,  7,  8,  5,133,133, 11, 11, 11, 11,133,133,  8,  5,  5, 10,  8,  8,133,133,133,  6,  6,  6
byte        1,  1,  1,  1,  1,133,133,133,133,133,133,133,133, 12, 13,  1,  1, 13, 14,133,133,133,133,133,133,133,133,  1,  1,  1,  1,  1
byte        3,  4,  3,  4,  1, 15, 16, 16, 16, 16, 16, 17,  2, 13,  1,  4,  4,  1, 13,  2, 15, 16, 16, 16, 16, 16, 17,  1,  3,  4,  3,  4
byte        4,  3,  4,  3,  1, 15,  5,  5, 18,  5, 18, 17,  2,  1,  4,  3,  3,  4,  1,  2, 15,  5, 18,  5, 18,  5, 17,  1,  4,  3,  4,  3
byte        3,  4,  3,  4,  1, 15, 18,  5,  5, 18,  5, 17,  2,  1,  4,  3,  3,  4,  1,  2, 15, 18,  5,  5, 18, 18, 17,  1,  3,  4,  3,  4
byte        4,  3,  4,  3,  1, 15, 19, 19, 19, 19, 19, 17,  2, 13,  1,  4,  4,  1, 13,  2, 15, 19, 19, 19, 19, 19, 17,  1,  4,  3,  4,  3
byte        1,  1,  1,  1,  1,133,133,133,133,133,133,133,133, 20, 13,  1,  1, 13, 21,133,133,133,133,133,133,133,133,  1,  1,  1,  1,  1
byte        6,  6,  6,133,133,133,  8,  5,  9,  8,  8,  8,133,133, 22, 22, 22, 22,133,133, 10,  8,  5, 10,  8,  8,133,133,133,  6,  6,  6
byte        6,  6,  6,133,  5,  7,  5,  9,  9,  9,  5,  8, 10,133,133,133,133,133,133,  8,  7,  5,  5,  5,  8,  8,  8,  7,133,  6,  6,  6
byte        6,  6,  6,133,  8,  5,  7,  5,  9,  9,  8,  5,  8,  9,  6,  6,  6,  6,  8, 10,  7,  8,  5,  7,  9,  9, 10,  7,133,  6,  6,  6
byte        3,  3,  4,  2,  5,  7,  5,  8,  5,  9,  8,  8,  7,  2,  4,  4,  4,  4,  2,  7,  8,  5,  7,  7,  5,  5,  8,  7,  2,  4,  3,  3
byte        3,  3,  4,  2,  8,  7,  7,  9,  9,  5,  5,  8,  8,  2,  4,  3,  3,  4,  2,  5,  5, 10,  7,  7, 10,  5,  5,  5,  2,  4,  3,  3
byte        3,  3,  4,  2,  8,  9,  9,  9,  8,  5,  5,  7,  9,  2,  4,  3,  3,  4,  2,  8,  8,  5,  5,  7,  5,  5,  5,  7,  2,  4,  3,  3
byte        6,  6,  6,133,  7,  7,  9,  5,  8,  5,  7,  7,  8,133,  6,  6,  6,  6,133,  8,  7,  7,  7,  5,  5,  5,  7,  7,133,  6,  6,  6
byte        6,  6,  6,133,  8,  7,  5,  5,  9,  5,  5,  8,133,133,  6,  6,  6,  6,133,133,  8,  7,  8,  5,  5,  8, 10,  8,133,  6,  6,  6
byte        6,  6,  6,133,133,  8,  8,  9,  5,  8,  7,  8,133,  1,  1,  1,  1,  1,  1,133,  7,  7,  7,  5,  7,  7,  8,133,133,  6,  6,  6
byte        1,  1,  1,  1,133,133,133,  6,  6,  6,133,133,133,  1,  3,  4,  3,  4,  1,133,133,133,  6,  6,  6,133,133,133,  1,  1,  1,  1
byte        1,  3,  3,  1,  2,  2,  2,  4,  4,  4,  2,  2,  2,  1,  4,  3,  4,  3,  1,  2,  2,  2,  4,  4,  4,  2,  2,  2,  1,  3,  3,  1
byte        1,  3,  3,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  3,  4,  3,  4,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  3,  3,  1
byte        1,  1,  1,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  4,  3,  4,  3,  1,  2,  2,  2,  3,  3,  3,  2,  2,  2,  1,  1,  1,  1

'tileset: monotiles 
'levelname WronskianDelta
WronskianDelta
byte    50, 38
byte      151, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,  2,  2,  2,  2, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,153,151,153,151,153,151,153,151, 24, 24, 24, 24
byte      153, 24, 24, 24, 24, 26, 27, 24, 24, 24, 24, 24, 24,  2,  2,  2,  2, 24, 24, 24, 24, 26, 27, 24, 24, 24, 24, 28, 28, 28, 28, 28, 24, 24, 24, 24, 24, 24,151,153,151,153,151,153,151,153, 24, 24, 24, 24
byte      151, 24, 24, 24, 24, 29, 30, 24, 24, 24, 24, 24, 24,  2,  2,  2,  2, 24, 24, 24, 24, 29, 30, 24, 24, 24, 28, 28, 24, 24, 24, 28, 28, 28, 24, 24, 24, 24,153,151,153,151,153,151,153, 24, 24, 24, 24, 24
byte      153, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,159,160, 13, 13,161,159,162,163, 24, 24, 24, 24, 24, 24, 28, 24, 24, 24, 24, 24, 24, 28, 28, 24, 24, 24, 24,153,151,153,151,153,151, 24, 24, 24, 24, 24
byte      151, 24, 24, 24, 24, 24, 24, 24, 24, 24,164,162,162,165, 13, 13, 13,166, 13,161,162,162,163, 24, 24, 24, 28, 24, 24, 24, 24, 24, 24, 24, 28, 28, 24, 24, 24, 24,153, 24,153,151,153, 24, 24, 24, 24, 24
byte      153, 24, 24, 24, 24, 24, 24, 24, 24, 24,160, 13,166, 13, 13, 13, 13, 13, 13, 13, 13, 13,161,162,162,  6,  6,  6,162,162,162,162,162,162,163, 24, 28, 28, 28, 24, 24, 24, 24,153, 24, 24, 24, 24, 24, 24
byte      159,164,162,162,162,162,159,  6,  6,  6,159, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,166,141,  6,  6,  6,141, 13, 13,166, 13,166,167, 24, 24, 24, 28, 28, 28, 24, 24, 24, 24, 24, 24, 24, 24, 24
byte      162,165, 13, 13, 13, 13,141,  6,  6,  6,141, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,168,169,169,169,  6,  6,  6,169,169,169,169,169,170,161,162,163, 24, 24, 24, 28, 28, 24, 24, 24, 24, 24, 24, 24, 24
byte       13, 13, 13, 13, 13,168,159,  6,  6,  6,159,169,169,169,169,169,170, 13, 13, 13,166,167,151, 24, 24, 24, 26, 27, 24, 24, 24, 24, 24,160, 13,166,167, 24,151, 24, 24, 24, 24, 24, 28, 24, 24, 24, 24, 24
byte       13, 13, 13, 13,168,171, 24, 24, 28, 24, 24,151, 24, 24, 24,151,172,169,170, 13,168,171,153, 24, 24, 24, 29, 30, 24, 24, 24, 24, 24,160, 13, 13,167,151,153,151, 24, 24, 24, 24, 28, 24, 24, 24, 24, 24
byte       13, 13, 13,168,171, 24, 24, 24, 28, 24, 24,153, 24, 24, 24,153,151,151,160, 13,161,162,162,162,163, 24, 24, 24, 24, 24,159,  6,  6,159, 13, 13,167,153,151,153,151, 24, 24, 28, 28, 24, 24, 24, 24, 24
byte       13, 13, 13,167,151, 24, 24, 24, 28, 24, 24, 24, 24, 24, 24, 24,153,153,160, 13, 13, 13, 13, 13,161,162,162,162,162,162,165,  6,  6,141, 13, 13,167, 24,153, 24,153, 24, 28, 28, 24, 24, 24, 24, 24, 24
byte       13, 13, 13,167,153, 24, 24, 24, 28, 24, 24, 24, 24, 24, 24, 24, 24,159,160, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,141,  6,  6,141, 13, 13,161,163, 24, 24, 24, 24, 28, 24, 24, 24, 24,151, 24,151
byte       13, 13, 13,161,163, 24, 24, 24, 24, 24, 28, 24, 24, 24, 24, 24, 24,164,165, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,141,  6,  6,141, 13, 13, 13,167, 24, 24, 24, 24, 28, 24,151, 24,151,153,151,153
byte       13, 13, 13, 13,167, 24, 24, 24, 24, 24, 28, 24, 24, 24, 24, 24,151,160, 13, 13, 13, 13, 13, 13,166, 13,168,169,170,166,168,  6,  6,169,170, 13, 13,167, 24, 24, 24, 24, 24, 24,153,151,153,151,153,151
byte       13, 13, 13, 13,167,151, 24, 24, 24, 24, 28, 24, 24, 24, 24,151,153,160, 13, 13, 13, 13, 13,168,169,169,171,159,172,169,159, 24, 24,159,160, 13, 13,167, 24, 24, 24, 24, 28, 24,173,153,151,153,151,153
byte       13, 13, 13, 13,167,153, 24, 24, 28, 24, 24, 24, 24, 24,151,153,164,165, 13, 13,168,169,169,171, 24,151,159,151, 24,151, 24, 24, 24, 24,160, 13, 13,167, 24, 24, 24, 24, 24, 24, 24, 24,153,159,153,151
byte       13, 13, 13, 13,161,162,163, 24, 28, 28, 24, 24, 24, 24,153,164,165, 13, 13,168,171, 24, 24,159,151,153,151,153, 24,153, 24, 24, 24, 24,160, 13, 13,167, 24, 24,174, 24, 28, 24,174,159, 24, 24, 24,153
byte       13, 13, 13, 13, 13, 13,161,159, 24, 28, 24, 24, 24,164,162,165, 13, 13,168,171, 24, 24, 24, 24,153,151,153, 24, 24, 24, 24, 24, 24, 24,160, 13, 13,167, 24, 24,175,  6,  6,  6,175,162,162,162,162,163
byte       13, 13, 13, 13, 13, 13,141,161,  6,  6,  6, 24,151,160, 13, 13, 13,168,171, 24, 28, 24, 24, 24, 24,153, 24, 24, 24, 24, 24, 24, 24, 24,160, 13, 13,161,162,162,175,  6,  6,  6,175, 13, 13, 13, 13,161
byte       13, 13, 13, 13, 13, 13,166, 13,  6, 13,  6,  6,153,160, 13, 13,168,171, 24, 26, 27, 28, 28, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,160, 13, 13, 13, 13, 13,175,  6,  6,  6,175, 13, 13, 13, 13, 13
byte       13, 13, 13, 13, 13, 13,141,166, 13, 13, 13,  6,162,165, 13, 13,167, 24, 24, 29, 30, 24, 28, 28, 28, 24, 24, 24, 24,176,177,178,179, 24,160, 13, 13,166, 13, 13,175,  6,  6,  6,175, 13, 13,166, 13, 13
byte       13, 13, 13, 13, 13, 13,141, 13, 13,  6, 13, 13, 13, 13, 13,166,167, 24, 24, 24, 24, 24, 24, 24, 28, 24, 24, 24, 24,180,181,182,183,164,165, 13, 13, 13,168,169,184,  6,  6,  6,184,169,169,170, 13, 13
byte       13, 13, 13, 13, 13, 13,166, 13, 13, 13,  6, 13, 13, 13, 13,168,171, 24, 24, 24, 24, 24, 24, 24, 28, 24, 24, 24, 24,180,181,185,183,160, 13, 13, 13, 13,167, 24, 24, 24, 28, 24, 24, 24, 24,160, 13, 13
byte       13, 13, 13, 13, 13, 13,141, 13, 13,  6, 13, 13, 13, 13, 13,167, 24,151, 24, 24, 24, 24, 24, 24, 28, 24, 24, 24, 24,186,187,188,189,160, 13, 13, 13, 13,167, 24, 24, 24, 24, 28,151, 24,151,160, 13, 13
byte       13, 13, 13, 13, 13, 13,166,168,  6,  6,  6,170, 13, 13, 13,167,151,153,151, 24, 24, 24, 24, 24, 28, 24, 24,159,173,190,191,190,190,160, 13, 13, 13, 13,167, 24, 24, 24, 28, 28,153,151,153,172,170, 13
byte       13, 13, 13, 13, 13, 13,168,159, 24, 24, 24,159, 13, 13, 13,167,153,151,153,151, 24, 24, 24, 24, 28, 28, 28, 28, 28, 28, 28,164,162,165, 13,166, 13, 13,167, 24, 24, 24, 28, 28, 24,153,151, 24,172,170
byte       13, 13, 13, 13, 13,168,171, 24, 24, 24,159,172,170, 13, 13,167, 24,153,151,153, 24, 24, 24, 24, 28, 28, 24, 24, 24,159,162,165,141,141,166,141,166,141,159, 24, 24, 24, 24, 28, 24,151,153, 24, 24,172
byte       13, 13, 13,168,169,171,151, 24, 24, 24, 24,151,160, 13, 13,161,163,151,153,151, 24, 24, 24, 24, 24, 28, 28, 24, 24,130,  2, 13,  2, 13, 13, 13, 13,  2,130, 24, 24, 24, 24, 28, 24,153,151, 24, 24, 24
byte       13, 13,168,171,151,159,153, 24, 24, 24, 24,153,160, 13, 13, 13,167,153,151,153, 24, 24, 24, 24, 24, 24, 24, 28, 28,130,  2, 13, 13, 13, 13, 13,  2, 13,130, 24, 24, 24, 24, 28, 24,151,153, 24, 24,151
byte       13,168,171,151,153, 24, 24, 24, 24, 24, 24, 24,160, 13, 13, 13,167,151,153,151, 24, 24, 24, 24, 24, 24, 24, 24, 24,130, 13,  2, 13, 13, 13, 13, 13,  2,130, 24, 24, 24, 28, 24, 24,153, 24, 24,151,153
byte       13,167,151,153,151, 24, 24, 24, 24, 24, 24, 24,172,170, 13, 13,167,153,151,153,151, 24,151, 24,151, 24, 24, 24, 24,159, 13, 13, 13, 13, 13, 13,168,169,159, 24, 24, 28, 28, 24, 24, 24, 24, 24,153,151
byte       13,167,153,151,153, 24, 24, 24, 24, 24, 24, 24, 24,160, 13, 13,161,163,153, 24,153,151,153,151,153, 24, 24,164,162,165, 13, 13, 13, 13, 13, 13,167, 24, 24, 24, 24, 28, 24, 24, 24, 24, 24, 24,151,153
byte       13,161,163,153,151, 24, 24, 24, 24, 24, 24, 24,159,165, 13, 13, 13,161,163, 24, 24,153, 24,153, 24,164,162,165, 13, 13, 13, 13, 13, 13,168,169,171, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,151,153,151
byte       13, 13,167,151,153,151, 24,151,159,  6,  6,  6,165, 13, 13, 13, 13, 13,161,163, 24, 24,164,162,162,165, 13, 13, 13, 13, 13, 13, 13, 13,167,151, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,153,151,153
byte       13, 13,167,153, 24,153, 24,153,164,  6, 13, 13, 13, 13, 13, 13, 13, 13, 13,161,162,162,165, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,167,153, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,151,153,151
byte       13, 13,161,162,162,162,162,162,165, 13, 13,  6, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,168,169,169,171, 24,151, 24,151, 24, 24, 24, 24, 24,151, 24, 24,153,151,153
byte       13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,167, 24,151, 24,151,153,151,153,151, 24, 24, 24,151,153,151, 24,151,153,151

'tileset: monotiles 
'levelname TheCastle
TheCastle
byte    30, 30
byte      145,192,193,194,194,194,194,194,195,192,194,194,196,193,194,194,196,193,194,194,195,192,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,195,192,194,194,196,193,194,194,196,193,194,194,195,192,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,195,192,194,194,196,193,197,198,196,193,194,194,195,192,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,199,200,194,194,196,193,  5,  5,196,193,194,194,199,200,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,196,193,194,194,196,193, 73, 73,196,193,194,194,196,193,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,196,193,  1,  3, 74, 75,  1,  1, 74, 75,  3,  1,196,193,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,196,193,  1,  3,  3,  1,  1,  1,  1,  3,  3,  1,196,193,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,196,193,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,196,193,194,194,194,194,194,196,195,143
byte      145,192,193,194,194,194,194,194,196,193,194,194,194, 76, 76, 76, 76,194,194,194,196,193,194,194,194,194,194,196,195,143
byte      145,192, 75,  3,  3,  3,  3,  3,196,193,194,194,194, 76, 76, 76, 76,194,194,194,196,193,  3,  3,  3,  3,  3, 74,195,143
byte      145,192,205,205,205,205,205,174, 74, 75,174,205,205,  1,  1,  1,  1,205,205,174, 74, 75,174,205,205,205,205,205,195,143
byte      145,192,194,194,194,194,194,184,205,205,184,194,194,  1,  1,  1,  1,194,194,184,205,205,184,194,194,194,194,194,195,143
byte      145,192, 13, 13, 13, 13, 13,206,194,194,207, 13,141,  1,  1,  1,  1,141, 13,206,194,194,207, 13, 13, 13, 13, 13,195,143
byte      145,192,205,205,205,205,205,205,205,205,205,205,205,  1,  1,  1,  1,205,205,205,205,205,205,205,205,205,205,205,195,143
byte      145,192,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  1,  1,  1,  1,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,  3,195,143
byte      145,192,  3,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,  3,  3,  3,  3,  3,  3,  1,  1,  1,  1,  1,  1,  3,  3,  3,  3,  3,  3,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,  3,174,205,205,174,  3,  1,  1,  1,  1,  1,  1,  3,174,205,205,174,  3,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,151,175,194,194,175,151,  1,  1,  1,  1,  1,  1,151,175,194,194,175,151,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,153,175,141,141,175,153,  1,  1,  1,  1,  1,  1,153,175,141,141,175,153,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,  3,  2,  2,  2,  2,  3,  1,  1,  1,  1,  1,  1,  3,  2,  2,  2,  2,  3,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,  3,  2,  2,  2,  2,  3,  1,  1,  1,  1,  1,  1,  3,  2,  2,  2,  2,  3,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,151,175,141,141,175,151,  1,  1,  1,  1,  1,  1,151,175,141,141,175,151,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,153,175, 13, 13,175,153,  1,  1,  1,  1,  1,  1,153,175, 13, 13,175,153,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,  3,175, 13, 13,175,  3,  1,  1,  1,  1,  1,  1,  3,175, 13, 13,175,  3,  1,  1,  1,  3,195,143
byte      145,192,194, 76, 76, 76,194,184,205,205,184,  3,  1,  1,  1,  1,  1,  1,  3,184,205,205,184,194, 76, 76, 76,194,195,143
byte      145,192,  3,  1,  1,  1,  3,184, 13, 13,184,  3,  1,  1,  1,  1,  1,  1,  3,184, 13, 13,184,  3,  1,  1,  1,  3,195,143
byte      145,192,  3,  1,  1,  1,  3,175, 13, 13,175,  3,  1,  1,  1,  1,  1,  1,  3,175, 13, 13,175,  3,  1,  1,  1,  3,195,143
byte      145,192,  3,  3,  3,  3,  3,175, 13, 13,175,  3,  1,  1,  1,  1,  1,  1,  3,175, 13, 13,175,  3,  3,  3,  3,  3,195,143
 
startlocations
'moonman
byte        1,1
byte        28,28

'wronskian
byte        7,12
byte        42,31

'thecastle
byte        14,6
byte        14,27















DAT 'SPRITE DATA


extremetank
word    $40  'frameboost
word    $2, $2   'width, height
byte    $0, $1, $D6, $D6, $FE, $38, $FF, $E9, $0, $0, $1A, $12, $B7, $87, $B7, $85, $BF, $8D, $BF, $9, $DE, $D6, $0, $0, $D4, $D4, $FF, $39, $FF, $E8, $1E, $11
byte    $E4, $A4, $C3, $83, $C3, $80, $E3, $A1, $1C, $90, $0, $C0, $4, $E4, $D, $ED, $D, $ED, $5, $E4, $0, $C0, $4, $84, $C3, $83, $C3, $80, $E3, $A1, $FC, $B0
byte    $0, $1, $6F, $6F, $FF, $48, $17, $17, $38, $38, $7E, $66, $7E, $40, $7F, $41, $7F, $41, $7E, $40, $7E, $46, $38, $30, $7F, $5F, $FF, $48, $FF, $9F, $E0, $E1
byte    $F0, $A0, $F7, $A7, $F7, $A7, $F0, $A0, $0, $80, $0, $C0, $12, $92, $37, $A7, $37, $A1, $12, $92, $0, $C0, $0, $80, $F0, $A0, $F7, $A4, $F7, $A4, $F3, $A3
byte    $0, $3F, $80, $BF, $80, $87, $B0, $B1, $B6, $B0, $B6, $80, $B6, $80, $B2, $80, $B0, $80, $BD, $B5, $4F, $49, $EF, $D, $F6, $56, $F0, $11, $F0, $1F, $F0, $FF
byte    $0, $F8, $33, $DA, $4B, $C2, $93, $12, $B3, $A2, $83, $2, $83, $82, $93, $12, $B3, $A2, $83, $2, $80, $80, $97, $17, $B7, $A4, $47, $85, $37, $E4, $2, $F2
byte    $F0, $FF, $F0, $1F, $F0, $11, $F6, $56, $EF, $D, $4F, $49, $BD, $B5, $B0, $80, $B2, $80, $B6, $80, $B6, $80, $B6, $B0, $B0, $B1, $80, $87, $80, $BF, $0, $3F
byte    $2, $F2, $37, $E4, $47, $85, $B7, $A4, $97, $17, $80, $80, $83, $2, $B3, $A2, $93, $12, $83, $82, $83, $2, $B3, $A2, $93, $12, $4B, $C2, $33, $DA, $0, $F8

extremethang
word    $40  'frameboost
word    $2, $2   'width, height
byte    $4, $7, $F8, $3, $F8, $1, $9A, $2, $9A, $0, $FA, $0, $FA, $0, $6, $4, $6, $4, $FA, $0, $FA, $0, $9A, $0, $9A, $2, $F8, $1, $F8, $3, $4, $7
byte    $2, $FE, $1, $FC, $5, $FC, $D, $D8, $D, $18, $4D, $48, $2E, $28, $2A, $A8, $2A, $A8, $2E, $28, $4D, $48, $D, $18, $D, $D8, $5, $CC, $1, $EC, $2, $EE
byte    $4, $7, $0, $3, $0, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $0, $3, $4, $7
byte    $3, $EF, $2, $EE, $4, $CC, $C, $DC, $8, $18, $48, $48, $28, $28, $28, $A8, $28, $A8, $28, $28, $48, $48, $8, $18, $C, $DC, $4, $DC, $2, $FE, $3, $FF
byte    $0, $7, $4, $7, $E8, $1, $88, $0, $EC, $0, $EC, $0, $EC, $0, $EC, $0, $D8, $0, $F0, $A0, $E0, $E0, $0, $0, $0, $1, $0, $1, $0, $7, $0, $FF
byte    $1, $F7, $3, $F6, $7, $E4, $B, $E8, $B, $E8, $F, $88, $2F, $28, $6F, $68, $6F, $69, $2F, $2C, $9, $88, $8, $F8, $C, $FC, $4, $FC, $2, $FE, $0, $FF
byte    $0, $FF, $0, $7, $0, $1, $0, $1, $0, $0, $E0, $E0, $F0, $A0, $D8, $0, $EC, $0, $EC, $0, $EC, $0, $EC, $0, $88, $0, $E8, $1, $4, $7, $0, $7
byte    $0, $FF, $2, $FE, $4, $FC, $C, $FC, $8, $F8, $9, $88, $2F, $2C, $6F, $69, $6F, $68, $2F, $28, $F, $88, $B, $E8, $B, $E8, $7, $E4, $3, $F6, $1, $F7

gianttank
word    $90  'frameboost
word    $3, $3   'width, height
byte    $0, $FF, $0, $7F, $80, $BF, $C0, $BF, $C0, $BF, $80, $3F, $0, $3F, $C0, $DF, $0, $3, $0, $1, $24, $5, $24, $5, $24, $5, $24, $5, $0, $1, $0, $3
byte    $E0, $DF, $C0, $27, $0, $7, $FC, $FF, $F7, $F0, $FC, $3, $F8, $FF, $18, $E7, $0, $FF, $54, $54, $F8, $A8, $F8, $A8, $F9, $A9, $F9, $A9, $E0, $A0, $19, $19
byte    $43, $43, $2, $2, $5A, $5A, $22, $2, $22, $2, $5A, $5A, $2, $2, $43, $43, $19, $19, $C0, $80, $E0, $E0, $1F, $1F, $F, $F, $1F, $10, $FF, $EF, $0, $FF
byte    $0, $FF, $19, $99, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $19, $99, $0, $C0, $0, $C0, $3, $83, $3, $83, $3, $83, $3, $83, $0, $C0, $0, $C0
byte    $19, $99, $7F, $66, $7E, $66, $7F, $67, $71, $61, $7F, $67, $18, $98, $0, $FF, $0, $FF, $2, $3, $FF, $FF, $F8, $F8, $FF, $0, $FE, $FD, $0, $7F, $80, $BF
byte    $0, $7, $0, $3, $8, $B, $8, $B, $8, $B, $8, $B, $0, $3, $0, $7, $C0, $BF, $0, $7F, $0, $7F, $80, $7F, $80, $7F, $0, $7F, $0, $FF, $0, $FF
byte    $0, $9F, $70, $70, $8F, $8F, $87, $81, $8F, $88, $7F, $77, $E0, $80, $3, $3, $6, $6, $4, $4, $C4, $C4, $C4, $C4, $C4, $C4, $C4, $C4, $4, $4, $6, $6
byte    $3, $3, $F0, $A0, $F1, $A1, $F3, $A3, $F3, $A3, $F3, $A2, $58, $58, $0, $FF, $0, $FF, $19, $99, $7F, $66, $7E, $66, $7F, $66, $7F, $66, $7F, $66, $19, $99
byte    $0, $E0, $0, $E0, $1, $C1, $1, $C1, $1, $C1, $1, $C1, $0, $E0, $0, $E0, $19, $99, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $7F, $66, $19, $99, $0, $FF
byte    $0, $FF, $0, $FF, $70, $5F, $78, $57, $7C, $5B, $70, $57, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $78, $51, $78, $50, $71, $51, $71, $51
byte    $70, $50, $70, $51, $70, $5F, $70, $5F, $78, $57, $78, $57, $0, $FF, $0, $FF, $0, $FF, $80, $7F, $0, $7E, $80, $FE, $BF, $D5, $AA, $EA, $BE, $FE, $80, $FE
byte    $80, $FE, $80, $FE, $0, $3C, $5A, $42, $2A, $2A, $50, $50, $40, $40, $0, $0, $0, $0, $0, $0, $0, $38, $80, $FE, $81, $FD, $1, $7D, $80, $FF, $0, $FF
byte    $19, $D0, $3E, $88, $BA, $B2, $BA, $B2, $6, $4, $6, $4, $82, $82, $B2, $82, $3E, $34, $3E, $34, $82, $82, $82, $82, $7, $5, $37, $5, $BB, $B3, $BB, $B3
byte    $7, $5, $6, $4, $82, $82, $B2, $82, $3E, $34, $3E, $34, $44, $C4, $2B, $EB, $0, $FF, $0, $FF, $78, $57, $78, $57, $10, $1F, $50, $1F, $80, $81, $C0, $C0
byte    $41, $41, $41, $1, $C8, $80, $C8, $41, $D0, $9F, $90, $9F, $70, $5F, $70, $5F, $70, $5F, $70, $5F, $70, $57, $7C, $5B, $78, $57, $70, $5F, $0, $FF, $0, $FF
byte    $0, $FF, $80, $FF, $1, $7D, $81, $FD, $80, $FE, $0, $38, $1, $1, $0, $0, $0, $0, $40, $40, $50, $50, $2B, $2B, $5B, $42, $0, $3C, $80, $FE, $80, $FE
byte    $80, $FE, $BE, $FE, $AA, $EA, $BF, $D5, $80, $FE, $0, $7E, $80, $7F, $0, $FF, $2B, $EB, $44, $C4, $3E, $34, $3E, $34, $B2, $82, $82, $82, $6, $4, $7, $5
byte    $BB, $B3, $BB, $B3, $37, $5, $7, $5, $82, $82, $82, $82, $3E, $34, $3E, $34, $B2, $82, $82, $82, $6, $4, $6, $4, $BA, $B2, $BA, $B2, $3E, $88, $19, $D0

happyface
word    $40  'frameboost
word    $2, $2   'width, height
byte    $0, $7F, $60, $63, $42, $3, $E2, $E3, $42, $2, $E6, $E6, $E, $2, $7A, $60, $76, $60, $E, $2, $E6, $E6, $42, $2, $E2, $E3, $42, $3, $60, $63, $0, $7F
byte    $0, $F8, $8, $F8, $3E, $F2, $76, $C2, $EE, $82, $DC, $8C, $DA, $8A, $D8, $88, $D8, $88, $DA, $8A, $DC, $8C, $EE, $82, $76, $C2, $3E, $F2, $8, $F8, $0, $F8
byte    $0, $7F, $0, $3, $2, $3, $2, $3, $2, $2, $2, $2, $6, $6, $FE, $FE, $FE, $FE, $6, $6, $2, $2, $2, $2, $2, $3, $2, $3, $0, $3, $0, $7F
byte    $0, $F8, $8, $F8, $20, $E0, $40, $C0, $80, $80, $80, $80, $C0, $C0, $FF, $FF, $FF, $FF, $C0, $C0, $80, $80, $80, $80, $40, $C0, $20, $E0, $0, $F0, $0, $F8
byte    $1A, $61, $6E, $6E, $46, $6, $E2, $E2, $42, $2, $E2, $E2, $42, $2, $E2, $E2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $3, $4, $7, $78, $7F, $80, $FF
byte    $A, $FA, $D8, $88, $D8, $88, $DC, $84, $EE, $82, $F6, $C2, $FE, $E2, $E0, $E0, $C0, $C0, $80, $80, $80, $80, $80, $80, $40, $C0, $30, $F0, $8, $F8, $7, $FF
byte    $80, $FF, $78, $7F, $4, $7, $2, $3, $2, $2, $2, $2, $2, $2, $2, $2, $E2, $E2, $42, $2, $E2, $E2, $42, $2, $E2, $E2, $46, $6, $6E, $6E, $1A, $61
byte    $7, $FF, $8, $F8, $30, $F0, $40, $C0, $80, $80, $80, $80, $80, $80, $C0, $C0, $E0, $E0, $FE, $E2, $F6, $C2, $EE, $82, $DC, $84, $D8, $88, $D8, $88, $A, $FA

moonman
word    $40  'frameboost
word    $2, $2   'width, height
byte    $0, $FF, $30, $FF, $48, $C7, $48, $43, $30, $7, $32, $A7, $1E, $1D, $1F, $1, $1F, $0, $DF, $1, $1E, $3, $1C, $F, $10, $1F, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $0, $FE, $8, $FF, $18, $F6, $3F, $67, $3F, $20, $3F, $E0, $3B, $E1, $1B, $F0, $D, $C, $3, $7F, $0, $FD, $0, $E3, $0, $FF
byte    $0, $FF, $0, $FF, $0, $FF, $F0, $FF, $FC, $F, $FE, $3, $FF, $1, $FF, $0, $CF, $1, $BE, $B5, $3A, $B7, $30, $7, $70, $63, $70, $E7, $30, $FF, $0, $FF
byte    $0, $FF, $0, $E3, $0, $FD, $3, $7F, $7, $7, $1F, $FC, $3F, $FC, $3F, $F8, $6, $0, $3E, $76, $18, $F6, $8, $FF, $0, $FE, $0, $FF, $0, $FF, $0, $FF
byte    $0, $FF, $10, $97, $38, $2B, $38, $2F, $3A, $AF, $32, $A7, $17, $15, $1F, $18, $1F, $1, $DE, $1, $DE, $3, $9C, $7, $F8, $F, $F8, $3F, $10, $97, $0, $FF
byte    $0, $FF, $0, $FF, $8, $FE, $18, $F6, $18, $F7, $39, $E6, $39, $62, $3B, $20, $3B, $F0, $3D, $E0, $1F, $70, $E, $8, $5, $FC, $1, $E3, $0, $FF, $0, $FF
byte    $0, $FF, $10, $97, $F8, $3F, $F8, $F, $9C, $7, $DE, $3, $DE, $1, $1F, $1, $1F, $18, $17, $15, $32, $A7, $3A, $AF, $38, $2F, $38, $2B, $10, $97, $0, $FF
byte    $0, $FF, $0, $FF, $1, $E3, $5, $FC, $E, $8, $1F, $70, $3D, $E0, $3B, $F0, $3B, $20, $39, $62, $39, $E6, $18, $F7, $18, $F6, $8, $FE, $0, $FF, $0, $FF







bulletgrfx
word    $10  'frameboost
word    $1, $1   'width, height
byte    $0, $FF, $4, $C7, $2A, $AB, $1E, $9D, $3E, $B9, $5E, $D5, $3C, $E3, $0, $FF


heartgrfx
word    $10  'frameboost
word    $1, $1   'width, height
byte    $0, $E1, $F, $CE, $1F, $9E, $3E, $39, $38, $39, $3F, $BE, $1F, $DE, $E, $E1

heartbox
byte    $0, $E1, $F, $CE, $1F, $9E, $3E, $39, $38, $39, $3F, $BE, $1F, $DE, $E, $E1       


teamlamelogo
word    $200  'frameboost
word    $10, $2   'width, height
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $18, $10, $18, $10, $18, $10, $18, $10, $F8, $0, $F8, $0, $18, $10, $18, $10, $18, $10, $18, $10, $0, $0, $F8, $40, $F8, $0, $D8, $90, $D8, $90, $D8, $90
byte    $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $0, $0, $0, $0, $80, $0, $E0, $0, $F8, $80, $38, $20, $F8, $80, $E0, $0, $80, $0, $0, $0, $0, $0
byte    $F8, $0, $F8, $0, $F8, $0, $E0, $0, $80, $0, $0, $0, $80, $0, $E0, $0, $F8, $0, $F8, $0, $F8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $F8, $0, $F8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $80, $0
byte    $E0, $0, $F8, $80, $38, $20, $F8, $80, $E0, $0, $80, $0, $0, $0, $0, $0, $F8, $0, $F8, $0, $F8, $0, $E0, $0, $80, $0, $0, $0, $80, $0, $E0, $0
byte    $F8, $0, $F8, $0, $F8, $0, $0, $0, $F8, $40, $F8, $0, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $D8, $90, $0, $0, $18, $10
byte    $78, $40, $18, $10, $0, $0, $78, $40, $18, $10, $70, $40, $18, $10, $70, $40, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $F, $8, $F, $8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $7, $4, $F, $8, $C, $8, $C, $8, $C, $8
byte    $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $E, $8, $F, $8, $3, $2, $0, $0, $0, $0, $0, $0, $3, $2, $F, $8, $E, $8, $C, $8
byte    $F, $8, $F, $8, $1, $1, $7, $4, $F, $8, $E, $8, $F, $8, $7, $4, $1, $1, $F, $8, $F, $8, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $7, $4, $F, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $0, $0, $C, $8, $E, $8, $F, $8
byte    $3, $2, $0, $0, $0, $0, $0, $0, $3, $2, $F, $8, $E, $8, $C, $8, $F, $8, $F, $8, $1, $1, $7, $4, $F, $8, $E, $8, $F, $8, $7, $4
byte    $1, $1, $F, $8, $F, $8, $0, $0, $7, $4, $F, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $C, $8, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0





 'LAME LOGO
tanklogo
word    $200  'frameboost
word    $10, $2   'width, height
byte    $0, $0, $0, $0, $C, $0, $C, $8, $4, $4, $0, $0, $C0, $C0, $E4, $64, $C, $C, $C, $8, $C, $8, $C, $0, $0, $0, $0, $0, $88, $0, $8C, $80
byte    $8C, $80, $C, $0, $C, $0, $C, $0, $8C, $80, $8C, $0, $FC, $0, $F8, $0, $0, $0, $0, $0, $F8, $E0, $FC, $0, $C, $0, $C, $0, $C, $8, $C, $8
byte    $C, $8, $4, $0, $84, $84, $C8, $48, $0, $0, $0, $0, $F8, $0, $F0, $0, $80, $0, $C0, $0, $E0, $80, $78, $40, $3C, $0, $C, $0, $C, $4, $C, $C
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $8C, $C, $8C, $C, $8C, $C, $8C, $8, $8C, $8, $8C, $8, $8C, $0, $8C, $0
byte    $FC, $0, $F8, $0, $0, $0, $0, $0, $88, $0, $8C, $0, $8C, $4, $88, $8, $80, $0, $80, $0, $84, $4, $8C, $8, $FC, $0, $F8, $0, $0, $0, $0, $0
byte    $C, $0, $C, $0, $C, $8, $C, $8, $4, $4, $4, $4, $C, $8, $C, $8, $C, $0, $C, $0, $0, $0, $0, $0, $0, $0, $4, $4, $C, $8, $C, $8
byte    $CC, $C0, $EC, $E0, $C, $0, $C, $0, $C, $0, $C, $0, $0, $0, $0, $0, $3C, $20, $1C, $10, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $F8, $0, $FC, $0, $8C, $0, $8C, $80, $C, $8, $C, $8, $4, $0, $4, $0, $4, $0, $C, $8, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0
byte    $1, $1, $1, $1, $0, $0, $0, $0, $0, $0, $1, $1, $1F, $18, $1F, $1E, $0, $0, $0, $0, $1C, $C, $19, $9, $0, $0, $0, $0, $0, $0, $0, $0
byte    $0, $0, $0, $0, $1F, $1, $1F, $0, $0, $0, $0, $0, $F, $F, $1F, $18, $3, $0, $1, $1, $0, $0, $0, $0, $0, $0, $C, $C, $1C, $4, $18, $8
byte    $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $10, $1F, $10, $19, $18, $9, $9, $1, $1, $1, $1, $1, $1, $9, $9
byte    $1F, $1E, $F, $8, $0, $0, $0, $0, $1F, $0, $1F, $1C, $1, $0, $1, $0, $1, $0, $1, $0, $1, $0, $1, $0, $1F, $18, $1F, $10, $0, $0, $0, $0
byte    $0, $0, $0, $0, $0, $0, $0, $0, $1E, $E, $1F, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0
byte    $1F, $1, $1F, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $E, $2, $1C, $4, $18, $0, $18, $10, $18, $10, $8, $0, $8, $0, $18, $10
byte    $18, $10, $18, $0, $0, $0, $0, $0, $F, $0, $1F, $0, $19, $0, $19, $0, $19, $11, $18, $10, $18, $10, $18, $18, $8, $8, $8, $8, $0, $0, $0, $0
    
         
'RANDOM PIC 2
excitingtank
byte    $40, $0, $0, $0, $C, $0, $C, $8, $4, $4, $0, $0, $C0, $C0, $E4, $64, $C, $C, $C, $8, $C, $8, $8C, $80, $0, $0, $0, $0, $88, $0, $8C, $80
byte    $8C, $80, $C, $0, $C, $0, $C, $0, $8C, $80, $8C, $0, $FC, $0, $F8, $0, $0, $0, $0, $0, $F8, $E0, $FC, $0, $C, $0, $C, $0, $C, $8, $C, $8
byte    $C, $8, $4, $0, $84, $84, $C8, $48, $0, $0, $0, $0, $F8, $0, $F0, $0, $80, $0, $C0, $0, $E0, $80, $78, $40, $3C, $0, $C, $0, $C, $4, $C, $C
byte    $0, $0, $0, $0, $0, $0, $40, $40, $0, $0, $0, $0, $4, $0, $0, $0, $C0, $C0, $E0, $60, $84, $4, $8C, $8, $8C, $8, $8C, $8, $8C, $0, $8C, $0
byte    $FC, $0, $F8, $0, $C0, $C0, $40, $40, $C8, $40, $EC, $60, $AC, $24, $88, $8, $80, $0, $80, $0, $84, $4, $8C, $8, $FC, $0, $F8, $0, $0, $0, $0, $0
byte    $2C, $20, $C, $0, $C, $8, $C, $8, $4, $4, $4, $4, $C, $8, $C, $8, $C, $0, $4C, $0, $0, $0, $80, $80, $80, $80, $4, $4, $C, $8, $C, $8
byte    $CC, $C0, $EC, $E0, $C, $0, $C, $0, $8C, $80, $C, $0, $0, $0, $0, $0, $3C, $20, $1C, $10, $0, $0, $0, $0, $0, $0, $0, $0, $80, $80, $88, $80
byte    $C0, $C0, $F0, $F0, $30, $30, $0, $0, $F8, $0, $FC, $0, $8C, $0, $8C, $80, $C, $8, $C, $8, $4, $0, $4, $0, $4, $0, $0, $0, $40, $40, $0, $0
byte    $0, $0, $0, $0, $20, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1F, $0, $1F, $0
byte    $1, $1, $1, $1, $0, $0, $0, $0, $0, $0, $1, $1, $1F, $18, $9F, $9E, $80, $80, $80, $80, $9C, $8C, $F9, $E9, $20, $20, $30, $30, $0, $0, $0, $0
byte    $0, $0, $0, $0, $1F, $1, $1F, $0, $0, $0, $0, $0, $8F, $8F, $9F, $98, $83, $80, $81, $81, $80, $80, $80, $80, $80, $80, $8C, $8C, $DC, $C4, $D8, $C8
byte    $C0, $C0, $C0, $C0, $60, $60, $60, $60, $60, $60, $70, $70, $38, $38, $38, $38, $3F, $30, $3F, $30, $39, $38, $39, $39, $2F, $2F, $7, $7, $3, $3, $9, $9
byte    $1F, $1E, $F, $8, $80, $80, $0, $0, $1F, $0, $1F, $1C, $1, $0, $1, $0, $1, $0, $81, $80, $81, $80, $81, $80, $9F, $98, $9F, $90, $80, $80, $C0, $C0
byte    $E0, $E0, $E0, $E0, $40, $40, $0, $0, $1E, $E, $1F, $1, $4, $4, $4, $4, $A, $A, $E, $E, $6, $6, $3, $3, $1, $1, $0, $0, $0, $0, $0, $0
byte    $1F, $1, $1F, $0, $80, $80, $C0, $C0, $E0, $E0, $60, $60, $B0, $B0, $0, $0, $E, $2, $1C, $4, $1A, $2, $5A, $52, $19, $11, $9, $1, $9, $1, $18, $10
byte    $18, $10, $18, $0, $0, $0, $0, $0, $F, $0, $1F, $0, $19, $0, $19, $0, $99, $91, $98, $90, $D8, $D0, $98, $98, $88, $88, $C0, $C0, $40, $40, $0, $0
byte    $80, $80, $0, $0, $C0, $C0, $80, $80, $0, $0, $0, $0, $22, $22, $0, $0, $50, $50, $40, $40, $60, $60, $70, $70, $72, $72, $70, $70, $70, $70, $18, $18
byte    $1C, $1C, $9C, $9C, $8C, $8C, $86, $86, $A7, $A7, $A3, $A3, $A3, $A3, $AF, $AF, $A3, $A3, $81, $81, $A0, $A0, $80, $80, $B0, $B0, $30, $30, $30, $30, $10, $10
byte    $28, $28, $6C, $6C, $7C, $7C, $7E, $7E, $4E, $4E, $7F, $7F, $D, $D, $C7, $C7, $66, $66, $77, $77, $27, $27, $3, $3, $23, $23, $33, $33, $21, $21, $0, $0
byte    $1, $1, $A0, $A0, $A0, $A0, $84, $84, $A0, $A0, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $82, $82, $80, $80, $80, $80, $88, $88, $80, $80, $80, $80
byte    $D0, $50, $D0, $50, $C8, $48, $C8, $48, $C8, $48, $C4, $44, $CC, $4C, $CC, $CC, $C7, $C7, $87, $87, $87, $87, $83, $3, $82, $2, $81, $1, $C9, $49, $C1, $41
byte    $C8, $C8, $C0, $C0, $C0, $C0, $84, $84, $80, $80, $90, $90, $D0, $D0, $C8, $C8, $CC, $4C, $C4, $44, $FE, $FE, $EE, $6E, $CE, $4E, $DC, $1C, $86, $86, $8E, $8E
byte    $A3, $23, $83, $3, $20, $20, $30, $30, $84, $4, $C0, $0, $E2, $2, $F2, $2, $FA, $2, $F8, $C0, $7C, $60, $3C, $30, $4C, $48, $EC, $E8, $F2, $F2, $F2, $F2
byte    $E2, $E2, $C8, $C8, $E0, $E0, $9C, $9C, $1C, $1C, $2E, $2E, $CF, $CF, $C7, $C7, $C3, $C3, $C3, $C3, $81, $81, $80, $80, $0, $0, $10, $10, $40, $40, $0, $0
byte    $F7, $F7, $E3, $63, $F3, $33, $F3, $33, $F9, $19, $FD, $D, $FC, $4, $FE, $2, $FE, $2, $FE, $2, $FE, $0, $7E, $0, $3F, $1, $1F, $1, $9F, $80, $8F, $80
byte    $8F, $80, $8F, $80, $F, $0, $F, $1, $F, $1, $1F, $1, $1F, $0, $1F, $0, $7F, $0, $FF, $0, $FF, $0, $FF, $1, $FF, $0, $FF, $1, $FF, $3, $FF, $3
byte    $FF, $3, $FF, $3, $FE, $2, $FE, $2, $FE, $2, $FE, $2, $F8, $0, $F8, $80, $F8, $10, $FA, $12, $F2, $F2, $C0, $C0, $8E, $8E, $1A, $1A, $70, $10, $F4, $84
byte    $B5, $25, $B9, $A9, $F9, $D1, $D9, $D1, $C9, $81, $EB, $AB, $DB, $9B, $F7, $A7, $B7, $7, $AF, $8E, $AF, $8C, $EF, $8C, $CF, $8C, $DF, $1E, $DF, $98, $9F, $90
byte    $BF, $3C, $3F, $34, $7F, $70, $FF, $F0, $FF, $F0, $FF, $D0, $FF, $F0, $FF, $C0, $FF, $80, $FF, $E0, $FF, $80, $FF, $0, $FF, $0, $FF, $C0, $FF, $0, $FF, $0
byte    $FF, $0, $FF, $0, $FF, $0, $FF, $1, $FF, $1, $FF, $1, $FF, $1, $FF, $1, $FF, $1, $87, $0, $7B, $60, $FD, $80, $FD, $80, $FD, $80, $FD, $80, $9D, $80
byte    $DD, $80, $1, $0, $5C, $5C, $DF, $0, $1F, $0, $1F, $0, $1F, $0, $1F, $0, $9F, $0, $3, $1, $1C, $0, $1D, $0, $FD, $80, $FC, $80, $FC, $80, $DC, $80
byte    $DD, $C1, $CD, $C1, $CE, $C0, $4E, $40, $7E, $40, $6, $0, $78, $0, $84, $0, $2, $0, $2, $0, $85, $1, $79, $1, $87, $87, $FE, $FE, $FC, $FC, $FC, $FC
byte    $FF, $1, $FF, $0, $FF, $1, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $C1, $0, $BE, $0, $63, $40, $63, $40, $BE, $0, $C1, $0, $F3, $10
byte    $C1, $0, $BE, $0, $63, $40, $63, $40, $7F, $40, $BE, $0, $C0, $80, $38, $38, $C0, $0, $E1, $0, $FF, $0, $FF, $0, $1F, $0, $F, $0, $8F, $0, $C7, $0
byte    $C7, $80, $C7, $80, $E7, $0, $E7, $0, $FF, $80, $FF, $E0, $FF, $E0, $7F, $6C, $7F, $78, $BF, $3F, $BF, $38, $DF, $1F, $DF, $1F, $EF, $F, $60, $0, $7F, $45
byte    $5F, $43, $5E, $5C, $82, $2, $D7, $17, $DF, $F, $6F, $0, $8F, $1, $E7, $2, $7, $3, $F7, $0, $F7, $1, $F6, $0, $F6, $2, $13, $3, $D3, $C3, $51, $41
byte    $57, $45, $57, $40, $57, $44, $16, $6, $76, $4, $B5, $1, $35, $1, $35, $1, $A3, $3, $9B, $2, $B7, $7, $67, $4, $6F, $D, $EF, $F, $DF, $1D, $9F, $1D
byte    $3F, $3F, $7F, $6E, $7F, $4C, $FF, $FC, $FF, $B4, $FF, $E0, $FF, $30, $FF, $0, $FF, $C0, $FF, $C0, $FE, $0, $FD, $1, $FD, $81, $1D, $1, $ED, $1, $F5, $1
byte    $F1, $1, $F0, $0, $C0, $0, $BF, $20, $76, $40, $E6, $80, $EE, $0, $DE, $0, $DF, $0, $DE, $0, $F0, $0, $88, $0, $75, $1, $F5, $1, $ED, $1, $DD, $1
byte    $DD, $1, $ED, $1, $80, $0, $80, $0, $B5, $0, $80, $0, $FC, $0, $FC, $0, $FF, $6, $FD, $4, $F8, $8, $FA, $A, $FB, $1B, $F7, $17, $F7, $37, $EF, $6F
byte    $FF, $C0, $FF, $F0, $FF, $60, $FF, $A0, $FF, $F8, $FF, $F0, $FF, $C0, $FB, $E0, $7B, $40, $7B, $60, $7B, $70, $77, $40, $37, $20, $B6, $20, $B5, $20, $82, $2
byte    $1A, $1A, $1B, $1A, $1B, $1A, $3, $2, $1B, $1A, $19, $19, $1A, $18, $83, $0, $DD, $18, $CD, $88, $EE, $C8, $EE, $4C, $E4, $44, $F0, $0, $9, $8, $D5, $15
byte    $D5, $1, $D5, $1, $D5, $1, $D5, $1, $D5, $1, $D4, $0, $D6, $0, $D6, $0, $D7, $0, $D7, $4, $D7, $4, $D7, $4, $D3, $2, $D3, $2, $D7, $17, $C7, $5
byte    $D1, $11, $AE, $AC, $1F, $10, $67, $60, $79, $40, $7E, $40, $7F, $40, $7F, $40, $0, $0, $7F, $7F, $7F, $40, $7F, $40, $FF, $C0, $FC, $80, $80, $80, $73, $70
byte    $6F, $68, $5F, $50, $5F, $50, $27, $20, $19, $0, $66, $0, $81, $0, $81, $0, $0, $0, $0, $0, $0, $0, $81, $0, $81, $0, $66, $0, $99, $0, $27, $21
byte    $6F, $43, $2F, $2, $AF, $82, $AE, $2, $AC, $0, $AD, $5, $AD, $D, $AD, $2D, $AD, $25, $9D, $1, $D9, $1, $D7, $6, $C7, $6, $C8, $8, $CF, $E, $9F, $E
byte    $8F, $88, $4F, $C, $5F, $1C, $DF, $18, $BE, $30, $B9, $31, $33, $22, $7, $4, $6F, $48, $6F, $40, $4F, $40, $5F, $50, $1F, $0, $1E, $0, $3D, $0, $BB, $80
byte    $B3, $80, $AF, $80, $CF, $80, $EF, $80, $FF, $80, $FF, $80, $FF, $C0, $FF, $F0, $FF, $80, $FF, $E0, $FF, $F0, $FF, $F0, $FF, $F0, $FF, $E0, $FF, $F0, $FF, $0
byte    $F9, $10, $FD, $11, $FD, $91, $FD, $31, $FD, $11, $FC, $10, $FE, $D0, $FE, $48, $FE, $44, $FF, $24, $FF, $24, $FF, $10, $FF, $90, $FF, $90, $FE, $90, $FE, $DA
byte    $FE, $6A, $FE, $6A, $FE, $22, $FF, $23, $FE, $12, $7E, $12, $7E, $4A, $7E, $2A, $7F, $6B, $FF, $5E, $FF, $3A, $FF, $28, $FF, $0, $F, $0, $F0, $F0, $FD, $81
byte    $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FD, $81, $FB, $2, $FB, $2, $FB, $2, $FB, $2, $FB, $2, $FB, $2, $FB, $2
byte    $FB, $2, $FB, $3, $F8, $F8, $1, $1, $C1, $C1, $83, $83, $83, $83, $F, $F, $0, $0, $3, $3, $17, $17, $2F, $2F, $3E, $3E, $3E, $3E, $1E, $1E, $3E, $3E
byte    $3E, $3E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $3E, $3E, $2D, $2C, $2D, $2C, $D, $C, $E, $E, $86, $86, $2, $2, $2, $2, $40, $40
byte    $C2, $C0, $FF, $F0, $C0, $C0, $3B, $3B, $FB, $C2, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FB, $82, $FD, $80, $FD, $80, $FD, $80, $FD, $80
byte    $FD, $80, $FD, $81, $FD, $85, $FC, $84, $FC, $84, $E3, $82, $1F, $6, $F0, $0, $F7, $34, $F7, $34, $FF, $3C, $FF, $78, $F0, $70, $F7, $20, $F7, $0, $F6, $0
byte    $FE, $40, $FE, $40, $FE, $40, $FC, $20, $FD, $21, $FD, $21, $FD, $41, $F9, $21, $FB, $23, $FB, $23, $FB, $63, $FB, $43, $F3, $43, $F3, $C3, $F7, $C7, $F7, $7
byte    $FF, $6, $FF, $61, $F9, $21, $F8, $30, $FE, $10, $FF, $10, $FF, $18, $FF, $8, $FF, $C, $FF, $45, $3F, $22, $F, $1, $F, $1, $8F, $1, $CF, $0, $CF, $0
byte    $FF, $8, $FF, $8, $FF, $4, $FF, $4, $FF, $6, $FF, $2, $FF, $81, $FE, $40, $FE, $60, $FF, $20, $FF, $10, $FF, $18, $FF, $8, $FE, $0, $BE, $3A, $F0, $70
byte    $80, $0, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A8, $20, $A9, $21, $A9, $21, $89, $1, $89, $1, $89, $1, $89, $1, $81, $1
byte    $C1, $C1, $F9, $79, $F4, $34, $FC, $3C, $FF, $1F, $F8, $F8, $FF, $3F, $FF, $3F, $F, $F, $1, $1, $1F, $1F, $3F, $1F, $3F, $1F, $FF, $1F, $FF, $3F, $E9, $29
byte    $FF, $FF, $FF, $3F, $FF, $3F, $FF, $3F, $FD, $1D, $FD, $1D, $F9, $19, $F3, $33, $C7, $7, $DE, $5E, $FE, $7E, $FC, $7C, $F8, $38, $F8, $38, $F1, $31, $F1, $71
byte    $E4, $64, $80, $0, $85, $5, $94, $14, $81, $1, $A1, $21, $A9, $21, $A9, $21, $A9, $21, $C9, $1, $C9, $1, $C9, $1, $C9, $1, $D4, $10, $D4, $10, $D4, $10
byte    $D4, $10, $E4, $0, $E4, $0, $E4, $0, $F0, $0, $FE, $20, $FE, $20, $FF, $20, $FF, $20, $FF, $20, $FF, $20, $BF, $20, $BF, $20, $3F, $27, $3F, $26, $7F, $2A
byte    $FF, $4A, $FF, $4A, $FF, $4A, $FF, $4A, $FF, $4A, $FE, $4A, $FC, $48, $FC, $4C, $FC, $44, $FF, $4, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0, $FF, $0








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
extremetankname         byte    "Tank Tock",0
extremethangname        byte    "Super Thang",0
gianttankname           byte    "Class XVI",0
happyfacename           byte    "Happy Face",0
moonmanname             byte    "Moon Man",0
  

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
