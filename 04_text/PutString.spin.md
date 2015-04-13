<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd  : &quot;LameLCD&quot;
        gfx  : &quot;LameGFX&quot;
        
        font : &quot;gfx_font6x8&quot;
        
PUB Main

    lcd.Start(gfx.Start)

    gfx.LoadFont(font.Addr, &quot; &quot;, 0, 0)
    gfx.PutString(string(&quot;THIS IS A TEST&quot;),4,28)

    lcd.DrawScreen</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 04_text/PutString.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd  : &quot;LameLCD&quot;
        gfx  : &quot;LameGFX&quot;
        
        font : &quot;gfx_font6x8&quot;
        
PUB Main

    lcd.Start(gfx.Start)

    gfx.LoadFont(font.Addr, &quot; &quot;, 0, 0)
    gfx.PutString(string(&quot;THIS IS A TEST&quot;),4,28)

    lcd.DrawScreen

</code></pre>
