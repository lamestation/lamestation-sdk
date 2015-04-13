<p>This tutorial demonstrates that the Propeller itself is alive by blinking a connected LED. It verifies that the crystal oscillator is working too.</p>
<p>We can use the <code>Pinout</code> object to get the pin that the LED is on.</p>
<pre><code>OBJ
    pin : &quot;Pinout&quot;</code></pre>
<pre><code>CON
    LED_PIN = pin#LED</code></pre>
<p>Set some arbitrary delay. 1000 seems like a friendly number. You'll see if you use some different values. 1000 is long enough to see, short enough that you're not going to be waiting for it.</p>
<pre><code>    LED_PERIOD = 1000
</code></pre>
<pre><code>PUB Main </code></pre>
<p>There are three commands that allow you to interact with the world on your Propeller. These are <code>ina</code>, <code>outa</code>, and <code>dira</code>.</p>
<p>A register sounds exciting but it's not. There's 32 pins on the Propeller, and there's 32 switches in each of these registers.</p>
<p>WHAT'S A REGISTER? THIS IS TOO LOW-LEVEL; NOT BASIC AT ALL</p>
<pre><code>    dira[LED_PIN]~~
</code></pre>
<p>Let's set up an infinite loop forever. In Spin, that's super easy. Just use the <code>repeat</code> command.</p>
<pre><code>    repeat</code></pre>
<p>There are a few commands that make working with external pins possible. i</p>
<pre><code>        outa[LED_PIN]~
        </code></pre>
<p>Sometimes you really just want the microcontroller to just WAIT for something else to happen, but sometimes you don't really care how long. For a quick and dirty delay, I usually just like to call a <code>repeat</code> for a certain amount of time.</p>
<pre><code>        repeat LED_PERIOD</code></pre>
<pre><code>        outa[LED_PIN]~~
        </code></pre>
<pre><code>        repeat LED_PERIOD</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 01_basics/ImAlive.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
OBJ
    pin : &quot;Pinout&quot;
CON
    LED_PIN = pin#LED
    LED_PERIOD = 1000

PUB Main 
    dira[LED_PIN]~~

    repeat
        outa[LED_PIN]~
        
        repeat LED_PERIOD
        outa[LED_PIN]~~
        
        repeat LED_PERIOD

</code></pre>
