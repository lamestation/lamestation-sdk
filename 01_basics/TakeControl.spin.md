<p>This app verifies the on-board controls of the LS are working by blinking the test LED whenever the joystick or buttons are pressed.</p>
<pre><code>CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    
OBJ
    ctrl    : &quot;LameControl&quot;
    pin     : &quot;Pinout&quot;

CON
    LED_PIN = pin#LED

PUB Main

    dira[LED_PIN]~~

    repeat
        ctrl.Update

        if ctrl.A or ctrl.B or ctrl.Up or ctrl.Down or ctrl.Left or ctrl.Right
            outa[LED_PIN]~~
        else
            outa[LED_PIN]~</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 01_basics/TakeControl.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000
    
OBJ
    ctrl    : &quot;LameControl&quot;
    pin     : &quot;Pinout&quot;

CON
    LED_PIN = pin#LED

PUB Main

    dira[LED_PIN]~~

    repeat
        ctrl.Update

        if ctrl.A or ctrl.B or ctrl.Up or ctrl.Down or ctrl.Left or ctrl.Right
            outa[LED_PIN]~~
        else
            outa[LED_PIN]~

</code></pre>
