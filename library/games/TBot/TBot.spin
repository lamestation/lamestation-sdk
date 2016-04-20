{{

  _______________                     _______________
  \             / ________   ________ \             / 
   \---     ---/ /  ___   \ /   __   \ \---     ---/
    \  /   \    /  /__/ __/|   | /\   \    /   \  /
      /     \  /  /__/   \  \  \/_/    |  /     \
     /_______\/__________/   \________/  /_______\     
     \       / \        /     \      /   \       /
     An adventure game for the Lamestation Game Console
     Bay Area Maker Faire Edition - May 2014
     
     Trodoss
         
     v0.5
         
     See the end of this file for license/terms of use.
  
}}
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  'constants to store the images
  TBOT_STAND   = 0
  TBOT_WALK    = 1
  TBOT_JUMP    = 3

  MAX_WALK_VELOCITY = 4
  MAX_JUMP_VELOCITY = 6
  STEP_LENGTH       = 2

  'player state constants
  TBOT_STANDING = 0
  TBOT_WALKING  = 1
  TBOT_JUMPING  = 2
  TBOT_FALLING  = 3

  TOBT_DEAD     = 9 

' graphics constants
  BULLET       = 8

  WALKER       = 0
  FLYER        = 2

 'constants used when accessing enemy data
  ENEMY_SCREEN  = 0 'defines the screen when this enemy activates 
  ENEMY_LIFE    = 1 'represents amount of life (0 = dead)
  ENEMY_TYPE    = 2 'represents enemy type
  ENEMY_FACING  = 3 'represents enemy facing (left/right)
  ENEMY_X       = 4 'X position of the enemy
  ENEMY_Y       = 5 'Y position of the enemy
  ENEMY_ACTION  = 6 'defines the current enemy action
  ENEMY_FRAME   = 7 'defines the animation frame of the enemy
  
  'length of the structure
  ENEMY_LENGTH = 8

  '*current number of enemies
  ENEMY_COUNT  = 3

'Enemy action constants
  ENEMY_MOVING   = 0
  ENEMY_FALLING  = 1

 'enemy velocity constant 
  ENEMY_VELOCITY = 2

  'action constants
  BULLET_NONE  = 0
  BULLET_LEFT  = 1
  BULLET_RIGHT = 2

  'facing constants
  FACING_RIGHT = 0
  FACING_LEFT  = 4

  'size (bytes) of each screen
  SCREEN_SIZE  = 128
  
VAR
  byte player_x
  byte player_y
  byte player_facing
  byte player_step

  byte player_x_velocity
  byte player_y_velocity
  byte player_count
  byte player_state

  byte tile_adjust

  byte bullet_action
  byte bullet_x
  byte bullet_y

  byte level_current_room

OBJ
  lcd     :              "LameLCD" 
  gfx     :              "LameGFX"
  ctrl    :              "LameControl" 
  tbot    :              "tbotgfx" 
  level   :              "levelgfx"
  enemy   :              "enemygfx"  

PUB Main
    lcd.Start(gfx.Start)

    ctrl.Start

    gfx.Clear
    lcd.Draw

   'start/restart level
   StartLevel

   'start a loop (update the sprite images)
   repeat
     CheckPlayerInput
     HandlePlayer
     HandleBullet
     HandleEnemies
     RenderGraphics

     if player_state == TOBT_DEAD
        StartLevel

pub CheckPlayerInput
     ctrl.Update 
 
     if(ctrl.B)
        if bullet_action == BULLET_NONE  
              if player_facing == FACING_RIGHT
                 if CheckLevelMove_V (player_x + 4, player_y) == 0  and player_x < 116
                    bullet_action := BULLET_RIGHT
                    bullet_x := player_x + 4
                    bullet_y := player_y
              else
                 if CheckLevelMove_V (player_x + 5, player_y) == 0 and player_x > 12
                    bullet_action := BULLET_LEFT
                    bullet_x := player_x - 4
                    bullet_y := player_y
                    
              if bullet_action > BULLET_NONE      
                 gfx.Sprite(tbot.GetPtr, bullet_x, bullet_y, BULLET)  

     'right
     if(ctrl.Right)
         PlayerMove(FACING_RIGHT)

     'left
     if(ctrl.Left)
         PlayerMove(FACING_LEFT)

     'up
     if(ctrl.A)
         PlayerJump


pub RenderGraphics | enemy_ptr
     gfx.Clear

     DrawLevel

     gfx.Sprite(tbot.GetPtr, player_x, player_y, player_facing + player_step)
     if bullet_action > BULLET_NONE
         gfx.Sprite(tbot.GetPtr, bullet_x, bullet_y, BULLET)

    enemy_ptr := @enemydata
    repeat ENEMY_COUNT
           
       if (byte[enemy_ptr][ENEMY_SCREEN] == level_current_room) and (byte[enemy_ptr][ENEMY_LIFE] > 0)
           byte[enemy_ptr][ENEMY_FRAME]++
           if byte[enemy_ptr][ENEMY_FRAME] > 1
              byte[enemy_ptr][ENEMY_FRAME] := 0

           gfx.Sprite(enemy.GetPtr, byte[enemy_ptr][ENEMY_X], byte[enemy_ptr][ENEMY_Y], byte[enemy_ptr][ENEMY_TYPE] + byte[enemy_ptr][ENEMY_FRAME])
                            
       enemy_ptr += ENEMY_LENGTH              

     'handles the update to the sprite elements
     lcd.Draw

pub HandleBullet
     if bullet_action > BULLET_NONE
        if bullet_action == BULLET_RIGHT
           if bullet_x =< 116
               if CheckLevelMove_V (bullet_x + 4, bullet_y) == 0
                  bullet_x += 4
               else
                  bullet_action := BULLET_NONE
           else
              bullet_action := BULLET_NONE
        else
           if bullet_x => 8
               if CheckLevelMove_V (bullet_x + 5, bullet_y) == 0
                  bullet_x -= 4
               else
                  bullet_action := BULLET_NONE
           else
             bullet_action := BULLET_NONE

'************************** Enemy Code ******************************
pub HandleEnemies | enemy_ptr
    enemy_ptr := @enemydata
    repeat ENEMY_COUNT
       if (byte[enemy_ptr][ENEMY_SCREEN] == level_current_room) and (byte[enemy_ptr][ENEMY_LIFE] > 0)

          'handle the walker type enemies
          if byte[enemy_ptr][ENEMY_TYPE] == WALKER
             if byte[enemy_ptr][ENEMY_ACTION] == ENEMY_MOVING
                'handle moving left
                if byte[enemy_ptr][ENEMY_FACING] == FACING_LEFT
                   if CheckLevelMove_V(byte[enemy_ptr][ENEMY_X] - ENEMY_VELOCITY, byte[enemy_ptr][ENEMY_Y]) > 0
                      byte[enemy_ptr][ENEMY_X] := ((tile_adjust + 1) << 3) + 1
                      byte[enemy_ptr][ENEMY_FACING] := FACING_RIGHT
                   else
                      if (byte[enemy_ptr][ENEMY_X] - ENEMY_VELOCITY > 0)
                         byte[enemy_ptr][ENEMY_X] -= ENEMY_VELOCITY
                      else
                         byte[enemy_ptr][ENEMY_LIFE] := 0

                  'test for gravity pulling down (if nothing is below)
                   if (CheckLevelMove_H(byte[enemy_ptr][ENEMY_X], byte[enemy_ptr][ENEMY_Y]+9) == 0)
                      byte[enemy_ptr][ENEMY_ACTION] := ENEMY_FALLING
                
                'handle moving right
                else
                   if CheckLevelMove_V(byte[enemy_ptr][ENEMY_X] + ENEMY_VELOCITY + 8, byte[enemy_ptr][ENEMY_Y]) > 0
                      byte[enemy_ptr][ENEMY_X] := (tile_adjust << 3) - 9
                      byte[enemy_ptr][ENEMY_FACING] := FACING_LEFT
                   else
                      if (byte[enemy_ptr][ENEMY_X] + ENEMY_VELOCITY < 118)
                         byte[enemy_ptr][ENEMY_X] += ENEMY_VELOCITY
                      else
                         byte[enemy_ptr][ENEMY_LIFE] := 0

                '  test for gravity pulling down (if nothing is below)
                   if (CheckLevelMove_H(byte[enemy_ptr][ENEMY_X], byte[enemy_ptr][ENEMY_Y]+9) == 0)
                      byte[enemy_ptr][ENEMY_ACTION] := ENEMY_FALLING
                                                                    
             else
                'walker falling
                if (CheckLevelMove_H(byte[enemy_ptr][ENEMY_X], byte[enemy_ptr][ENEMY_Y]+9) > 0)
                    byte[enemy_ptr][ENEMY_Y] := (tile_adjust << 3) - 9
                    byte[enemy_ptr][ENEMY_ACTION] := ENEMY_MOVING
                else
                    if (byte[enemy_ptr][ENEMY_Y] < 48)
                        byte[enemy_ptr][ENEMY_Y] += ENEMY_VELOCITY
                    else
                        byte[enemy_ptr][ENEMY_LIFE] := 0
          else
            'handle flyer behavior
            'handle moving left
             if byte[enemy_ptr][ENEMY_FACING] == FACING_LEFT
                if CheckLevelMove_V(byte[enemy_ptr][ENEMY_X] - ENEMY_VELOCITY, byte[enemy_ptr][ENEMY_Y]) > 0
                   byte[enemy_ptr][ENEMY_X] := ((tile_adjust + 1) << 3) + 1
                   byte[enemy_ptr][ENEMY_FACING] := FACING_RIGHT
                else
                   if (byte[enemy_ptr][ENEMY_X] - ENEMY_VELOCITY > 0)
                      byte[enemy_ptr][ENEMY_X] -= ENEMY_VELOCITY
                   else
                      byte[enemy_ptr][ENEMY_LIFE] := 0
             else
                if CheckLevelMove_V(byte[enemy_ptr][ENEMY_X] + ENEMY_VELOCITY + 8, byte[enemy_ptr][ENEMY_Y]) > 0
                   byte[enemy_ptr][ENEMY_X] := (tile_adjust << 3) - 9
                   byte[enemy_ptr][ENEMY_FACING] := FACING_LEFT
                else
                   if (byte[enemy_ptr][ENEMY_X] + ENEMY_VELOCITY < 118)
                      byte[enemy_ptr][ENEMY_X] += ENEMY_VELOCITY
                   else
                      byte[enemy_ptr][ENEMY_LIFE] := 0                      

          if (Enemy_Test(enemy_ptr, bullet_x, bullet_y) > 0)
             byte[enemy_ptr][ENEMY_LIFE] := 0

          if (Enemy_Test(enemy_ptr, player_x, player_y) > 0)
             player_state := TOBT_DEAD
                                                                  
       enemy_ptr += ENEMY_LENGTH              

Pub Enemy_Test(enemy_ptr,  x, y)
    if (byte[enemy_ptr][ENEMY_Y] + 8 < y)
       return 0
    if (byte[enemy_ptr][ENEMY_Y] > (y + 8))
       return 0
    if (byte[enemy_ptr][ENEMY_X] + 8 < x)
       return 0
    if (byte[enemy_ptr][ENEMY_X] > (x + 8))
       return 0
    return 1
'************************** Player Code *****************************
pub HandlePlayer 
   if (player_count => MAX_WALK_VELOCITY - player_x_velocity) or (player_y_velocity > 0) or (player_state == TBOT_JUMPING) 
      player_step++
      player_count := 0

      'handle x axis
      if (player_x_velocity > 0)
         if player_facing == FACING_RIGHT
            if CheckLevelMove_V(player_x + player_x_velocity + 8, player_y) > 0
               player_x := (tile_adjust << 3) - 9
               player_x_velocity := 0
            else
               if (player_x + player_x_velocity > 111)
                   ScrollLevel
                   player_x := 0
               else
                   player_x += player_x_velocity
                   player_x_velocity--
         else
            if CheckLevelMove_V(player_x - player_x_velocity, player_y) > 0
               player_x := ((tile_adjust + 1) << 3) + 1
               player_x_velocity := 0
            else
               if (player_x - player_x_velocity > 0)
                  player_x -= player_x_velocity
               player_x_velocity--

      'player y axis
      if (player_y_velocity > 0)
         if player_state == TBOT_JUMPING
            if CheckLevelMove_H(player_x, player_y - player_y_velocity) > 0
               player_y := ((tile_adjust + 1) << 3) + 1
               player_y_velocity := 1
               player_state := TBOT_FALLING
            else
               if (player_y - player_y_velocity > 0)
                   player_y -= player_y_velocity
               player_y_velocity--
         else
            if CheckLevelMove_H(player_x, player_y + player_y_velocity + 8) > 0
               player_y := (tile_adjust << 3) - 9
               player_y_velocity := 0
               player_state := TBOT_STANDING
            else
               if (player_y + player_y_velocity) > 48
                  player_state := TOBT_DEAD
               else
                  player_y += player_y_velocity
                  if (player_y_velocity =< MAX_JUMP_VELOCITY)
                      player_y_velocity++
      else
      'test for gravity pulling down (if nothing is below)
         if CheckLevelMove_H (player_x, player_y + 9 ) == 0
            player_state := TBOT_FALLING
            player_y_velocity := 1

   'handle animation based on state
   if player_y_velocity > 0
      player_step := TBOT_JUMP
   else
      if player_x_velocity > 0
         if player_step > 2
            player_step := TBOT_WALK
      else
         player_step := TBOT_STAND
        
   'increment the count, regardless      
   player_count++

pub PlayerMove(new_facing)
   if player_state < TBOT_FALLING
      if new_facing == player_facing
         if player_x_velocity =< MAX_WALK_VELOCITY
            player_x_velocity++
      else
         player_facing := new_facing
         player_x_velocity := STEP_LENGTH

pub PlayerJump
   if player_state < TBOT_JUMPING
      player_y_velocity := MAX_JUMP_VELOCITY
      player_state := TBOT_JUMPING
           
'********************************************************************
pub StartLevel
   player_x := 48
   player_y := 24
   player_x_velocity := 0
   player_y_velocity := 0
   player_facing := FACING_RIGHT
   player_step := TBOT_STAND
   player_count := 0
   player_state := TBOT_STANDING
   level_current_room := 0

   tile_adjust := 0

   bullet_action := BULLET_NONE

   'clear the screen
   gfx.Clear

   'add the sprites to the screen
   gfx.Sprite(tbot.GetPtr, 48, 24, 0)
   
   DrawLevel

   lcd.Draw

pub DrawLevel  | lvlptr, lvl_x, lvl_y, i, j
   lvlptr := @leveldata + (level_current_room * SCREEN_SIZE) 
   lvl_x := 0
   lvl_y := 0
   repeat j from 0 to 7
     lvl_x := 0
     repeat i from 0 to 15
       gfx.Sprite(level.GetPtr,lvl_x,lvl_y,byte[lvlptr])

       lvl_x += 8
       lvlptr++
     lvl_y += 8

pub ScrollLevel | x, y    
    bullet_action := BULLET_NONE

    level_current_room++
   
pub CheckLevelMove_H(test_x, test_y) |tile_y, tile_x, tile_x_pixels, testend
    tile_x_pixels :=  test_x - (test_x // 8) 'calculate the x position in pixels we are checking against
    testend := test_x + 8
    tile_y := test_y >> 3
    tile_adjust := tile_y
    tile_x := tile_x_pixels >> 3
    repeat
       if tile_x_pixels => testend
          quit
       if CheckLevelBlock(tile_x, tile_y) > 0
          return 1
       tile_x++
       tile_x_pixels += 8
    return 0

pub CheckLevelMove_V(test_x, test_y) | tile_x, tile_y, tile_y_pixels, testend
    tile_y_pixels :=  test_y - (test_y // 8) 'calculate the x position in pixels we are checking against
    testend := test_y + 8
    tile_x := test_x >> 3
    tile_adjust := tile_x
    tile_y := tile_y_pixels >> 3
    repeat
       if tile_y_pixels => testend
          quit
       if CheckLevelBlock(tile_x, tile_y) > 0
          return 1
       tile_y++
       tile_y_pixels += 8
    return 0

pub CheckLevelBlock(tile_x, tile_y) | lvlptr
    lvlptr := @leveldata + (level_current_room * SCREEN_SIZE)
    if byte[lvlptr + (tile_y << 4) + tile_x] > 1
       return 1
    else
       return 0

pub GetLevelBlock(tile_x, tile_y) | lvlptr
    lvlptr := @leveldata + (level_current_room * SCREEN_SIZE)
    return byte[lvlptr + (tile_y << 4) + tile_x] 
      
'*****************************************************

DAT
'screen 1
leveldata byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
          byte 2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
          byte 2,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1
          byte 2,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1
          byte 2,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1
          byte 2,0,0,1,0,2,2,0,0,1,0,0,1,0,2,2
          byte 2,2,0,1,2,2,2,2,0,1,0,0,1,2,2,2
          byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

'screen 2
          byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
          byte 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
          byte 1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1
          byte 1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1
          byte 1,0,0,1,0,0,2,2,0,1,2,2,1,0,0,1
          byte 2,2,0,1,2,2,2,2,0,1,0,0,1,0,2,2
          byte 2,2,0,1,2,2,2,2,0,1,0,0,1,0,2,2
          byte 2,2,2,2,2,2,2,2,0,1,0,0,2,2,2,2

'screen 3
          byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
          byte 0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,2
          byte 0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,2
          byte 0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,2
          byte 0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,2
          byte 2,2,0,1,0,2,2,0,0,1,0,0,1,0,2,2
          byte 2,2,0,1,2,2,2,2,0,1,0,0,1,2,2,2
          byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

'Enemy Data:
'              ENEMY_SCREEN, ENEMY_LIFE, ENEMY_TYPE, ENEMY_FACING, ENEMY_X, ENEMY_Y, ENEMY_ACTION, ENEMY_FRAME 
enemydata byte 0, 1, WALKER, FACING_LEFT, 80, 16, ENEMY_MOVING, 0
          byte 1, 1, FLYER, FACING_LEFT, 80, 16, ENEMY_MOVING, 0
          byte 2, 1, WALKER, FACING_LEFT, 80, 16, ENEMY_MOVING, 0
