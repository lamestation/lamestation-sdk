<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ

    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot;
    fn      :               &quot;LameFunctions&quot;

PUB Blit

    lcd.Start(gfx.Start)
    gfx.ClearScreen(gfx#WHITE)
    lcd.DrawScreen

    fn.Sleep(1000)
        
    gfx.ClearScreen(gfx#BLACK)
    lcd.DrawScreen

    fn.Sleep(1000)

    gfx.ClearScreen(gfx#GRAY)
    lcd.DrawScreen</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/clearscreen/02_Colors.spin
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
    fn      :               &quot;LameFunctions&quot;

PUB Blit

    lcd.Start(gfx.Start)
    gfx.ClearScreen(gfx#WHITE)
    lcd.DrawScreen

    fn.Sleep(1000)
        
    gfx.ClearScreen(gfx#BLACK)
    lcd.DrawScreen

    fn.Sleep(1000)

    gfx.ClearScreen(gfx#GRAY)
    lcd.DrawScreen

</code></pre>
