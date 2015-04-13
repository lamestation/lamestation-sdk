<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot;

    sprite  :               &quot;gfx_radar&quot;


PUB Main | frame

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)
    repeat
        gfx.Sprite(sprite.Addr, 56, 24, frame)
        lcd.DrawScreen
        frame++
        if frame &gt; 15
            frame := 0</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/sprite/02_Frames.spin
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

    sprite  :               &quot;gfx_radar&quot;


PUB Main | frame

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)
    repeat
        gfx.Sprite(sprite.Addr, 56, 24, frame)
        lcd.DrawScreen
        frame++
        if frame &gt; 15
            frame := 0

</code></pre>
