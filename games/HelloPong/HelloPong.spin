CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    lcd     : "LameLCD" 
    gfx     : "LameGFX" 
    ctrl    : "LameControl"   
    
    ball    : "gfx_ball"
    paddle  : "gfx_paddle"

VAR
    long    x
    long    y
    
    long    speed_x
    long    speed_y
    
    long    paddle1_y
    long    paddle2_y
    
PUB Main
    lcd.Start(gfx.Start)
    ctrl.Start
    
    repeat
        ctrl.Update
        gfx.ClearScreen(0)

        
        if ctrl.Right
               x++
        if ctrl.Left
            x--
        if ctrl.Up
               paddle1_y--
        if ctrl.Down
               paddle1_y++
         
        gfx.Sprite(paddle.Addr, 4, paddle1_y, 0)
        gfx.Sprite(paddle.Addr, 116, paddle2_y, 0)
                
        gfx.Sprite(ball.Addr, x, y, 0)
        lcd.DrawScreen

