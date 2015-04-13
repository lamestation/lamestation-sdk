---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 3: Test Map Move"
section: "Section 7: Collision"

next_file: "04_BallBouncing.spin.html"
next_name: "Step 4: Ball Bouncing"

prev_file: "02_TestMapCollision.spin.html"
prev_name: "Step 2: Test Map Collision"
---
<p>Now let's take collision to the next level. Let's do more than detect that a collision has occurred; we are going to use that information to make sure that the ball stays outside of the map. This is the starting point for any game that might potentially have walls or obstacles that the player can't cross.</p>
<p>Add the usual set up, with a box and map.</p>
<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd  : &quot;LameLCD&quot; 
    gfx  : &quot;LameGFX&quot;
    map  : &quot;LameMap&quot;
    ctrl : &quot;LameControl&quot;
    
    box  : &quot;gfx_box&quot;

    map1 : &quot;map_map&quot;
    tile : &quot;gfx_box_s&quot;

CON
    w = 24
    h = 24
</code></pre>
<p>Now we're really going to need those long values. Add the <code>x</code> and <code>y</code> constants like in the previous tutorial.</p>
<pre><code>VAR
    long    x, y</code></pre>
<p>But this time we need to add a little something extra. We need to keep track of some extra information.</p>
<p><code>oldx</code>, <code>oldy</code> will be used to save the last position of the <code>x</code> and <code>y</code> variables before they were changed.</p>
<pre><code>    long    oldx, oldy</code></pre>
<p><code>adjust</code> will be a temporary variable that we will explain a few lines from now. For now, define it.</p>
<pre><code>    long    adjust</code></pre>
<p>A setup similar to the previous tutorial.</p>
<pre><code>PUB Main

    lcd.Start(gfx.Start)
    map.Load(tile.Addr, map1.Addr)

    x := 12
    y := 12
    
    repeat
        gfx.ClearScreen(0)</code></pre>
<p>We were going to save the <code>x</code> and <code>y</code> position at the start of every loop. Here's where we do that.</p>
<pre><code>        oldx := x
        oldy := y</code></pre>
<p>Now we want to move the box with the joystick. The movement code is the same as in the previous tutorial. However, we will be splitting it up horizontally and vertically so that we can apply corrections to the movement.</p>
<p>Left and right movement.</p>
<pre><code>        ctrl.Update
        if ctrl.Left
            if x &gt; 0
                x--
        if ctrl.Right
            if x &lt; gfx#res_x
                x++
</code></pre>
<p>Now the <code>adjust</code> variable comes into play. <code>TestMoveX</code> returns an integer offset that equals the number of pixels that your box has cross over into the map tile. This number is calculated based on:</p>
<ul>
<li>The old <code>x</code> and <code>y</code> positions</li>
<li>The width and height of the object</li>
<li>Finally, the <strong>new</strong> horizontal position</li>
</ul>
<p>We will store the result of this command in the <code>adjust</code> variable.</p>
<pre><code>        adjust := map.TestMoveX(oldx, oldy, word[box.Addr][1], word[box.Addr][2], x)</code></pre>
<p>If <code>adjust</code> is not zero, we will use it to apply a correction to the object's position.</p>
<pre><code>        if adjust
            x += adjust</code></pre>
<p>So you can see it, let's invert the colors.</p>
<pre><code>            gfx.InvertColor(True)
</code></pre>
<p>Now we are basically doing to the same thing, but changing it for up and down movement.</p>
<pre><code>        if ctrl.Up
            if y &gt; 0
                y--
        if ctrl.Down
            if y &lt; gfx#res_y
                y++

        adjust := map.TestMoveY(oldx, oldy, word[box.Addr][1], word[box.Addr][2], y)
        if adjust
            y += adjust
            gfx.InvertColor(True)</code></pre>
<p>Draw the map and sprite to the screen.</p>
<pre><code>        map.Draw(0,0)
        gfx.Sprite(box.Addr,x, y,0)

        gfx.InvertColor(False)
        lcd.DrawScreen</code></pre>
<p>And now you can't do crazy things like travel through walls!</p>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 07_collision/03_TestMapMove.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd  : &quot;LameLCD&quot; 
    gfx  : &quot;LameGFX&quot;
    map  : &quot;LameMap&quot;
    ctrl : &quot;LameControl&quot;
    
    box  : &quot;gfx_box&quot;

    map1 : &quot;map_map&quot;
    tile : &quot;gfx_box_s&quot;

CON
    w = 24
    h = 24

VAR
    long    x, y
    long    oldx, oldy
    long    adjust
PUB Main

    lcd.Start(gfx.Start)
    map.Load(tile.Addr, map1.Addr)

    x := 12
    y := 12
    
    repeat
        gfx.ClearScreen(0)
        oldx := x
        oldy := y
        ctrl.Update
        if ctrl.Left
            if x &gt; 0
                x--
        if ctrl.Right
            if x &lt; gfx#res_x
                x++

        adjust := map.TestMoveX(oldx, oldy, word[box.Addr][1], word[box.Addr][2], x)
        if adjust
            x += adjust
            gfx.InvertColor(True)

        if ctrl.Up
            if y &gt; 0
                y--
        if ctrl.Down
            if y &lt; gfx#res_y
                y++

        adjust := map.TestMoveY(oldx, oldy, word[box.Addr][1], word[box.Addr][2], y)
        if adjust
            y += adjust
            gfx.InvertColor(True)
        map.Draw(0,0)
        gfx.Sprite(box.Addr,x, y,0)

        gfx.InvertColor(False)
        lcd.DrawScreen

</code></pre>
