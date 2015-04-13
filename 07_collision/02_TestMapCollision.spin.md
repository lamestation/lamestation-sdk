---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 2: Test Map Collision"
section: "Section 7: Collision"

next_file: "03_TestMapMove.spin.html"
next_name: "Step 3: Test Map Move"

prev_file: "01_TestBoxCollision.spin.html"
prev_name: "Step 1: Test Box Collision"
---
<p>In this tutorial, we're going to learn to check collision between a sprite and a <code>LameMap</code> level map.</p>
<p>Back to the basics.</p>
<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd  : &quot;LameLCD&quot; 
    gfx  : &quot;LameGFX&quot;
    ctrl : &quot;LameControl&quot;
    map  : &quot;LameMap&quot;</code></pre>
<p>Load up some box graphics like in the previous tutorial.</p>
<pre><code>    box  : &quot;gfx_box&quot;</code></pre>
<p>Now we're going to add some map graphics. Remember, loading a map consists of two pieces: the level data and the tilemap data.</p>
<pre><code>    map1 : &quot;map_map&quot;
    tile : &quot;gfx_box_s&quot;
</code></pre>
<p>Set up some variables to track the location of the box</p>
<pre><code>VAR
    byte    x1, y1</code></pre>
<p>Define the width and height as constants. CON w = 24 h = 24</p>
<p>Set up a main function like in the previous tutorial, with graphics and an initial box position.</p>
<pre><code>PUB Main
    lcd.Start(gfx.Start)
    x1 := 12
    y1 := 12</code></pre>
<p>Now we're going to load a map with <code>LameMap</code>. Pass the addresses of the level and tilemap data.</p>
<pre><code>    map.Load(tile.Addr, map1.Addr)</code></pre>
<p>Let's add the same set up from the previous example.</p>
<pre><code>    repeat
        gfx.ClearScreen(0)

        ctrl.Update
        if ctrl.Left
            if x1 &gt; 0
                x1--
        if ctrl.Right
            if x1 &lt; gfx#res_x-24
                x1++
        if ctrl.Up
            if y1 &gt; 0
                y1--
        if ctrl.Down
            if y1 &lt; gfx#res_y-24
                y1++
</code></pre>
<p>Unlike the last example though, now we're going to test to see if a map collision has occurred. This is done using the aptly named <code>TestCollision</code> command in the LameMap library. Pass the x- and y-position and the width and height of the sprite to use it. If a collision has occurred, invert the colors.</p>
<pre><code>        if map.TestCollision(x1, y1, w, h)
            gfx.InvertColor(True)</code></pre>
<p>Draw the map to the screen, and the sprite on top of it.</p>
<pre><code>        map.Draw(0,0)
        gfx.Sprite(box.Addr,x1,y1,0)
</code></pre>
<p>Reset the colors and draw to the screen.</p>
<pre><code>        gfx.InvertColor(False)
        lcd.DrawScreen

    </code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 07_collision/02_TestMapCollision.spin
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
    ctrl : &quot;LameControl&quot;
    map  : &quot;LameMap&quot;
    box  : &quot;gfx_box&quot;
    map1 : &quot;map_map&quot;
    tile : &quot;gfx_box_s&quot;

VAR
    byte    x1, y1
PUB Main
    lcd.Start(gfx.Start)
    x1 := 12
    y1 := 12
    map.Load(tile.Addr, map1.Addr)
    repeat
        gfx.ClearScreen(0)

        ctrl.Update
        if ctrl.Left
            if x1 &gt; 0
                x1--
        if ctrl.Right
            if x1 &lt; gfx#res_x-24
                x1++
        if ctrl.Up
            if y1 &gt; 0
                y1--
        if ctrl.Down
            if y1 &lt; gfx#res_y-24
                y1++

        if map.TestCollision(x1, y1, w, h)
            gfx.InvertColor(True)
        map.Draw(0,0)
        gfx.Sprite(box.Addr,x1,y1,0)

        gfx.InvertColor(False)
        lcd.DrawScreen

    

</code></pre>
