<pre><code>CON
    _clkmode = xtal1|pll16x
    _xinfreq = 5_000_000

OBJ
    lcd     :               &quot;LameLCD&quot; 
    gfx     :               &quot;LameGFX&quot;
    ctrl    :               &quot;LameControl&quot;

    sprite  :               &quot;gfx_supertank&quot;

VAR
    byte    apress

PUB Main | dir,frame

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)
    ctrl.Start

    repeat
        gfx.ClearScreen(0)

        ctrl.Update
        if ctrl.A
            frame := 0
            if not apress     
                apress := 1           
                frame := 2            
        else
            apress := 0
            if ctrl.Left or ctrl.Right or ctrl.Up or ctrl.Down
                if frame
                    frame := 0
                else
                    frame := 1
            else
                frame := 0

        if ctrl.Left
            dir := 0
        if ctrl.Right
            dir := 1
        if ctrl.Up
            dir := 2
        if ctrl.Down
            dir := 3

        gfx.Sprite(sprite.Addr, 56, 24, dir*3+frame)
        lcd.DrawScreen</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/sprite/03_Character.spin
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
    ctrl    :               &quot;LameControl&quot;

    sprite  :               &quot;gfx_supertank&quot;

VAR
    byte    apress

PUB Main | dir,frame

    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#QUARTERSPEED)
    ctrl.Start

    repeat
        gfx.ClearScreen(0)

        ctrl.Update
        if ctrl.A
            frame := 0
            if not apress     
                apress := 1           
                frame := 2            
        else
            apress := 0
            if ctrl.Left or ctrl.Right or ctrl.Up or ctrl.Down
                if frame
                    frame := 0
                else
                    frame := 1
            else
                frame := 0

        if ctrl.Left
            dir := 0
        if ctrl.Right
            dir := 1
        if ctrl.Up
            dir := 2
        if ctrl.Down
            dir := 3

        gfx.Sprite(sprite.Addr, 56, 24, dir*3+frame)
        lcd.DrawScreen

</code></pre>
