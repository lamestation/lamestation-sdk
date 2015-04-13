<pre><code>CON

    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ

    lcd      : &quot;LameLCD&quot;
    gfx      : &quot;LameGFX&quot;
    fn       : &quot;LameFunctions&quot;
    audio    : &quot;LameAudio&quot;
    music    : &quot;LameMusic&quot;
    
    font_6x8 : &quot;gfx_font6x8_normal_w&quot;
    famus    : &quot;gfx_spacegirl&quot;
    blehtrd  : &quot;sng_blehtroid&quot;
        
PUB TypewriterTextDemo | count

    lcd.Start(gfx.Start)

    audio.Start
    
    music.Start
    music.Load(blehtrd.Addr)
    music.Loop

    gfx.ClearScreen(0)

    gfx.Sprite(famus.Addr,38,0,0)

    lcd.DrawScreen
    fn.Sleep(2000)

    count := 0
    repeat
        Typewriter(string(&quot;I FIRST BATTLED THE&quot;,10,&quot;DURPEES ON THE PLANET&quot;,10,&quot;PHEEBES. IT WAS THERE&quot;,10,&quot;THAT I FOILED MY&quot;,10,&quot;DINNER AND HAD TO&quot;,10,&quot;ASK FOR THE CHECK...&quot;),0,0,128,64, 6, 8, count)
        count++
        fn.Sleep(80)

        lcd.DrawScreen
    while count &lt; 160


PUB Typewriter(stringvar, origin_x, origin_y, w, h, tilesize_x, tilesize_y, countmax) | char, x, y, count

    x := origin_x
    y := origin_y
    
    count := 0
    repeat strsize(stringvar)
        count++
        char := byte[stringvar++]
        if char == 10 or char == 13
            y += tilesize_y
            x := origin_x          
        elseif char == &quot; &quot;
            x += tilesize_x
        else   
            gfx.Sprite(font_6x8.Addr, x, y, char - &quot; &quot;)
            if x+tilesize_x =&gt; origin_x+w      
                y += tilesize_y
                x := origin_x
            else
                x += tilesize_x
        if count &gt; countmax
            return</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 04_text/Typewriter.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON

    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ

    lcd      : &quot;LameLCD&quot;
    gfx      : &quot;LameGFX&quot;
    fn       : &quot;LameFunctions&quot;
    audio    : &quot;LameAudio&quot;
    music    : &quot;LameMusic&quot;
    
    font_6x8 : &quot;gfx_font6x8_normal_w&quot;
    famus    : &quot;gfx_spacegirl&quot;
    blehtrd  : &quot;sng_blehtroid&quot;
        
PUB TypewriterTextDemo | count

    lcd.Start(gfx.Start)

    audio.Start
    
    music.Start
    music.Load(blehtrd.Addr)
    music.Loop

    gfx.ClearScreen(0)

    gfx.Sprite(famus.Addr,38,0,0)

    lcd.DrawScreen
    fn.Sleep(2000)

    count := 0
    repeat
        Typewriter(string(&quot;I FIRST BATTLED THE&quot;,10,&quot;DURPEES ON THE PLANET&quot;,10,&quot;PHEEBES. IT WAS THERE&quot;,10,&quot;THAT I FOILED MY&quot;,10,&quot;DINNER AND HAD TO&quot;,10,&quot;ASK FOR THE CHECK...&quot;),0,0,128,64, 6, 8, count)
        count++
        fn.Sleep(80)

        lcd.DrawScreen
    while count &lt; 160


PUB Typewriter(stringvar, origin_x, origin_y, w, h, tilesize_x, tilesize_y, countmax) | char, x, y, count

    x := origin_x
    y := origin_y
    
    count := 0
    repeat strsize(stringvar)
        count++
        char := byte[stringvar++]
        if char == 10 or char == 13
            y += tilesize_y
            x := origin_x          
        elseif char == &quot; &quot;
            x += tilesize_x
        else   
            gfx.Sprite(font_6x8.Addr, x, y, char - &quot; &quot;)
            if x+tilesize_x =&gt; origin_x+w      
                y += tilesize_y
                x := origin_x
            else
                x += tilesize_x
        if count &gt; countmax
            return

</code></pre>
