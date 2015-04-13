<pre><code>CON

    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

    MAXSPRITES = 256
    BOUND_X = 128-16
    BOUND_Y = 64-16

OBJ

    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot; 
    ctrl    :               &quot;LameControl&quot;
    
    sprite  :               &quot;gfx_happyface&quot;
    font    :               &quot;gfx_font6x8&quot;

VAR

    long    x[MAXSPRITES]
    long    y[MAXSPRITES]
    long    speedx[MAXSPRITES]
    long    speedy[MAXSPRITES]
    byte    frame[MAXSPRITES]
    byte    framewait[MAXSPRITES]    
    byte    dir[MAXSPRITES]
    byte    framecounter[MAXSPRITES]
    
    byte    maxsprite
    
    byte    intarray[4]

PUB SpriteDemo | s, ran

    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, &quot; &quot;, 6, 8)
    
    gfx.ClearScreen(0)
    gfx.TextBox(string(&quot;Sprite Demo!&quot;,10,&quot;A/B changes the&quot;,10,&quot;number of sprites&quot;), 0, 0, 128, 64)
    gfx.Sprite(sprite.Addr, 56, 28, 1)
    gfx.TextBox(string(&quot;Press A to begin&quot;), 0, 56, 128, 64)
    lcd.DrawScreen
    
    repeat
        ctrl.Update
    until ctrl.A or ctrl.B

    maxsprite := 1
    repeat s from 0 to MAXSPRITES-1
        ran := cnt
        x[s] := (ran? &amp; $FF) // (lcd#SCREEN_W - 16)
        y[s] := (ran? &amp; $FF) // (lcd#SCREEN_H - 16)
        speedx[s] := ((ran? &amp; $FF // 9) - 4)
        speedy[s] := ((ran? &amp; $FF // 9) - 4)
        frame[s] := (ran? &amp; $FF) // 2
        framewait[s] := (ran? &amp; $FF) // 80
        dir[s] := (ran? &amp; $FF) // 4
    
    repeat
        gfx.ClearScreen(0)
        
        ctrl.Update
        
        if ctrl.A or ctrl.B
            if ctrl.A
                if maxsprite &gt; 1
                    maxsprite--
            if ctrl.B
                if maxsprite &lt; MAXSPRITES-1
                    maxsprite++
    
        repeat s from 0 to maxsprite-1
        
            if x[s] =&gt; BOUND_X or x[s] &lt; 0
                speedx[s] := -speedx[s]
            if y[s] =&gt; BOUND_Y or y[s] &lt; 0
                speedy[s] := -speedy[s]
                
            x[s] += speedx[s]
            y[s] += speedy[s]
            framecounter[s]++
            if framecounter[s] &gt; framewait[s]
                framecounter[s] := 0
                if frame[s]
                    frame[s] := 0
                else
                    frame[s] := 1
                    
                dir[s]++

            
            gfx.Sprite(sprite.Addr, x[s], y[s], (dir[s] &amp; $3)&lt;&lt;1 + frame[s])
        

        Overlay
        lcd.DrawScreen
        
PUB Overlay | tmp
    tmp := maxsprite
    intarray[2] := 48+(tmp // 10)
    tmp /= 10
    intarray[1] := 48+(tmp // 10)
    tmp /= 10
    intarray[0] := 48+(tmp // 10)
    intarray[3] := 0

    gfx.PutString(@intarray, 0, 0)</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/sprite/SpriteDemo.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON

    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

    MAXSPRITES = 256
    BOUND_X = 128-16
    BOUND_Y = 64-16

OBJ

    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot; 
    ctrl    :               &quot;LameControl&quot;
    
    sprite  :               &quot;gfx_happyface&quot;
    font    :               &quot;gfx_font6x8&quot;

VAR

    long    x[MAXSPRITES]
    long    y[MAXSPRITES]
    long    speedx[MAXSPRITES]
    long    speedy[MAXSPRITES]
    byte    frame[MAXSPRITES]
    byte    framewait[MAXSPRITES]    
    byte    dir[MAXSPRITES]
    byte    framecounter[MAXSPRITES]
    
    byte    maxsprite
    
    byte    intarray[4]

PUB SpriteDemo | s, ran

    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, &quot; &quot;, 6, 8)
    
    gfx.ClearScreen(0)
    gfx.TextBox(string(&quot;Sprite Demo!&quot;,10,&quot;A/B changes the&quot;,10,&quot;number of sprites&quot;), 0, 0, 128, 64)
    gfx.Sprite(sprite.Addr, 56, 28, 1)
    gfx.TextBox(string(&quot;Press A to begin&quot;), 0, 56, 128, 64)
    lcd.DrawScreen
    
    repeat
        ctrl.Update
    until ctrl.A or ctrl.B

    maxsprite := 1
    repeat s from 0 to MAXSPRITES-1
        ran := cnt
        x[s] := (ran? &amp; $FF) // (lcd#SCREEN_W - 16)
        y[s] := (ran? &amp; $FF) // (lcd#SCREEN_H - 16)
        speedx[s] := ((ran? &amp; $FF // 9) - 4)
        speedy[s] := ((ran? &amp; $FF // 9) - 4)
        frame[s] := (ran? &amp; $FF) // 2
        framewait[s] := (ran? &amp; $FF) // 80
        dir[s] := (ran? &amp; $FF) // 4
    
    repeat
        gfx.ClearScreen(0)
        
        ctrl.Update
        
        if ctrl.A or ctrl.B
            if ctrl.A
                if maxsprite &gt; 1
                    maxsprite--
            if ctrl.B
                if maxsprite &lt; MAXSPRITES-1
                    maxsprite++
    
        repeat s from 0 to maxsprite-1
        
            if x[s] =&gt; BOUND_X or x[s] &lt; 0
                speedx[s] := -speedx[s]
            if y[s] =&gt; BOUND_Y or y[s] &lt; 0
                speedy[s] := -speedy[s]
                
            x[s] += speedx[s]
            y[s] += speedy[s]
            framecounter[s]++
            if framecounter[s] &gt; framewait[s]
                framecounter[s] := 0
                if frame[s]
                    frame[s] := 0
                else
                    frame[s] := 1
                    
                dir[s]++

            
            gfx.Sprite(sprite.Addr, x[s], y[s], (dir[s] &amp; $3)&lt;&lt;1 + frame[s])
        

        Overlay
        lcd.DrawScreen
        
PUB Overlay | tmp
    tmp := maxsprite
    intarray[2] := 48+(tmp // 10)
    tmp /= 10
    intarray[1] := 48+(tmp // 10)
    tmp /= 10
    intarray[0] := 48+(tmp // 10)
    intarray[3] := 0

    gfx.PutString(@intarray, 0, 0)

</code></pre>
