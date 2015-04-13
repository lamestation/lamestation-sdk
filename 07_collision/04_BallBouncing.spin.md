---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 4: Ball Bouncing"
section: "Section 7: Collision"

next_file: "05_BallBouncingWithGravity.spin.html"
next_name: "Step 5: Ball Bouncing With Gravity"

prev_file: "03_TestMapMove.spin.html"
prev_name: "Step 3: Test Map Move"
---
<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd  :               &quot;LameLCD&quot; 
    gfx  :               &quot;LameGFX&quot;
    map  :               &quot;LameMap&quot;
    ctrl :               &quot;LameControl&quot;
    
    ball :               &quot;gfx_ball_16x16&quot;
    map1 :               &quot;map_map&quot;
    tile :               &quot;gfx_box_s&quot;
</code></pre>
<pre><code>VAR
    long    oldx, oldy
    long    x, y
    long    speedx, speedy
    long    adjust</code></pre>
<pre><code>CON
    w = 16
    h = 16
    maxspeed = 20</code></pre>
<pre><code>PUB Main
    lcd.Start(gfx.Start)
    map.Load(tile.Addr, map1.Addr)

    x := 12
    y := 12
    
    repeat
        gfx.ClearScreen(0)
        ctrl.Update</code></pre>
<pre><code>        oldx := x
        oldy := y

        &#39; use the joystick to control speed of the ball
        &#39; instead of position directly</code></pre>
<pre><code>        if ctrl.Left
            if speedx &gt; -maxspeed
                speedx--
        if ctrl.Right
            if speedx &lt; maxspeed
                speedx++

        x += speedx

        &#39; apply movement adjustments to ensure object stays within bounds</code></pre>
<pre><code>        adjust := map.TestMoveX(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], x)
        if adjust
            x += adjust
            speedx := -speedx

        &#39; then up and down</code></pre>
<pre><code>        if ctrl.Up
            if speedy &gt; -maxspeed
                speedy--
        if ctrl.Down
            if speedy &lt; maxspeed
                speedy++

        y += speedy

        &#39; apply movement adjustments to ensure object stays within bounds</code></pre>
<pre><code>        adjust := map.TestMoveY(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], y)
        if adjust
            y += adjust
            speedy := -speedy
</code></pre>
<pre><code>        map.Draw(0,0)
        gfx.Sprite(ball.Addr,x, y,0)

        lcd.DrawScreen</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 07_collision/04_BallBouncing.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd  :               &quot;LameLCD&quot; 
    gfx  :               &quot;LameGFX&quot;
    map  :               &quot;LameMap&quot;
    ctrl :               &quot;LameControl&quot;
    
    ball :               &quot;gfx_ball_16x16&quot;
    map1 :               &quot;map_map&quot;
    tile :               &quot;gfx_box_s&quot;

VAR
    long    oldx, oldy
    long    x, y
    long    speedx, speedy
    long    adjust
CON
    w = 16
    h = 16
    maxspeed = 20
PUB Main
    lcd.Start(gfx.Start)
    map.Load(tile.Addr, map1.Addr)

    x := 12
    y := 12
    
    repeat
        gfx.ClearScreen(0)
        ctrl.Update
        oldx := x
        oldy := y

        &#39; use the joystick to control speed of the ball
        &#39; instead of position directly
        if ctrl.Left
            if speedx &gt; -maxspeed
                speedx--
        if ctrl.Right
            if speedx &lt; maxspeed
                speedx++

        x += speedx

        &#39; apply movement adjustments to ensure object stays within bounds
        adjust := map.TestMoveX(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], x)
        if adjust
            x += adjust
            speedx := -speedx

        &#39; then up and down
        if ctrl.Up
            if speedy &gt; -maxspeed
                speedy--
        if ctrl.Down
            if speedy &lt; maxspeed
                speedy++

        y += speedy

        &#39; apply movement adjustments to ensure object stays within bounds
        adjust := map.TestMoveY(oldx, oldy, word[ball.Addr][1], word[ball.Addr][2], y)
        if adjust
            y += adjust
            speedy := -speedy

        map.Draw(0,0)
        gfx.Sprite(ball.Addr,x, y,0)

        lcd.DrawScreen

</code></pre>
