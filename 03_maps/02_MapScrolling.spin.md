---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 2: Map Scrolling"
section: "Section 3: Maps"

next_file: "03_ParallaxScrolling.spin.html"
next_name: "Step 3: Parallax Scrolling"

prev_file: "01_DrawMap.spin.html"
prev_name: "Step 1: Draw Map"
---
<p>You probably noticed that we only got to see a small portion of the beautiful map that we have. Well, that really stinks, and is unacceptable. So in this demo, we're going to set things up so that you can move around on the screen.</p>
<p>The main things that will be different about this exercise than the last are that we're adding a loop and <code>LameControl</code> to the application so that we can get user input.</p>
<h2 id="setup">Setup</h2>
<p>The setup is the same as before.</p>
<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd     :   &quot;LameLCD&quot; 
    gfx     :   &quot;LameGFX&quot;
    map     :   &quot;LameMap&quot;

    mp      :   &quot;map_cave&quot;
    tileset :   &quot;gfx_cave&quot;</code></pre>
<p>But now we're going to add <code>LameControl</code>.</p>
<pre><code>    ctrl    :   &quot;LameControl&quot;</code></pre>
<p>Let's also create some variables, so we'll be able to keep track of where things are as we're moving around.</p>
<p>The first variables are the X and Y offset. In other words, this is how far away from the top-left corner of the map we want to display.</p>
<p>INSERT DIAGRAM</p>
<p>We'll appropriately call our new variables <code>xoffset</code> and <code>yoffset</code></p>
<pre><code>VAR
    long    xoffset
    long    yoffset</code></pre>
<p>We're going to add some other fanciness. We don't want to fall off the map, so we're going to add boundaries to the screen.</p>
<pre><code>    long    bound_x
    long    bound_y</code></pre>
<p>Time to start up the main function and set up the SDK, like in the previous demo.</p>
<pre><code>PUB Main
    lcd.Start(gfx.Start)
    map.Load(tileset.Addr, mp.Addr)</code></pre>
<p>Here's where we actually set up and initialize the boundaries of the map.</p>
<pre><code>    bound_x := map.GetWidth&lt;&lt;3 - lcd#SCREEN_W
    bound_y := map.GetHeight&lt;&lt;3 - lcd#SCREEN_H</code></pre>
<p>There's some stuff happening here to be aware of.</p>
<ul>
<li><code>map.GetWidth</code>, <code>map.GetHeight</code> - these functions return the width and height of the currently loaded map in tiles. However, we don't want the number of tiles; we want the number of pixels, so we have to multiply by 8 since the tiles are 8x8 pixels in size.</li>
<li><code>lcd#SCREEN_W</code>, <code>lcd#SCREEN_H</code> - <code>LameLCD</code> defines these constants which return the size of the screen, or 128 and 64. We're substract these from the size of the screen because the player's view of the screen actually takes up size, and this prevents the camera from straying off the screen.</li>
</ul>
<p>INSERT DIAGRAM EXPLAINING HOW THE MAP MOVES RELATIVE TO THE TOP-LEFT CORNER</p>
<p>For fun, let's put the starting position of the map at the same place of the previous demo, so you can see how it's changed.</p>
<pre><code>    yoffset := bound_y</code></pre>
<h2 id="main-loop">Main Loop</h2>
<p>Starting the main loop!</p>
<pre><code>    repeat
        gfx.ClearScreen(0)</code></pre>
<p>Add a control block to keep the view inside the map. What's cool is that we're not the ones doing the moving. The map itself moves relative to the screen, giving the illusion that we're moving in a world, but we're not!!</p>
<pre><code>        ctrl.Update
        if ctrl.Up
            if yoffset &gt; 0
                yoffset--
        if ctrl.Down
            if yoffset &lt; bound_y
                yoffset++
        if ctrl.Left
            if xoffset &gt; 0
                xoffset--
        if ctrl.Right
            if xoffset &lt; bound_x
                xoffset++</code></pre>
<p>Draw to the screen.</p>
<pre><code>        map.Draw(xoffset, yoffset)
        lcd.DrawScreen</code></pre>
<p>The finished product. You are looking at the same map as before, but now you will be able to move back and forth across it.</p>
<div class="figure">
<img src="screenshots/pic2.png" alt="Somewhere else." /><p class="caption">Somewhere else.</p>
</div>
<div class="figure">
<img src="screenshots/pic4.png" alt="Somewhere more else." /><p class="caption">Somewhere more else.</p>
</div>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 03_maps/02_MapScrolling.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000
OBJ
    lcd     :   &quot;LameLCD&quot; 
    gfx     :   &quot;LameGFX&quot;
    map     :   &quot;LameMap&quot;

    mp      :   &quot;map_cave&quot;
    tileset :   &quot;gfx_cave&quot;
    ctrl    :   &quot;LameControl&quot;
VAR
    long    xoffset
    long    yoffset
    long    bound_x
    long    bound_y
PUB Main
    lcd.Start(gfx.Start)
    map.Load(tileset.Addr, mp.Addr)
    bound_x := map.GetWidth&lt;&lt;3 - lcd#SCREEN_W
    bound_y := map.GetHeight&lt;&lt;3 - lcd#SCREEN_H
    yoffset := bound_y
    repeat
        gfx.ClearScreen(0)
        ctrl.Update
        if ctrl.Up
            if yoffset &gt; 0
                yoffset--
        if ctrl.Down
            if yoffset &lt; bound_y
                yoffset++
        if ctrl.Left
            if xoffset &gt; 0
                xoffset--
        if ctrl.Right
            if xoffset &lt; bound_x
                xoffset++
        map.Draw(xoffset, yoffset)
        lcd.DrawScreen

</code></pre>
