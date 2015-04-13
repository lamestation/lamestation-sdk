<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
        lcd     :               &quot;LameLCD&quot;
        gfx     :               &quot;LameGFX&quot;
        fn      :               &quot;LameFunctions&quot;
        audio   :               &quot;LameAudio&quot;
        
        font_8x8    :           &quot;gfx_font8x8&quot;
        font_6x8    :           &quot;gfx_font6x8&quot;
        font_4x4    :           &quot;gfx_font4x4&quot;
        
PUB TextDemo | x, ran, y

    lcd.Start(gfx.Start)
    audio.Start

    repeat
        gfx.ClearScreen(0)

        ThisIsATest
        ZoomToCenter
        HouseOfLeaves     

PUB ThisIsATest
    gfx.LoadFont(font_8x8.Addr, &quot; &quot;, 8, 8)
    gfx.ClearScreen(0)
    gfx.PutString(string(&quot;THIS IS A TEST&quot;),4,28)
    lcd.DrawScreen
    fn.Sleep(1000)


    gfx.ClearScreen(0)
    gfx.PutString(string(&quot;DO NOT ADJUST&quot;),10,24)
    gfx.PutString(string(&quot;YOUR BRAIN&quot;),15,32)
    lcd.DrawScreen
    fn.Sleep(1000)    


PUB HouseOfLeaves
        
    gfx.LoadFont(font_4x4.Addr, &quot; &quot;, 4, 4)        
        
    gfx.PutChar(&quot;c&quot;, 120, 0)
       
    gfx.PutString(string(&quot;Super Texty Fun-Time?&quot;), 0, 0)
    gfx.PutString(string(&quot;Wow, this isn&#39;t legible at all!&quot;), 0, 40)
    gfx.PutString(string(&quot;Well, kind of, actually.&quot;), 0, 44)
    gfx.PutString(@allcharacters, 0, 5)        
        
    gfx.TextBox(string(&quot;Lorem ipsum dolor chicken bacon inspector cats and more&quot;), 52, 32, 5, 32)                 
    lcd.DrawScreen
    fn.Sleep(2000)
    
    gfx.ClearScreen(0)     
    gfx.TextBox(string(&quot;I recently added LoadFont, PutChar and PutString functions to LameGFX.spin. I used to use the TextBox command, which used the format you described to draw to the screen, but now that LameGFX uses a linear framebuffer, that approach doesn&#39;t make sense anymore. PutChar and PutString work by simply using the Box command. I&#39;m working on supporting arbitrary font sizes, variable-width fonts, and a one-bit color mode so that fonts don&#39;t waste space.&quot;),1,1,120,56)
    lcd.DrawScreen
    fn.Sleep(2000) 
        
    gfx.LoadFont(font_8x8.Addr, &quot; &quot;, 8, 8)
    gfx.PutString(string(&quot;A LOT OF TEXT&quot;), 6, 32)
    lcd.DrawScreen
    fn.Sleep(2000) 
        
    gfx.ClearScreen(0)
    lcd.DrawScreen
    fn.Sleep(1000) 


PUB ZoomToCenter | x, y, ax, ay, vx, vy, m, ran, count, count2, centerx, centery
    gfx.LoadFont(font_8x8.Addr, &quot; &quot;, 8, 8)
    gfx.ClearScreen(0)
    
    centerx := 64
    centery := 32
    vx := 10
    vy := 0
        ran := cnt
        x := ran? &amp; $7F
        y := ran? &amp; $3F
        repeat count2 from 1 to 200
            gfx.ClearScreen(0)
            
            ax := (centerx - x)/20
            ay := (centery - y)/20
            
            vx += ax
            vy += ay
            
            x += vx
            y += vy
           
            gfx.PutString(string(&quot;BUY ME!!&quot;), x-16, y-4)
            gfx.PutString(string(&quot;SUBLIMINAL&quot;), 12, 32)
            lcd.DrawScreen   
    
DAT
&#39;&#39;Strings need to be null-terminated
allcharacters   byte    &quot;!&quot;,34,&quot;#$%&amp;&#39;()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz&quot;,0</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 04_text/TextDemo.spin
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
        fn      :               &quot;LameFunctions&quot;
        audio   :               &quot;LameAudio&quot;
        
        font_8x8    :           &quot;gfx_font8x8&quot;
        font_6x8    :           &quot;gfx_font6x8&quot;
        font_4x4    :           &quot;gfx_font4x4&quot;
        
PUB TextDemo | x, ran, y

    lcd.Start(gfx.Start)
    audio.Start

    repeat
        gfx.ClearScreen(0)

        ThisIsATest
        ZoomToCenter
        HouseOfLeaves     

PUB ThisIsATest
    gfx.LoadFont(font_8x8.Addr, &quot; &quot;, 8, 8)
    gfx.ClearScreen(0)
    gfx.PutString(string(&quot;THIS IS A TEST&quot;),4,28)
    lcd.DrawScreen
    fn.Sleep(1000)


    gfx.ClearScreen(0)
    gfx.PutString(string(&quot;DO NOT ADJUST&quot;),10,24)
    gfx.PutString(string(&quot;YOUR BRAIN&quot;),15,32)
    lcd.DrawScreen
    fn.Sleep(1000)    


PUB HouseOfLeaves
        
    gfx.LoadFont(font_4x4.Addr, &quot; &quot;, 4, 4)        
        
    gfx.PutChar(&quot;c&quot;, 120, 0)
       
    gfx.PutString(string(&quot;Super Texty Fun-Time?&quot;), 0, 0)
    gfx.PutString(string(&quot;Wow, this isn&#39;t legible at all!&quot;), 0, 40)
    gfx.PutString(string(&quot;Well, kind of, actually.&quot;), 0, 44)
    gfx.PutString(@allcharacters, 0, 5)        
        
    gfx.TextBox(string(&quot;Lorem ipsum dolor chicken bacon inspector cats and more&quot;), 52, 32, 5, 32)                 
    lcd.DrawScreen
    fn.Sleep(2000)
    
    gfx.ClearScreen(0)     
    gfx.TextBox(string(&quot;I recently added LoadFont, PutChar and PutString functions to LameGFX.spin. I used to use the TextBox command, which used the format you described to draw to the screen, but now that LameGFX uses a linear framebuffer, that approach doesn&#39;t make sense anymore. PutChar and PutString work by simply using the Box command. I&#39;m working on supporting arbitrary font sizes, variable-width fonts, and a one-bit color mode so that fonts don&#39;t waste space.&quot;),1,1,120,56)
    lcd.DrawScreen
    fn.Sleep(2000) 
        
    gfx.LoadFont(font_8x8.Addr, &quot; &quot;, 8, 8)
    gfx.PutString(string(&quot;A LOT OF TEXT&quot;), 6, 32)
    lcd.DrawScreen
    fn.Sleep(2000) 
        
    gfx.ClearScreen(0)
    lcd.DrawScreen
    fn.Sleep(1000) 


PUB ZoomToCenter | x, y, ax, ay, vx, vy, m, ran, count, count2, centerx, centery
    gfx.LoadFont(font_8x8.Addr, &quot; &quot;, 8, 8)
    gfx.ClearScreen(0)
    
    centerx := 64
    centery := 32
    vx := 10
    vy := 0
        ran := cnt
        x := ran? &amp; $7F
        y := ran? &amp; $3F
        repeat count2 from 1 to 200
            gfx.ClearScreen(0)
            
            ax := (centerx - x)/20
            ay := (centery - y)/20
            
            vx += ax
            vy += ay
            
            x += vx
            y += vy
           
            gfx.PutString(string(&quot;BUY ME!!&quot;), x-16, y-4)
            gfx.PutString(string(&quot;SUBLIMINAL&quot;), 12, 32)
            lcd.DrawScreen   
    
DAT
&#39;&#39;Strings need to be null-terminated
allcharacters   byte    &quot;!&quot;,34,&quot;#$%&amp;&#39;()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz&quot;,0

</code></pre>
