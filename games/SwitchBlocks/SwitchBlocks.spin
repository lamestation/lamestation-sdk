{      SwitchBlocks
            by Devonte Cunningham
 }

CON  
      _clkmode = xtal1 + pll16x
      _xinfreq = 5_000_000

      INTRO = 0
      GAMELOOP = 1
      GAMEOVER = 2
      
OBJ
      lcd : "LameLCD"
      gfx : "LameGFX"
      txt : "LameText"
      ctrl : "LameControl"

      border : "border"
      block : "block"
      block2 : "block2"
      block3 : "block3"
      selector : "selector"
      number_font : "numbers"
      font :  "font6x6"
      
VAR
    byte selector_x
    byte selector_y
    byte gamestate
    byte s_position
    byte pausing
    byte int_array[9]
    byte selection1
    byte selection2
    byte selection_ready
    byte ran
    byte loadblocks
    byte can_switch
    byte score
    byte score_array[4]
    byte time_array[4]
    byte time
    byte time_pause
  
PUB Main
    ran := cnt
    lcd.Start(gfx.Start)
    ctrl.Start
    gamestate := INTRO
    
    repeat
          case gamestate
          
              INTRO : SetIntro
              
              GAMELOOP : HandleGraphics
                         HandleInput
                         HandleSwitch
                         HandleMatches
                         KeepScore
                         KeepTime
                         HandleTime
                         
              GAMEOVER :
                         Endgame

PUB SetIntro
    selector_x := 39
    selector_y := 6
    time := 60
    score := 0
    SetBoard
    gamestate := GAMELOOP
    
PUB HandleGraphics
      gfx.Clear
      
      gfx.Sprite(border.Addr,33,0,0)
      gfx.Sprite(selector.Addr,selector_x,selector_y,0)
      
      DrawBoard
      lcd.DrawScreen
      
PUB HandleInput
  
    ctrl.Update
    
    'MOVING RIGHT
    if ctrl.Right
        pausing += 1
        if pausing == 5
            
            case s_position
                0 : MoveRight(1)
                1 : MoveRight(2)
                2 : MoveNone
                3 : MoveRight(4)
                4 : MoveRight(5)
                5 : MoveNone
                6 : MoveRight(7)
                7 : MoveRight(8)
                8 : MoveNone           
    'MOVING LEFT          
    if ctrl.Left
        pausing += 1
        if pausing == 5
            case s_position
                0 : MoveNone
                1 : MoveLeft(0)
                2 : MoveLeft(1)
                3 : MoveNone
                4 : MoveLeft(3)
                5 : MoveLeft(4)
                6 : MoveNone
                7 : MoveLeft(6)
                8 : MoveLeft(7)
    'MOVING DOWN
    if ctrl.Down
        pausing += 1
        if pausing == 5
            case s_position
                0 : MoveDown(3)
                1 : MoveDown(4)
                2 : MoveDown(5)
                3 : MoveDown(6)
                4 : MoveDown(7)
                5 : MoveDown(8)
                6 : MoveNone
                7 : MoveNone
                8 : MoveNone
    'MOVING UP
    if ctrl.Up
        pausing += 1
        if pausing == 5
            case s_position
                0 : MoveNone
                1 : MoveNone
                2 : MoveNone
                3 : MoveUp(0)
                4 : MoveUp(1)
                5 : MoveUp(2)
                6 : MoveUp(3)
                7 : MoveUp(4)
                8 : MoveUp(5)
            
PUB MoveRight(position)
    selector_x += 17
    pausing := 0
    s_position := position
    
PUB MoveLeft(position)
    selector_x -= 17
    pausing := 0
    s_position := position
    
PUB MoveDown(position)
    selector_y += 17
    pausing := 0
    s_position := position
    
PUB MoveUp(position)
    selector_y -= 17
    pausing := 0
    s_position := position

PUB MoveNone
    pausing := 0
    
PUB SetBoard
    int_array[0] := MakeRandom(3)
    int_array[1] := MakeRandom(3)
    int_array[2] := MakeRandom(3)
    int_array[3] := MakeRandom(3)
    int_array[4] := MakeRandom(3)
    int_array[5] := MakeRandom(3)
    int_array[6] := MakeRandom(3)
    int_array[7] := MakeRandom(3)
    int_array[8] := MakeRandom(3)
    
'DRAWS THE BLOCKS IN THE BOARD  
PUB DrawBlock(position,x,y)
    
    case int_array[position] 
          0 : gfx.Sprite(block.Addr,x,y,0)
          1 : gfx.Sprite(block2.Addr,x,y,0)
          2 : gfx.Sprite(block3.Addr,x,y,0)

'DRAW THE FULL BOARD    
PUB DrawBoard
      DrawBlock(0,40,7)
      DrawBlock(1,57,7)
      DrawBlock(2,74,7)
      DrawBlock(3,40,24)
      DrawBlock(4,57,24)
      DrawBlock(5,74,24)
      DrawBlock(6,40,41)
      DrawBlock(7,57,41)
      DrawBlock(8,74,41)
      
'HANDLES SWITCHING TILES
PUB HandleSwitch | temp

    ctrl.Update
    
    if ctrl.A
        selection1 := s_position
        selection_ready := 1
        
    if ctrl.B and selection_ready == 1
    
        case selection1 
            0:  MakeSelection2(1,3)
                DoSwitch(selection1,selection2)
                
            1:  MakeSelection3(0,2,4)
                DoSwitch(selection1,selection2)
            
            2:  MakeSelection2(1,5)
                DoSwitch(selection1,selection2)
            
            3:  MakeSelection3(0,4,6)
                DoSwitch(selection1,selection2)
                
            4:  MakeSelection4(1,3,5,7)
                DoSwitch(selection1,selection2)
            
            5:  MakeSelection3(2,4,8)
                DoSwitch(selection1,selection2)
            
            6:  MakeSelection2(3,7)
                DoSwitch(selection1,selection2)
            
            7:  MakeSelection3(4,6,8)
                DoSwitch(selection1,selection2)
                
            8:  MakeSelection2(5,7)
                DoSwitch(selection1,selection2)
                
        selection_ready := 0
     
'Switches two values in the array   
PUB DoSwitch(a,b)|temp
    temp := int_array[a]
    int_array[a] := int_array[b]
    int_array[b] := temp
    
'CHECK THE POSITIONS TO ALLOW FOR LEGAL SWITCHES
PUB MakeSelection2(a,b)
      if s_position == a or s_position == b
          selection2 := s_position

PUB MakeSelection3(a,b,c)
      if s_position == a or s_position == b or s_position == c
          selection2 := s_position

PUB MakeSelection4(a,b,c,d)
      if s_position == a or s_position == b or s_position == c or s_position == d
          selection2 := s_position
          
'HANDLES MAKING MATCHES
PUB HandleMatches
    Match(0,1,2)
    Match(3,4,5)
    Match(6,7,8)
    Match(0,3,6)
    Match(1,4,7)
    Match(2,5,8) 
    
PUB Match(first,second,third)
    if int_array[first] == int_array[second] and int_array[second] == int_array[third]
        int_array[first] := 3
        int_array[second] := 3
        int_array[third] := 3
        
        loadblocks++
        if loadblocks == 10
            int_array[first] := MakeRandom(3)
            int_array[second] := MakeRandom(3)
            int_array[third] := MakeRandom(3)
            loadblocks := 0
            score += 5
              
        
PUB MakeRandom(number)
    return ||ran? // number
    
'KEEP THE SCORE            
PUB KeepScore | tmp
    
    tmp := score
    score_array[2] := 48+(tmp // 10)
    tmp /= 10
    score_array[1] := 48+(tmp // 10)
    tmp /= 10
    score_array[0] := 48+(tmp // 10)
    score_array[3] := 0
    
    txt.Load(font.Addr," ", 5,3)
    txt.Str(string("Score:"),0,0)
    
    txt.Load(number_font.Addr,"0",4,4)
    txt.Str(@score_array, 6, 8)
    lcd.DrawScreen
    
'KEEP THE TIME
PUB KeepTime | tmp
    tmp := time 
    time_array[2] := 48+(tmp // 10)
    tmp /= 10
    time_array[1] := 48+(tmp // 10)
    tmp /= 10
    time_array[0] := 48+(tmp // 10)
    time_array[3] := 0
    
    txt.Load(font.Addr," ", 5,3)
    txt.Str(string("Time:"),0,17)
    
    txt.Load(number_font.Addr,"0",4,4)
    txt.Str(@time_array, 6, 25)
    lcd.DrawScreen
    
PUB HandleTime
    time_pause++
    if time_pause == 25
        time--
        time_pause := 0
    if time == 0
        gamestate := GAMEOVER
 
PUB Endgame
    gfx.Clear
    txt.Load(font.Addr," ",5,3)
    txt.Str(string("Game Over"),40,25)
   
    lcd.DrawScreen
 
