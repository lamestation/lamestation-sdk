CON

    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    
    BALLSPEED = 2
    HIGHSCORE = 9

OBJ

    lcd     : "LameLCD" 
    gfx     : "LameGFX"
    txt     : "LameText"
    ctrl    : "LameControl"
    fn      : "LameFunctions"
    
    ball    : "gfx_ball"
    paddle  : "gfx_paddle"
    fnt     : "gfx_font8x8"

VAR

    word    ballgfx

    long    ballx
    long    bally
    long    ballspeedx
    long    ballspeedy

    word    paddlegfx
    long    paddle1_y
    long    paddle1_x
    long    paddle1_speedy
    
    long    paddle2_x
    long    paddle2_y
    long    paddle2_speedy
    
    long    score1
    long    score2
    long    timeout

PUB Main

    lcd.Start(gfx.Start)
'    lcd.SetFrameLimit (lcd#HALFSPEED)
    ctrl.Start
    txt.Load (fnt.Addr," ",7,8)
    
    TitleScreen
    InitGame
    
    repeat
        GameLoop
        
PUB InitGame
    
    ballgfx := ball.Addr
    paddlegfx := paddle.Addr
    
    ballx := (128 / 2) - gfx.Width (ballgfx)
    bally := (64 / 2) - gfx.Height (ballgfx)

    ballspeedx := BALLSPEED
    ballspeedy := 2

    paddle1_x := 4
    paddle2_x := 116

PUB TitleScreen
    txt.Str(string("HELLO PONG!"),24,30)
    txt.Box(string("This game is",10,"impossible"),0,46,128,64)
    lcd.DrawScreen
    ctrl.WaitKey

PUB YouLose
    txt.Str(string("You lose!"),28,20)
    lcd.DrawScreen
    fn.Sleep (4000)
    
PUB YouWin
    txt.Str(string("You win!"),28,20)
    lcd.DrawScreen
    fn.Sleep (4000)
    
PUB ResetGame

    score1 := 0
    score2 := 0
    
PUB GameLoop
    
    ctrl.Update
    gfx.Clear

    if ballx => paddle1_x+8 and ballx =< paddle2_x
        ControlPlayer
        ControlOpponent
    
    ControlBall
     
    gfx.Sprite(paddle.Addr, paddle1_x, paddle1_y, 0)
    gfx.Sprite(paddle.Addr, paddle2_x, paddle2_y, 0)
            
    gfx.Sprite(ball.Addr, ballx, bally >> 3, 0)
    
    txt.Dec (score1, 0, 56)
    txt.Dec (score2, 120, 56)
    lcd.DrawScreen

PUB ControlPlayer

    paddle1_speedy := 0

    if ctrl.Up and paddle1_y > 0
           paddle1_speedy := -1
    if ctrl.Down and paddle1_y < gfx#res_y - 16
           paddle1_speedy := 1
           
    paddle1_y += paddle1_speedy

PUB ControlOpponent | ballcenter, paddlecenter

    paddle2_speedy := 0

    ballcenter := bally >> 3 + gfx.Height(ballgfx)/2
    paddlecenter := paddle2_y + gfx.Height(paddlegfx)/2

    if paddlecenter > ballcenter and paddle2_y > 0
        paddle2_speedy := -1
    if paddlecenter < ballcenter and paddle2_y < gfx#res_y - 16
        paddle2_speedy := 1
        
    paddle2_y += paddle2_speedy

PUB ControlBall | ballcenter, paddlecenter

    if bally >> 3 < 0 or bally >> 3 > gfx#res_y - 8
        ballspeedy := -ballspeedy

    bally += ballspeedy

    if ballx < -8
        score2++
        InitGame
        if score2 > 9
            YouLose
            ResetGame
    if ballx > gfx#res_x
        score1++
        InitGame
        if score1 > 9
            YouWin
            ResetGame
            
    ballx += ballspeedx
    ballcenter := bally >> 3 + gfx.Height(ballgfx)/2
    
    if fn.TestBoxCollision (ballx, bally >> 3, gfx.Width(ballgfx), gfx.Height(ballgfx), paddle1_x, paddle1_y, gfx.Width(paddlegfx), gfx.Height(paddlegfx))
        ballspeedx := BALLSPEED
        paddlecenter := paddle1_y + gfx.Height(paddlegfx)/2
        ballspeedy := ballcenter - paddlecenter + paddle1_speedy * 2
        
    if fn.TestBoxCollision (ballx, bally >> 3, gfx.Width(ballgfx), gfx.Height(ballgfx), paddle2_x, paddle2_y, gfx.Width(paddlegfx), gfx.Height(paddlegfx))
        ballspeedx := -BALLSPEED

        paddlecenter := paddle2_y + gfx.Height(paddlegfx)/2        
        ballspeedy := ballcenter - paddlecenter + paddle2_speedy * 2
 
