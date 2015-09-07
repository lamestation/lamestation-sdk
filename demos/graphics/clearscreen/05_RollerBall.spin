CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     :               "LameLCD"
    gfx     :               "LameGFX"
    ctrl    :               "LameControl"
    fn      :               "LameFunctions"

    ball    :               "gfx_rollerball"
    font    :               "gfx_font6x8"

VAR
    byte    ball_frame
    byte    ball_count
    long    ball_x, ball_y
    byte    blinktimeout
    byte    blinktoggle
    word    failtimeout
    
PUB Main | val
    lcd.Start(gfx.Start)
    
    gfx.LoadFont(font.Addr, " ", 6, 8)
    ctrl.Start

    ball_x := 64
    ball_y := 24

    val := %%1000_0000_1000_0000
    repeat
        gfx.ClearScreen(val)

        if ball_x < -16
            failtimeout++
            gfx.PutString(string("YOU FAILED"),30,29)
            if failtimeout > 128
                ball_x := 64
                ball_y := 24
                failtimeout := 0

        else
            ctrl.Update
            if ctrl.Up
                if ball_y > 0
                    ball_y--
            if ctrl.Down
                if ball_y < 48
                    ball_y++
            if ctrl.Left
                ball_x--
                ball_count--
            if ctrl.Right
                ball_x++
                ball_count++
            ball_count++
            if ball_count > 3
                ball_count := 0
                ball_frame++
                ball_x--
                if ball_frame > 4
                    ball_frame := 0

            gfx.Sprite(ball.Addr, ball_x, ball_y, 4-ball_frame)

            if ball_x < 30
                blinktimeout++
                if blinktimeout > 24
                    blinktimeout := 0
                    if blinktoggle
                        blinktoggle := 0
                    else
                        blinktoggle := 1
            else
                blinktoggle := 0

            if blinktoggle
                gfx.InvertColor(True)
                gfx.PutString(string("OH NO GO RIGHT!"),0,0)
                gfx.InvertColor(False)

        lcd.DrawScreen
        val ->= 2
