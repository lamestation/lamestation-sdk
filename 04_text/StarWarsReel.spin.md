<pre><code>CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd      : &quot;LameLCD&quot;
    gfx      : &quot;LameGFX&quot;
    audio    : &quot;LameAudio&quot;
    music    : &quot;LameMusic&quot;
    
    font_6x8 : &quot;gfx_font6x8_normal_w&quot;
    song     : &quot;sng_ibelieve&quot;
        
PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)

    gfx.LoadFont(font_6x8.Addr, &quot; &quot;, 0, 0)

    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Loop

    repeat
        StarWarsReel(@inaworld,120)
        StarWarsReel(@imagine,120)
        StarWarsReel(@takeyour,120)
        StarWarsReel(@somuch,120)

PUB StarWarsReel(text,reeltime) | x
    
    repeat x from 0 to reeltime
        gfx.ClearScreen(0)
        gfx.TextBox(text, 16, 64-x, 96, 64) 
        lcd.DrawScreen

DAT

inaworld    byte    &quot;In a world&quot;,10,&quot;of awesome game&quot;,10,&quot;consoles...&quot;,10,10,10,&quot;One console&quot;,10,&quot;dares to be...&quot;,0
imagine     byte    &quot;Imagine...&quot;,10,10,&quot;A game console&quot;,10,&quot;where the rules&quot;,10,&quot;of business do&quot;,10,&quot;not apply.&quot;,0
takeyour    byte    &quot;Take your memory&quot;,10,10,&quot;Take your specs!&quot;,10,10,&quot;Don&#39;t need &#39;em!&quot;,0
somuch      byte    &quot;The most action-packed 32 kilo-&quot;,10,&quot;bytes you&#39;ll&quot;,10,&quot;ever have!&quot;,0</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 04_text/StarWarsReel.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ
    lcd      : &quot;LameLCD&quot;
    gfx      : &quot;LameGFX&quot;
    audio    : &quot;LameAudio&quot;
    music    : &quot;LameMusic&quot;
    
    font_6x8 : &quot;gfx_font6x8_normal_w&quot;
    song     : &quot;sng_ibelieve&quot;
        
PUB Main

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)

    gfx.LoadFont(font_6x8.Addr, &quot; &quot;, 0, 0)

    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Loop

    repeat
        StarWarsReel(@inaworld,120)
        StarWarsReel(@imagine,120)
        StarWarsReel(@takeyour,120)
        StarWarsReel(@somuch,120)

PUB StarWarsReel(text,reeltime) | x
    
    repeat x from 0 to reeltime
        gfx.ClearScreen(0)
        gfx.TextBox(text, 16, 64-x, 96, 64) 
        lcd.DrawScreen

DAT

inaworld    byte    &quot;In a world&quot;,10,&quot;of awesome game&quot;,10,&quot;consoles...&quot;,10,10,10,&quot;One console&quot;,10,&quot;dares to be...&quot;,0
imagine     byte    &quot;Imagine...&quot;,10,10,&quot;A game console&quot;,10,&quot;where the rules&quot;,10,&quot;of business do&quot;,10,&quot;not apply.&quot;,0
takeyour    byte    &quot;Take your memory&quot;,10,10,&quot;Take your specs!&quot;,10,10,&quot;Don&#39;t need &#39;em!&quot;,0
somuch      byte    &quot;The most action-packed 32 kilo-&quot;,10,&quot;bytes you&#39;ll&quot;,10,&quot;ever have!&quot;,0

</code></pre>
