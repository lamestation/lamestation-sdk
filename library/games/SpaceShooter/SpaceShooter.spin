{{        SpaceShooter
       by Devonte Cunningham  
  }}

CON
      _clkmode = xtal1 + pll16x
      _xinfreq = 5_000_000
      
      width = 125
      height = 50
 
      BULLET_NONE = 0
      BULLET_SHOOT = 1
      
      EXIST = 2
      NON_EXIST = 3
      
      #0, TITLE,GAMELOOP,GAMEOVER,INTRO
  
VAR
      byte x																	
      byte y
      byte bullet_x
      byte bullet_y
      byte bullet_action
      byte enemy1_exist
      byte enemy2_exist
      byte enemy2_x
      byte enemy2_y
      byte enemy_x
      byte enemy_y
      byte enemy1_placement
      byte enemy2_placement
      byte walls_x
      byte walls_exist
      byte score
      byte score_array[4]
      byte hscore_array[4]
      byte gamestate
      byte highscore
      byte enemy2_health
      byte p_two_bullets_exist
      byte p_two_bullets_activated
      byte powerup_counter
      byte numba
      byte ran
      
OBJ
      lcd : "LameLCD"
      gfx : "LameGFX"
      txt : "LameText"
      ctrl : "LameControl"
      audio : "LameAudio"
      music : "LameMusic"
      fn : "LameFunctions"
      
      ball : "spaceship1"
      enemy1: "asteroid"
      enemy2: "enemy_ship"
      walls: "walls"
      
      bullet : "bullet_8x8"
      laser : "w_laser_8x5"
      rocket: "rocket"
      p_two_bullets: "two_bullets"
      
      number_font: "numbers"
      font: "font8x8_g"
      song : "song_lastboss"
      
PUB Main
      lcd.Start(gfx.Start)
      txt.Load(font.Addr," ",8,0)

      ctrl.Start
      audio.Start
      music.Start
      
      music.Load(song.Addr)
      music.Loop
      ran := cnt
      
      repeat
          case gamestate
             INTRO    : SetIntro
             
             TITLE    : TitleScreen
             
             GAMELOOP : CheckInput
                        MovementAndBarrier
                        HandleGraphics
                        HandleBullet
                        HandleCollision
                        HandleEnemy
                        DrawWalls
                        
             GAMEOVER : EndScreen

'THE TITLE SCREEN
PUB TitleScreen
    ctrl.Update
    gfx.Clear
    txt.Str(@str_pressA,35,25)
    if ctrl.A
        gamestate := GAMELOOP
        
    lcd.Draw

'INITIALIZATION OF VARIABLES AND EVENTS
PUB SetIntro
    bullet_action := BULLET_NONE
    bullet_x := 200
    p_two_bullets_activated := NON_EXIST
    enemy1_exist := NON_EXIST
    enemy2_exist := NON_EXIST
    walls_exist := NON_EXIST
    enemy2_health := 2
    DrawEnemy
    DrawEnemy2
    DrawWalls
    score := 0
    walls_x := 116
    x := 0
    y := 0
    enemy1_placement := 0
    enemy2_placement := 0
    gamestate := GAMELOOP
    
'CREATES PLAYER MOVEMENT AND MOVEMENT BARRIERS
PUB MovementAndBarrier      
         ctrl.Update
         
         'UPPER MOVEMENT AND BOUNDARY
         if ctrl.Up and fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],0,0,width,1) == false
            y--
            
         'LOWER MOVEMENT AND BOUNDARY
         if ctrl.Down and fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],0,height + 14,width,0) == false
            y++
            
         'LEFT MOVEMENT AND BOUNDARY
         if ctrl.Left and fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],0,0,1,height) == false
            x--
            
         'RIGHT MOVEMENT AND BOUNDARY
         if ctrl.Right and fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],width,0,0,height) == false
            x++
            
         if ctrl.A
            score := ||ran? // 3
 
'CHECKS FOR INPUT AND MOVES BULLET ACCORDING TO PLAYER POSITION
PUB CheckInput
    ctrl.Update
    
    'PRESS B TO SHOOT BULLET IF BULLET IS OFF THE SCREEN
    if ctrl.B and bullet_x > 199
        if bullet_action == BULLET_NONE
            bullet_action := BULLET_SHOOT
            
        bullet_x := x + 10
        bullet_y := y + 7
        powerup_counter++
  
'HANDLES DRAWING GRAPHICS
PUB HandleGraphics
    gfx.Clear
    txt.Load(number_font.Addr,"0",4,3)
    gfx.Sprite(ball.Addr,x,y,0)
    
    'DRAW THE BULLET
    if bullet_action == BULLET_SHOOT
        gfx.Sprite(laser.Addr,bullet_x,bullet_y,0)
        if p_two_bullets_activated == EXIST
            'DRAW SECOND BULLET 
            gfx.Sprite(laser.Addr,bullet_x,bullet_y+5,0)
            
    'DRAW ENEMY1
    if enemy1_exist == EXIST 'and enemy2_exist <> EXIST
        gfx.Sprite(enemy1.Addr,enemy_x,enemy_y,0)
    'DRAW ENEMY2
    if enemy2_exist == EXIST
        gfx.Sprite(enemy2.Addr,enemy2_x,enemy2_y,0)
    'DRAW WALL
    if walls_exist == EXIST
        gfx.Sprite(walls.Addr,walls_x,0,0)
        gfx.Sprite(walls.Addr,walls_x,55,0)
        
    if p_two_bullets_exist == EXIST
        gfx.Sprite(p_two_bullets.Addr, 50, 20, 0)
        
    PowerUp
    KeepScore
    KeepHighScore
    
    lcd.Draw
  
PUB PowerUp
    if powerup_counter == 25
        p_two_bullets_activated := NON_EXIST
        powerup_counter := 0
        
'HANDLES LOCATION OF BULLET
PUB HandleBullet
   'MOVE BULLET
   if bullet_action == BULLET_SHOOT
      bullet_x += 5
      
   'DESTROY BULLET
   if bullet_x > 200
      bullet_action := BULLET_NONE

'CREATES DIFFERENT ENEMY POSITIONS
PUB DrawEnemy
    enemy1_exist := EXIST
    
    'TOP PLACEMENT OF ENEMY
    if enemy1_placement == 1
      enemy_x := 116
      enemy_y := 10
      
    'MIDDLE PLACEMENT OF ENEMY
    elseif enemy1_placement == 2
      enemy_x := 116
      enemy_y := 30
      
      
    'BOTTOM PLACEMENT OF ENEMY
    elseif enemy1_placement == 3
      enemy_x := 116
      enemy_y := 50
      
'DIFFERENT ENEMY2 POSITIONS    
PUB DrawEnemy2
    if score > 10
        enemy2_exist := EXIST
        
    if enemy2_placement == 1
        enemy2_x := 116
        enemy2_y := 15
    
    elseif enemy2_placement == 2
        enemy2_x := 116
        enemy2_y := 35
    
    elseif enemy2_placement == 3
        enemy2_x := 116
        enemy2_y := 45
    
PUB DrawWalls
    if score > 50
        walls_exist := EXIST
   
'HANDLES ENEMY MOVING ACROSS SCREEN 
PUB HandleEnemy
    if enemy1_exist == EXIST
        enemy_x -= 1
    if enemy2_exist == EXIST
        enemy2_x -= 1
    if walls_exist == EXIST
        walls_x -= 1
        
'HANDLES COLLISION BETWEEN ENEMY AND BULLET           
PUB HandleCollision
    'IF BULLET DESTROYS ENEMY
    if fn.TestBoxCollision(bullet_x,bullet_y,word[bullet.Addr][1],word[bullet.Addr][2],enemy_x,enemy_y,word[enemy1.Addr][1],word[enemy1.Addr][2])
        enemy1_exist := NON_EXIST
        bullet_x := 200
        Enemy1Variation
        score++

    'IF PLAYER GETS DESTROYED BY ENEMY
    if fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],enemy_x,enemy_y,word[enemy1.Addr][1],word[enemy1.Addr][2])
        enemy1_exist := NON_EXIST
        Enemy1Variation
        gamestate := GAMEOVER
        
     'IF BULLET DESTROYS ENEMY2
    if fn.TestBoxCollision(bullet_x,bullet_y,word[bullet.Addr][1],word[bullet.Addr][2],enemy2_x,enemy2_y,word[enemy2.Addr][1],word[enemy2.Addr][2])
        enemy2_health--
        bullet_x := 200
        
        if enemy2_health == 0
          enemy2_exist := NON_EXIST
          Enemy2Variation
          score += 2
          
          enemy2_health := 2

    'IF PLAYER GETS DESTROYED BY ENEMY2
    if fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],enemy2_x,enemy2_y,word[enemy2.Addr][1],word[enemy2.Addr][2])
        enemy2_exist := NON_EXIST
        Enemy2Variation
        gamestate := GAMEOVER
        
    'WALL COLLISION
    if fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],walls_x,0,word[walls.Addr][1],word[walls.Addr][2])
        gamestate := GAMEOVER
    
    if fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],walls_x,55,word[walls.Addr][1],word[walls.Addr][2])
        gamestate := GAMEOVER
    
    'POWER UP COLLISIONS
    if fn.TestBoxCollision(x,y,word[ball.Addr][1],word[ball.Addr][2],50,20,word[p_two_bullets.Addr][1],word[p_two_bullets.Addr][2]) and p_two_bullets_exist == EXIST
        score += 1
        p_two_bullets_activated := EXIST
        p_two_bullets_exist := NON_EXIST

'HANDLE ENEMY LOCATION    
PUB Enemy1Variation
    if enemy1_placement < 4
          DrawEnemy
          enemy1_placement++
          
    else
          enemy1_placement := 1
          
          DrawEnemy
          
'HANDLE ENEMY2 LOCATION    
PUB Enemy2Variation
    if enemy2_placement < 4
          DrawEnemy2
          enemy2_placement++
          
    else
          enemy2_placement := 1
          
          DrawEnemy2
          
'KEEP THE SCORE            
PUB KeepScore | tmp
    
    tmp := score
    score_array[2] := 48+(tmp // 10)
    tmp /= 10
    score_array[1] := 48+(tmp // 10)
    tmp /= 10
    score_array[0] := 48+(tmp // 10)
    score_array[3] := 0
    
    'EVERY 40 POINTS SPAWN TWO BULLET POWERUP
    if score // 41 == 40 
        p_two_bullets_exist := EXIST

    txt.Str(@score_array, 0, 0)

'KEEP HIGHSCORE
PUB KeepHighScore | hightmp
    if score > highscore
        highscore := score
        hightmp := highscore
        hscore_array[2] := 48+(hightmp // 10)
        hightmp /= 10
        hscore_array[1] := 48+(hightmp // 10)
        hightmp /= 10
        hscore_array[0] := 48+(hightmp // 10)
        hscore_array[3] := 0

'DISPLAY GAMEOVER SCREEN
PUB EndScreen
    ctrl.Update
    gfx.Clear
    txt.Load(font.Addr," ",7,0)
    
    'DISPLAY GAME OVER STRING
    txt.Str(@str_game_over,30,15)
    
    'DISPLAY FINAL SCORE STRING
    txt.Str(@str_final,10,30)
    
    'DISPLAY HIGHSCORE STRING
    txt.Str(@str_high, 10, 50)
    
    'DISPLAY ACTUAL SCORES
    txt.Load(number_font.Addr,"0",4,3)
    txt.Str(@score_array,100,32)
    txt.Str(@hscore_array,100,52)
    
    'BACK TO INTRO SCREEN
    if ctrl.A
        gamestate := INTRO
    lcd.Draw
          
DAT
  
  str_pressA byte "Press A",0
  str_game_over byte "GAME OVER",0
  str_final byte "FINAL SCORE: ",0
  str_high byte "HIGH SCORE: ",0

