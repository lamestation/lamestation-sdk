<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd     :               &quot;LameLCD&quot;
        gfx     :               &quot;LameGFX&quot;
        font    :               &quot;gfx_font4x6&quot;
        
PUB Kerning

    lcd.Start(gfx.Start)

    gfx.ClearScreen(0)

    &#39; 0,0 loads default kerning, so normal letter spacing
    gfx.LoadFont(font.Addr, &quot; &quot;, 0, 0)
    gfx.TextBox(@strang,0,0,128,30)


    &#39; kerning can also be specified, giving rise to completely
    &#39; right or completely wrong sizes...
    gfx.LoadFont(font.Addr, &quot; &quot;, 6, 8)
    gfx.TextBox(@strang,0,16,128,30)

    gfx.LoadFont(font.Addr, &quot; &quot;, 10, 10)
    gfx.TextBox(@strang,0,32,128,30)

    gfx.LoadFont(font.Addr, &quot; &quot;, 3, 3)
    gfx.TextBox(@strang,0,52,128,30)

    lcd.DrawScreen

    repeat


DAT

strang  byte    &quot;This is cool&quot;,10,&quot;You think so?&quot;,0</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 04_text/Kerning.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd     :               &quot;LameLCD&quot;
        gfx     :               &quot;LameGFX&quot;
        font    :               &quot;gfx_font4x6&quot;
        
PUB Kerning

    lcd.Start(gfx.Start)

    gfx.ClearScreen(0)

    &#39; 0,0 loads default kerning, so normal letter spacing
    gfx.LoadFont(font.Addr, &quot; &quot;, 0, 0)
    gfx.TextBox(@strang,0,0,128,30)


    &#39; kerning can also be specified, giving rise to completely
    &#39; right or completely wrong sizes...
    gfx.LoadFont(font.Addr, &quot; &quot;, 6, 8)
    gfx.TextBox(@strang,0,16,128,30)

    gfx.LoadFont(font.Addr, &quot; &quot;, 10, 10)
    gfx.TextBox(@strang,0,32,128,30)

    gfx.LoadFont(font.Addr, &quot; &quot;, 3, 3)
    gfx.TextBox(@strang,0,52,128,30)

    lcd.DrawScreen

    repeat


DAT

strang  byte    &quot;This is cool&quot;,10,&quot;You think so?&quot;,0

</code></pre>
