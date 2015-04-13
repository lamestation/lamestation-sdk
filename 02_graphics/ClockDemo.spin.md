<p>Stuff</p>
<pre><code>&#39;&#39;
&#39;&#39; (not so) simple clock demo
&#39;&#39;
&#39;&#39;        Author: Marko Lukat
&#39;&#39; Last modified: 2014/06/29
&#39;&#39;       Version: 0.12
&#39;&#39;
&#39;&#39;        A: NORM: enter EDIT mode
&#39;&#39;           EDIT: confirm change (*), back to NORM
&#39;&#39;        B: EDIT: cancel
&#39;&#39; joystick: EDIT: select and modify digits
&#39;&#39;
&#39;&#39; 20140624: initial version, WIP
&#39;&#39;           use cached sprites
&#39;&#39; 20140626: added edit functionality
&#39;&#39; 20140627: defer EDIT copy until first change
&#39;&#39; 20140629: final release
&#39;&#39;
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  E_HRS = %10000000 &lt;&lt; 16
  E_MIN = %01000000 &lt;&lt; 16
  E_CHG = %00000001

OBJ
   frm: &quot;ClockFrames&quot;

   lcd: &quot;LameLCD&quot;
   gfx: &quot;LameGFX&quot;
  ctrl: &quot;LameControl&quot;

VAR
  long  time[3], link[4], edit
  long  stack[32], pressed, block

  word  size, sx, sy, data[12 &lt;&lt; 6]

PUB null : t

  init

  repeat
    t := time[2]
    repeat
      t |= buttons
      repeat                                            &#39; wait for potential change
      while time[1] &lt; 0                                 &#39; to be picked up
    while t == time[2]                                  &#39; wait until there is a change

    display(time[edit])                                 &#39; show it

PRI init : n

  link{0} := @s_00[-3]                                  &#39; ??:??:00
  link[1] := @s_00[-3]                                  &#39; even |
  link[2] := @s_00[-3]                                  &#39;  odd | seconds

  frm.init(@time{0})                                    &#39; frame handler
  
  cognew(clock, @stack{0})                              &#39; clock handler
  lcd.Start(gfx.Start)                                  &#39; setup screen and renderer

  size := 128
    sx := 16
    sy := 32                                            &#39; temporary sprite

  repeat n from 0 to 9
    place(@data[n &lt;&lt; 6], &quot;0&quot; + n)                       &#39; digits

  place(@data[10 &lt;&lt; 6], &quot;:&quot;)                            &#39; delimiter
  place(@data[11 &lt;&lt; 6], &quot;*&quot;)                            &#39; dirty

PRI place(addr, c) | base, m, v

  base := $8000 + (c &gt;&gt; 1) &lt;&lt; 7
  repeat m from base to base +127 step 4
    v := $AAAAAAAA - (long[m] &gt;&gt; (c &amp; 1)) &amp; $55555555
    bytemove(addr, @v, 4)
    addr += 4

PRI buttons : b

  ctrl.Update

  if (b := ctrl.A) and pressed
    return
  pressed := b

  if pressed
    ifnot edit                                          &#39; enter edit mode
      return edit := E_HRS
    if edit &amp; E_CHG                                     &#39; confirm
      time[1] |= NEGX
    return edit := 0

  if ctrl.B                                             &#39; cancel
    return edit := 0

&#39; edit mode: deal with joystick navigation

  if ctrl.Left                                          &#39; edit hours
    return edit := E_HRS | (edit &amp; !E_MIN)

  if ctrl.Right                                         &#39; edit minutes
    return edit := E_MIN | (edit &amp; !E_HRS)

  if block == (block := time.byte{0})
    return

  if ctrl.Up
    if edit &amp; E_HRS
      updown(6, +1, 24)
    if edit &amp; E_MIN
      updown(5, +1, 60)
    return edit

  if ctrl.Down
    if edit &amp; E_HRS
      updown(6, -1, 24)
    if edit &amp; E_MIN
      updown(5, -1, 60)
    return edit

PRI updown(idx, delta{+/-1}, limit)

  ifnot edit &amp; E_CHG
    edit |= E_CHG
    time[1] := time[2]                                  &#39; deferred until first change

  if (time.byte[idx] += delta) &lt; 0
    return time.byte[idx] += limit

  time.byte[idx] //= limit

PRI display(current) : idle

  gfx.ClearScreen(0)
  gfx.Sprite(link[index], 32, 0, 0)                     &#39; background sprite
  gfx.Sprite(@data[-3], 56, 16, 10)                     &#39; delimiter

  idle := not (ctrl.Up or ctrl.Down)

  ifnot (edit &amp; E_HRS) and (time{0} &amp; 1) and idle
    digits(current.byte[2], 27)

  ifnot (edit &amp; E_MIN) and (time{0} &amp; 1) and idle
    digits(current.byte[1], 67)

  if edit &amp; E_CHG
    gfx.Sprite(@data[-3], 99, 16, 11)

  repeat 1
    lcd.WaitForVerticalSync
  lcd.DrawScreen                                        &#39; update when ready

PRI index : n
                                                        &#39;    0: 0
  if n := time.byte[3]                                  &#39; even: 1
    return n &amp; 1 +1                                     &#39;  odd: 2
  
PRI digits(value, at)

  gfx.Sprite(@data[-3], at,      16, value  / 10)
  gfx.Sprite(@data[-3], at + 16, 16, value // 10)

PRI clock : t | adv, rem

  adv := clkfreq / 3
  rem := clkfreq - adv * 2

  t := cnt                                              &#39; get reference

  repeat
    repeat 2
      waitcnt(t += adv)
      update
    waitcnt(t += rem)
    update

PRI update

  ifnot time.byte{0} := (time.byte{0} + 1) // 180       &#39; advance clock
    ifnot time.byte[1] := (time.byte[1] + 1) // 60
      time.byte[2] := (time.byte[2] + 1) // 24
  time.byte[3] := time.byte{0} / 3

  if time[1] &lt; 0
    time{0} := time[1] &amp;= $00FFFF00                     &#39; update

  time[2] := time{0}                                    &#39; final value

DAT                                                     &#39; frame 0 (uncompressed)

        word    1024    &#39; frame size
        word    64, 64  &#39; width, height

s_00    word    $AAAA, $AAAA, $AAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FEAA, $FFFF, $FFFF, $AABF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FFFA, $AffF, $FffA, $AFFF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $fFFF, $AAAA, $AAAA, $FFFf, $AAAA, $AAAA
        word    $AAAA, $EAAA, $ABFF, $AAAA, $AAAA, $FFEA, $AAAB, $AAAA
        word    $AAAA, $FEAA, $AABF, $AAAA, $AAAA, $FEAA, $AABF, $AAAA
        word    $AAAA, $FFAA, $AAAB, $AAAA, $AAAA, $EAAA, $AAFF, $AAAA
        word    $AAAA, $BFEA, $fAAA, $ffff, $ABff, $AAAA, $ABFE, $AAAA
        word    $AAAA, $AFFE, $FAAA, $FFFF, $ABFF, $AAAA, $BFFA, $AAAA
        word    $AAAA, $ABFF, $FAAA, $ffff, $ABFf, $AAAA, $FFEA, $AAAA
        word    $AAAA, $AAFF, $FAAA, $AAAA, $ABEA, $AAAA, $FEAA, $AAAA
        word    $EAAA, $AABF, $FAAA, $AAAA, $ABEA, $AAAA, $FAAA, $AAAB
        word    $FAAA, $AAAF, $FAAA, $AAAA, $ABEA, $AAAA, $FAAA, $AAAF
        word    $FEAA, $AAAB, $FAAA, $AAAA, $ABEA, $AAAA, $EAAA, $AABF
        word    $FEAA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AABF
        word    $BFAA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AAFE
        word    $BFEA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $ABFE
        word    $AFEA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $ABFA
        word    $AFFA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AFFA
        word    $ABFA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AFEA
        word    $ABFA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AFEA
        word    $AAFE, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $BFAA
        word    $AAFE, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $BFAA
        word    $AAFE, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $BFAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FAAA
        word    $AAAF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FAAA
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFE, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF
        word    $FFFE, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF
        word    $FFFE, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF
        word    $FFFA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF
        word    $FFFA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF
        word    $FFFA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF
        word    $FFEA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $ABFF
        word    $FFEA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $ABFF
        word    $FFAA, $FFFF, $FFFF, $AAAA, $ffEA, $ffff, $ffff, $AAFf
        word    $FEAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $FEAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $FAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $EAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $AAAA, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $AAAB
        word    $AAAA, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $AAAA
        word    $AAAA, $FFFE, $FFFF, $FFFF, $FFFF, $FFFF, $BFFF, $AAAA
        word    $AAAA, $FFEA, $FFFF, $FFFF, $FFFF, $FFFF, $ABFF, $AAAA
        word    $AAAA, $FFAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAFF, $AAAA
        word    $AAAA, $FEAA, $FFFF, $FFFF, $FFFF, $FFFF, $AABF, $AAAA
        word    $AAAA, $EAAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAAB, $AAAA
        word    $AAAA, $AAAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FFFA, $FFFF, $FFFF, $AFFF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FEAA, $FFFF, $FFFF, $AABF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $AAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 02_graphics/ClockDemo.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
&#39;&#39;
&#39;&#39; (not so) simple clock demo
&#39;&#39;
&#39;&#39;        Author: Marko Lukat
&#39;&#39; Last modified: 2014/06/29
&#39;&#39;       Version: 0.12
&#39;&#39;
&#39;&#39;        A: NORM: enter EDIT mode
&#39;&#39;           EDIT: confirm change (*), back to NORM
&#39;&#39;        B: EDIT: cancel
&#39;&#39; joystick: EDIT: select and modify digits
&#39;&#39;
&#39;&#39; 20140624: initial version, WIP
&#39;&#39;           use cached sprites
&#39;&#39; 20140626: added edit functionality
&#39;&#39; 20140627: defer EDIT copy until first change
&#39;&#39; 20140629: final release
&#39;&#39;
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  E_HRS = %10000000 &lt;&lt; 16
  E_MIN = %01000000 &lt;&lt; 16
  E_CHG = %00000001

OBJ
   frm: &quot;ClockFrames&quot;

   lcd: &quot;LameLCD&quot;
   gfx: &quot;LameGFX&quot;
  ctrl: &quot;LameControl&quot;

VAR
  long  time[3], link[4], edit
  long  stack[32], pressed, block

  word  size, sx, sy, data[12 &lt;&lt; 6]

PUB null : t

  init

  repeat
    t := time[2]
    repeat
      t |= buttons
      repeat                                            &#39; wait for potential change
      while time[1] &lt; 0                                 &#39; to be picked up
    while t == time[2]                                  &#39; wait until there is a change

    display(time[edit])                                 &#39; show it

PRI init : n

  link{0} := @s_00[-3]                                  &#39; ??:??:00
  link[1] := @s_00[-3]                                  &#39; even |
  link[2] := @s_00[-3]                                  &#39;  odd | seconds

  frm.init(@time{0})                                    &#39; frame handler
  
  cognew(clock, @stack{0})                              &#39; clock handler
  lcd.Start(gfx.Start)                                  &#39; setup screen and renderer

  size := 128
    sx := 16
    sy := 32                                            &#39; temporary sprite

  repeat n from 0 to 9
    place(@data[n &lt;&lt; 6], &quot;0&quot; + n)                       &#39; digits

  place(@data[10 &lt;&lt; 6], &quot;:&quot;)                            &#39; delimiter
  place(@data[11 &lt;&lt; 6], &quot;*&quot;)                            &#39; dirty

PRI place(addr, c) | base, m, v

  base := $8000 + (c &gt;&gt; 1) &lt;&lt; 7
  repeat m from base to base +127 step 4
    v := $AAAAAAAA - (long[m] &gt;&gt; (c &amp; 1)) &amp; $55555555
    bytemove(addr, @v, 4)
    addr += 4

PRI buttons : b

  ctrl.Update

  if (b := ctrl.A) and pressed
    return
  pressed := b

  if pressed
    ifnot edit                                          &#39; enter edit mode
      return edit := E_HRS
    if edit &amp; E_CHG                                     &#39; confirm
      time[1] |= NEGX
    return edit := 0

  if ctrl.B                                             &#39; cancel
    return edit := 0

&#39; edit mode: deal with joystick navigation

  if ctrl.Left                                          &#39; edit hours
    return edit := E_HRS | (edit &amp; !E_MIN)

  if ctrl.Right                                         &#39; edit minutes
    return edit := E_MIN | (edit &amp; !E_HRS)

  if block == (block := time.byte{0})
    return

  if ctrl.Up
    if edit &amp; E_HRS
      updown(6, +1, 24)
    if edit &amp; E_MIN
      updown(5, +1, 60)
    return edit

  if ctrl.Down
    if edit &amp; E_HRS
      updown(6, -1, 24)
    if edit &amp; E_MIN
      updown(5, -1, 60)
    return edit

PRI updown(idx, delta{+/-1}, limit)

  ifnot edit &amp; E_CHG
    edit |= E_CHG
    time[1] := time[2]                                  &#39; deferred until first change

  if (time.byte[idx] += delta) &lt; 0
    return time.byte[idx] += limit

  time.byte[idx] //= limit

PRI display(current) : idle

  gfx.ClearScreen(0)
  gfx.Sprite(link[index], 32, 0, 0)                     &#39; background sprite
  gfx.Sprite(@data[-3], 56, 16, 10)                     &#39; delimiter

  idle := not (ctrl.Up or ctrl.Down)

  ifnot (edit &amp; E_HRS) and (time{0} &amp; 1) and idle
    digits(current.byte[2], 27)

  ifnot (edit &amp; E_MIN) and (time{0} &amp; 1) and idle
    digits(current.byte[1], 67)

  if edit &amp; E_CHG
    gfx.Sprite(@data[-3], 99, 16, 11)

  repeat 1
    lcd.WaitForVerticalSync
  lcd.DrawScreen                                        &#39; update when ready

PRI index : n
                                                        &#39;    0: 0
  if n := time.byte[3]                                  &#39; even: 1
    return n &amp; 1 +1                                     &#39;  odd: 2
  
PRI digits(value, at)

  gfx.Sprite(@data[-3], at,      16, value  / 10)
  gfx.Sprite(@data[-3], at + 16, 16, value // 10)

PRI clock : t | adv, rem

  adv := clkfreq / 3
  rem := clkfreq - adv * 2

  t := cnt                                              &#39; get reference

  repeat
    repeat 2
      waitcnt(t += adv)
      update
    waitcnt(t += rem)
    update

PRI update

  ifnot time.byte{0} := (time.byte{0} + 1) // 180       &#39; advance clock
    ifnot time.byte[1] := (time.byte[1] + 1) // 60
      time.byte[2] := (time.byte[2] + 1) // 24
  time.byte[3] := time.byte{0} / 3

  if time[1] &lt; 0
    time{0} := time[1] &amp;= $00FFFF00                     &#39; update

  time[2] := time{0}                                    &#39; final value

DAT                                                     &#39; frame 0 (uncompressed)

        word    1024    &#39; frame size
        word    64, 64  &#39; width, height

s_00    word    $AAAA, $AAAA, $AAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FEAA, $FFFF, $FFFF, $AABF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FFFA, $AffF, $FffA, $AFFF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $fFFF, $AAAA, $AAAA, $FFFf, $AAAA, $AAAA
        word    $AAAA, $EAAA, $ABFF, $AAAA, $AAAA, $FFEA, $AAAB, $AAAA
        word    $AAAA, $FEAA, $AABF, $AAAA, $AAAA, $FEAA, $AABF, $AAAA
        word    $AAAA, $FFAA, $AAAB, $AAAA, $AAAA, $EAAA, $AAFF, $AAAA
        word    $AAAA, $BFEA, $fAAA, $ffff, $ABff, $AAAA, $ABFE, $AAAA
        word    $AAAA, $AFFE, $FAAA, $FFFF, $ABFF, $AAAA, $BFFA, $AAAA
        word    $AAAA, $ABFF, $FAAA, $ffff, $ABFf, $AAAA, $FFEA, $AAAA
        word    $AAAA, $AAFF, $FAAA, $AAAA, $ABEA, $AAAA, $FEAA, $AAAA
        word    $EAAA, $AABF, $FAAA, $AAAA, $ABEA, $AAAA, $FAAA, $AAAB
        word    $FAAA, $AAAF, $FAAA, $AAAA, $ABEA, $AAAA, $FAAA, $AAAF
        word    $FEAA, $AAAB, $FAAA, $AAAA, $ABEA, $AAAA, $EAAA, $AABF
        word    $FEAA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AABF
        word    $BFAA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AAFE
        word    $BFEA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $ABFE
        word    $AFEA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $ABFA
        word    $AFFA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AFFA
        word    $ABFA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AFEA
        word    $ABFA, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $AFEA
        word    $AAFE, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $BFAA
        word    $AAFE, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $BFAA
        word    $AAFE, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $BFAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FEAA
        word    $AABF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FAAA
        word    $AAAF, $AAAA, $FAAA, $AAAA, $ABEA, $AAAA, $AAAA, $FAAA
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFF, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF
        word    $FFFE, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF
        word    $FFFE, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF
        word    $FFFE, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF
        word    $FFFA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF
        word    $FFFA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF
        word    $FFFA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF
        word    $FFEA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $ABFF
        word    $FFEA, $FFFF, $FFFF, $AAAA, $FFEA, $FFFF, $FFFF, $ABFF
        word    $FFAA, $FFFF, $FFFF, $AAAA, $ffEA, $ffff, $ffff, $AAFf
        word    $FEAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $FEAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $FAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $EAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA
        word    $AAAA, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $AAAB
        word    $AAAA, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $AAAA
        word    $AAAA, $FFFE, $FFFF, $FFFF, $FFFF, $FFFF, $BFFF, $AAAA
        word    $AAAA, $FFEA, $FFFF, $FFFF, $FFFF, $FFFF, $ABFF, $AAAA
        word    $AAAA, $FFAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAFF, $AAAA
        word    $AAAA, $FEAA, $FFFF, $FFFF, $FFFF, $FFFF, $AABF, $AAAA
        word    $AAAA, $EAAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAAB, $AAAA
        word    $AAAA, $AAAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FFFA, $FFFF, $FFFF, $AFFF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $FEAA, $FFFF, $FFFF, $AABF, $AAAA, $AAAA
        word    $AAAA, $AAAA, $AAAA, $FFFF, $FFFF, $AAAA, $AAAA, $AAAA

</code></pre>
