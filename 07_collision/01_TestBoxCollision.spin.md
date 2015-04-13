---
date: 2015-04-13
version: 0.0.0
layout: learnpage
title: "Step 1: Test Box Collision"
section: "Section 7: Collision"

next_file: "02_TestMapCollision.spin.html"
next_name: "Step 2: Test Map Collision"

---
<p>Add the basic building blocks.</p>
<pre><code>CON

    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000</code></pre>
<p>You will need <code>LameLCD</code>, <code>LameGFX</code>, <code>LameControl</code>, and <code>LameFunctions</code> for this demo.</p>
<pre><code>OBJ
    lcd  :               &quot;LameLCD&quot; 
    gfx  :               &quot;LameGFX&quot;
    ctrl :               &quot;LameControl&quot;
    fn   :               &quot;LameFunctions&quot;</code></pre>
<p>Plus a little something extra. Add some slick graphics for a box, because how cool are you!</p>
<pre><code>    box  :               &quot;gfx_box&quot;
    boxo :               &quot;gfx_box_o&quot;</code></pre>
<p>Basic collision requires a bounding box, or the square that defines an object's location. All we need to know is the position of the top-left and the bottom-right corners of the image to know the bounding box. Then, we need this information for both objects that will interact with each other.</p>
<p>We'll store these values in their own variables. Since we're not making a full game and the size of the screen is very small, we'll store the positions in bytes, because we're cool.</p>
<p><em>In reality though, we should be using the <code>long</code> data type, because then we won't have to worry about sign errors if our program gets even slightly complicated.</em></p>
<pre><code>VAR
    byte    x1, y1
    byte    x2, y2</code></pre>
<p>We're going to be adding a large square to the screen, but to do collision, we really need to know how big the image is. There's a few way to do this. The LameGFX image format contains the width and height of an image, but it's slower to use the access functions than to use a hard-coded value. Since we know the size of the image in advantage, oh, whatever! Just define some constants!</p>
<pre><code>CON
    w = 24
    h = 24</code></pre>
<p>Now for the main function.</p>
<pre><code>PUB Main
</code></pre>
<p>Business as usual.</p>
<pre><code>    lcd.Start(gfx.Start)</code></pre>
<p>Now we need to initialize the position of the second object.</p>
<pre><code>    x2 := 52
    y2 := 20
    </code></pre>
<p>Let's start up a program loop so we can move around.</p>
<pre><code>    repeat</code></pre>
<p>Clear the screen to black so that moving around won't leave a trail on the screen.</p>
<pre><code>        gfx.ClearScreen(0)
</code></pre>
<p>Let's take box #1 (which has the position <code>(x1, y1)</code>) and allow the player to move it around on the screen. <strong>BUT!</strong> We will be careful and not let the box move off the screen (because who wants <em>that</em>!).</p>
<pre><code>        ctrl.Update
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
                y1++</code></pre>
<p>Let's invert the colors of the boxes if they are overlapping. This will provide a very obvious visual cue that something has happened.</p>
<pre><code>        if fn.TestBoxCollision(x1, y1, w, h, x2, y2, w, h)
            gfx.InvertColor(True)
</code></pre>
<p>Now we draw the boxes to the drawing buffer using the <code>Sprite</code> command.</p>
<pre><code>        gfx.Sprite(boxo.Addr,x1,y1,0)
        gfx.Sprite(boxo.Addr,x2,y2,0)</code></pre>
<p>This extra sprite gives us the nice overlapping box effect we like.</p>
<pre><code>        gfx.Sprite(box.Addr,x1,y1,0)
</code></pre>
<p>Always remember to turn off color inversion when you're done with it, so the rest of your program behaves the way that you expect it to.</p>
<pre><code>        gfx.InvertColor(False)
</code></pre>
<p>Finally take the drawing buffer and copy it to the screen.</p>
<pre><code>        lcd.DrawScreen</code></pre>
<p>Now run our program and see how awesome it is!</p>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 07_collision/01_TestBoxCollision.spin
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
    ctrl :               &quot;LameControl&quot;
    fn   :               &quot;LameFunctions&quot;
    box  :               &quot;gfx_box&quot;
    boxo :               &quot;gfx_box_o&quot;
VAR
    byte    x1, y1
    byte    x2, y2
CON
    w = 24
    h = 24
PUB Main

    lcd.Start(gfx.Start)
    x2 := 52
    y2 := 20
    
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
        if fn.TestBoxCollision(x1, y1, w, h, x2, y2, w, h)
            gfx.InvertColor(True)

        gfx.Sprite(boxo.Addr,x1,y1,0)
        gfx.Sprite(boxo.Addr,x2,y2,0)
        gfx.Sprite(box.Addr,x1,y1,0)

        gfx.InvertColor(False)

        lcd.DrawScreen

</code></pre>
