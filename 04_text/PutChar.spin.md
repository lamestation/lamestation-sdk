<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    
OBJ
    
    lcd     :   &quot;LameLCD&quot;
    gfx     :   &quot;LameGFX&quot;
    font    :   &quot;gfx_font8x8&quot;
        
PUB PutChar | x, ran, y, count, char
    
    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, &quot; &quot;, 0, 0)
    repeat
        gfx.ClearScreen(0)
        repeat count from 1 to 1000
            ran := cnt
            x := ran? &amp; $7F
            y := ran? &amp; $3F
            char := ran? &amp; %11111
            gfx.PutChar(&quot;A&quot; + char, x-8, y-8)
            lcd.DrawScreen
            </code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 04_text/PutChar.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    
OBJ
    
    lcd     :   &quot;LameLCD&quot;
    gfx     :   &quot;LameGFX&quot;
    font    :   &quot;gfx_font8x8&quot;
        
PUB PutChar | x, ran, y, count, char
    
    lcd.Start(gfx.Start)
    gfx.LoadFont(font.Addr, &quot; &quot;, 0, 0)
    repeat
        gfx.ClearScreen(0)
        repeat count from 1 to 1000
            ran := cnt
            x := ran? &amp; $7F
            y := ran? &amp; $3F
            char := ran? &amp; %11111
            gfx.PutChar(&quot;A&quot; + char, x-8, y-8)
            lcd.DrawScreen
            

</code></pre>
