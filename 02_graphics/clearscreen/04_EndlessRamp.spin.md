<p>This demo shows you how a simple ClearScreen command can be used to make something not so obvious.</p>
<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot;
    fn      :               &quot;LameFunctions&quot;
    
PUB Blit | val
    lcd.Start(gfx.Start)
    
    val := %%1000_0000_1000_0000
    repeat
        gfx.ClearScreen(val)
        lcd.DrawScreen
        val -&gt;= 2</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/clearscreen/04_EndlessRamp.spin
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
    
PUB Blit | val
    lcd.Start(gfx.Start)
    
    val := %%1000_0000_1000_0000
    repeat
        gfx.ClearScreen(val)
        lcd.DrawScreen
        val -&gt;= 2

</code></pre>
