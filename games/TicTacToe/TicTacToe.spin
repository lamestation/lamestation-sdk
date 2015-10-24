{     TIC TAC TOE
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
    block_o : "block_o"
    block_x : "block_x"
    
    selector : "selector"
    number_font : "numbers"
    font :  "font6x6"
      
VAR
  
    byte selector_x
    byte selector_y
    byte gamestate
    byte s_position
    byte int_array[9]
    byte pausing
    byte turn
    byte button_pause
    byte champion
  
PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    gamestate := INTRO
    
    repeat
          case gamestate
          
              INTRO : SetIntro
              
              GAMELOOP : HandleGraphics
                         HandleInput
                         DrawBoard
                         ChangeBlocks
                         HandleWin
                         
              GAMEOVER : Endgame
                         
PUB SetIntro
    selector_x := 39
    selector_y := 6
    turn := 0
    SetBoard
    gamestate := GAMELOOP
    
PUB HandleGraphics
      gfx.ClearScreen(0)
      
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
    int_array[0] := 0
    int_array[1] := 0
    int_array[2] := 0
    int_array[3] := 0
    int_array[4] := 0
    int_array[5] := 0
    int_array[6] := 0
    int_array[7] := 0
    int_array[8] := 0
    
'DRAWS THE BLOCKS IN THE BOARD  
PUB DrawBlock(position,x,y)
    
    case int_array[position] 
          0 : gfx.Sprite(block.Addr,x,y,0)
          1 : gfx.Sprite(block_x.Addr,x,y,0)
          2 : gfx.Sprite(block_o.Addr,x,y,0)
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
      
      
PUB ChangeBlocks
  
    ctrl.Update
    button_pause++
    if button_pause == 10
        if ctrl.A
            if int_array[s_position] == 1 or int_array[s_position] == 2
                int_array[s_position] := 0
                turn := 0
            elseif turn == 0
                int_array[s_position] := 1
                turn := 1
            
            elseif turn == 1
                int_array[s_position] := 2
                turn := 0
        
        button_pause := 0
        
PUB HandleWin
  
    HandleMatches(0,1,2)
    HandleMatches(3,4,5)
    HandleMatches(6,7,8)
    HandleMatches(0,3,6)
    HandleMatches(1,4,7)
    HandleMatches(2,5,8)
    HandleMatches(0,4,8)
    HandleMatches(2,4,6)
    
PUB HandleMatches(first,second,third)
     if int_array[first] <> 0
        if int_array[first] == int_array[second] and int_array[second] == int_array[third]
              Winner(int_array[first])
      
PUB Winner(win)
    if win == 1
        champion := 1
        
        'x wins
    else
        champion := 2
        'y wins
       
    gamestate := GAMEOVER
        
PUB Endgame
  
    gfx.ClearScreen(0)
    txt.Load(font.Addr, " ", 6,5)
    if champion == 1
        txt.Str(string("X won!"),40,25)
    elseif champion == 2
        txt.Str(string("O won!"),40,25)
        
    lcd.DrawScreen

