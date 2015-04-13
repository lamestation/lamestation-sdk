<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot;
    ctrl    :               &quot;LameControl&quot;
    fn      :               &quot;LameFunctions&quot;
    
    ball    :               &quot;gfx_rollerball&quot;
    font    :               &quot;gfx_font6x8&quot;
    
VAR
    byte    ball_frame
    byte    ball_count
    long    ball_x, ball_y
    byte    blinktimeout
    byte    blinktoggle
    word    failtimeout
PUB Blit | val

    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, &quot; &quot;, 6, 8)
    ctrl.Start
    
    ball_x := 64
    ball_y := 24
    
    val := %%1000_0000_1000_0000
    repeat
        gfx.ClearScreen(val)

    
        if ball_x &lt; -16
            failtimeout++
            gfx.PutString(string(&quot;YOU FAILED&quot;),30,29)
            if failtimeout &gt; 128
                ball_x := 64
                ball_y := 24
                failtimeout := 0
            
        else 
            ctrl.Update
            if ctrl.Up
                if ball_y &gt; 0
                    ball_y--
            if ctrl.Down
                if ball_y &lt; 48
                    ball_y++
            if ctrl.Left
                ball_x--
                ball_count--
            if ctrl.Right
                ball_x++
                ball_count++
            ball_count++
            if ball_count &gt; 3
                ball_count := 0
                ball_frame++
                ball_x--
                if ball_frame &gt; 4
                    ball_frame := 0
                
            gfx.Sprite(ball.Addr, ball_x, ball_y, 4-ball_frame)
        
            if ball_x &lt; 30
                blinktimeout++
                if blinktimeout &gt; 24
                    blinktimeout := 0
                    if blinktoggle
                        blinktoggle := 0
                    else
                        blinktoggle := 1
            else    
                blinktoggle := 0
                       

            if blinktoggle
                gfx.InvertColor(True)
                gfx.PutString(string(&quot;OH NO GO RIGHT!&quot;),0,0)
                gfx.InvertColor(False)
            
        lcd.DrawScreen
        val -&gt;= 2</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/clearscreen/05_RollerBall.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot;
    ctrl    :               &quot;LameControl&quot;
    fn      :               &quot;LameFunctions&quot;
    
    ball    :               &quot;gfx_rollerball&quot;
    font    :               &quot;gfx_font6x8&quot;
    
VAR
    byte    ball_frame
    byte    ball_count
    long    ball_x, ball_y
    byte    blinktimeout
    byte    blinktoggle
    word    failtimeout
PUB Blit | val

    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, &quot; &quot;, 6, 8)
    ctrl.Start
    
    ball_x := 64
    ball_y := 24
    
    val := %%1000_0000_1000_0000
    repeat
        gfx.ClearScreen(val)

    
        if ball_x &lt; -16
            failtimeout++
            gfx.PutString(string(&quot;YOU FAILED&quot;),30,29)
            if failtimeout &gt; 128
                ball_x := 64
                ball_y := 24
                failtimeout := 0
            
        else 
            ctrl.Update
            if ctrl.Up
                if ball_y &gt; 0
                    ball_y--
            if ctrl.Down
                if ball_y &lt; 48
                    ball_y++
            if ctrl.Left
                ball_x--
                ball_count--
            if ctrl.Right
                ball_x++
                ball_count++
            ball_count++
            if ball_count &gt; 3
                ball_count := 0
                ball_frame++
                ball_x--
                if ball_frame &gt; 4
                    ball_frame := 0
                
            gfx.Sprite(ball.Addr, ball_x, ball_y, 4-ball_frame)
        
            if ball_x &lt; 30
                blinktimeout++
                if blinktimeout &gt; 24
                    blinktimeout := 0
                    if blinktoggle
                        blinktoggle := 0
                    else
                        blinktoggle := 1
            else    
                blinktoggle := 0
                       

            if blinktoggle
                gfx.InvertColor(True)
                gfx.PutString(string(&quot;OH NO GO RIGHT!&quot;),0,0)
                gfx.InvertColor(False)
            
        lcd.DrawScreen
        val -&gt;= 2

</code></pre>
