<pre><code>&#39;&#39;
&#39;&#39; simple clipping demo
&#39;&#39;
&#39;&#39;        Author: Marko Lukat
&#39;&#39; Last modified: 2014/06/17
&#39;&#39;       Version: 0.6
&#39;&#39;
&#39;&#39; use joystick for moving around
&#39;&#39;
&#39;&#39; no button: move noise sprite
&#39;&#39;         A: move top left clip corner
&#39;&#39;         B: move bottom right clip corner
&#39;&#39;       A+B: reset clip area to max
&#39;&#39;
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  #0, PX, PY
  
OBJ
   lcd: &quot;LameLCD&quot;
   gfx: &quot;LameGFX&quot;                         
  ctrl: &quot;LameControl&quot;

   bmp: &quot;gfx_rpgtown&quot; 

VAR
  long  pos_x, pos_y, cx1, cy1, cx2, cy2                &#39; sprite position and clip area
  word  size, sx, sy, data[4096]                        &#39; noise sprite

PUB null : n

  lcd.Start(gfx.Start)                                  &#39; setup screen and renderer

  size := 8192
    sx := 256
    sy := 128

  frqa := cnt
  repeat 4096
    data[n++] := ?frqa                                  &#39; prepare noise sprite

  pos_x := -(cx2 := lcd#SCREEN_W)/2
  pos_y := -(cy2 := lcd#SCREEN_H)/2                     &#39; initial clip area and position

  repeat
    process{_buttons}                                   &#39; get button status/events

    gfx.Blit(bmp.Addr)                                  &#39; draw background (instead of CLS)
    gfx.SetClipRectangle(cx1, cy1, cx2, cy2)            &#39; limit area for next draw
    gfx.Sprite(@data[-3], pos_x, pos_y, 0)              &#39; draw noise sprite on top

    repeat 1
      lcd.WaitForVerticalSync
    lcd.DrawScreen                                      &#39; update when ready

PRI process : button

  ctrl.Update                                           &#39; current button state

  button := %01 &amp; ctrl.A
  button |= %10 &amp; ctrl.B                                &#39; extract A/B

  ifnot button                                          &#39; no buttons, just move noise sprite
    return advance(@pos_x, 1, -lcd#SCREEN_W, -lcd#SCREEN_H, 0, 0)

  if button == %01 {A}                                  &#39; A: move top left clip corner
    return advance(@cx1, 1, 0, 0, cx2, cy2)

  if button == %10 {B}                                  &#39; B: move bottom right clip corner
    return advance(@cx2, 1, cx1, cy1, lcd#SCREEN_W, lcd#SCREEN_H)

  cx1 := cy1 := 0
  cx2 := lcd#SCREEN_W
  cy2 := lcd#SCREEN_H                                   &#39; A+B: reset clip area to max

PRI advance(addr, delta, x, y, w, h) : changed

  if ctrl.Right
    changed or= long[addr][PX] &lt; w
    long[addr][PX] := w &lt;# (long[addr][PX] + delta)
  elseif ctrl.Left
    changed or= long[addr][PX] &gt; x
    long[addr][PX] := x #&gt; (long[addr][PX] - delta)     &#39; update x of coordinate pair at addr

  if ctrl.Up
    changed or= long[addr][PY] &gt; y
    long[addr][PY] := y #&gt; (long[addr][PY] - delta)
  elseif ctrl.Down
    changed or= long[addr][PY] &lt; h
    long[addr][PY] := h &lt;# (long[addr][PY] + delta)     &#39; update y of coordinate pair at addr</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/Clipping.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
&#39;&#39;
&#39;&#39; simple clipping demo
&#39;&#39;
&#39;&#39;        Author: Marko Lukat
&#39;&#39; Last modified: 2014/06/17
&#39;&#39;       Version: 0.6
&#39;&#39;
&#39;&#39; use joystick for moving around
&#39;&#39;
&#39;&#39; no button: move noise sprite
&#39;&#39;         A: move top left clip corner
&#39;&#39;         B: move bottom right clip corner
&#39;&#39;       A+B: reset clip area to max
&#39;&#39;
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  #0, PX, PY
  
OBJ
   lcd: &quot;LameLCD&quot;
   gfx: &quot;LameGFX&quot;                         
  ctrl: &quot;LameControl&quot;

   bmp: &quot;gfx_rpgtown&quot; 

VAR
  long  pos_x, pos_y, cx1, cy1, cx2, cy2                &#39; sprite position and clip area
  word  size, sx, sy, data[4096]                        &#39; noise sprite

PUB null : n

  lcd.Start(gfx.Start)                                  &#39; setup screen and renderer

  size := 8192
    sx := 256
    sy := 128

  frqa := cnt
  repeat 4096
    data[n++] := ?frqa                                  &#39; prepare noise sprite

  pos_x := -(cx2 := lcd#SCREEN_W)/2
  pos_y := -(cy2 := lcd#SCREEN_H)/2                     &#39; initial clip area and position

  repeat
    process{_buttons}                                   &#39; get button status/events

    gfx.Blit(bmp.Addr)                                  &#39; draw background (instead of CLS)
    gfx.SetClipRectangle(cx1, cy1, cx2, cy2)            &#39; limit area for next draw
    gfx.Sprite(@data[-3], pos_x, pos_y, 0)              &#39; draw noise sprite on top

    repeat 1
      lcd.WaitForVerticalSync
    lcd.DrawScreen                                      &#39; update when ready

PRI process : button

  ctrl.Update                                           &#39; current button state

  button := %01 &amp; ctrl.A
  button |= %10 &amp; ctrl.B                                &#39; extract A/B

  ifnot button                                          &#39; no buttons, just move noise sprite
    return advance(@pos_x, 1, -lcd#SCREEN_W, -lcd#SCREEN_H, 0, 0)

  if button == %01 {A}                                  &#39; A: move top left clip corner
    return advance(@cx1, 1, 0, 0, cx2, cy2)

  if button == %10 {B}                                  &#39; B: move bottom right clip corner
    return advance(@cx2, 1, cx1, cy1, lcd#SCREEN_W, lcd#SCREEN_H)

  cx1 := cy1 := 0
  cx2 := lcd#SCREEN_W
  cy2 := lcd#SCREEN_H                                   &#39; A+B: reset clip area to max

PRI advance(addr, delta, x, y, w, h) : changed

  if ctrl.Right
    changed or= long[addr][PX] &lt; w
    long[addr][PX] := w &lt;# (long[addr][PX] + delta)
  elseif ctrl.Left
    changed or= long[addr][PX] &gt; x
    long[addr][PX] := x #&gt; (long[addr][PX] - delta)     &#39; update x of coordinate pair at addr

  if ctrl.Up
    changed or= long[addr][PY] &gt; y
    long[addr][PY] := y #&gt; (long[addr][PY] - delta)
  elseif ctrl.Down
    changed or= long[addr][PY] &lt; h
    long[addr][PY] := h &lt;# (long[addr][PY] + delta)     &#39; update y of coordinate pair at addr

</code></pre>
