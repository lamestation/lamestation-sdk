''
'' (not so) simple clock demo
''
''        Author: Marko Lukat
'' Last modified: 2014/06/29
''       Version: 0.12
''
''        A: NORM: enter EDIT mode
''           EDIT: confirm change (*), back to NORM
''        B: EDIT: cancel
'' joystick: EDIT: select and modify digits
''
'' 20140624: initial version, WIP
''           use cached sprites
'' 20140626: added edit functionality
'' 20140627: defer EDIT copy until first change
'' 20140629: final release
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  E_HRS = %10000000 << 16
  E_MIN = %01000000 << 16
  E_CHG = %00000001

OBJ
   frm: "ClockFrames"

   lcd: "LameLCD"
   gfx: "LameGFX"
  ctrl: "LameControl"

VAR
  long  time[3], link[4], edit
  long  stack[32], pressed, block

  word  size, sx, sy, data[12 << 6]

PUB null : t

  init

  repeat
    t := time[2]
    repeat
      t |= buttons
      repeat                                            ' wait for potential change
      while time[1] < 0                                 ' to be picked up
    while t == time[2]                                  ' wait until there is a change

    display(time[edit])                                 ' show it

PRI init : n

  link{0} := @s_00[-3]                                  ' ??:??:00
  link[1] := @s_00[-3]                                  ' even |
  link[2] := @s_00[-3]                                  '  odd | seconds

  frm.init(@time{0})                                    ' frame handler
  
  cognew(clock, @stack{0})                              ' clock handler
  lcd.Start(gfx.Start)                                  ' setup screen and renderer

  size := 128
    sx := 16
    sy := 32                                            ' temporary sprite

  repeat n from 0 to 9
    place(@data[n << 6], "0" + n)                       ' digits

  place(@data[10 << 6], ":")                            ' delimiter
  place(@data[11 << 6], "*")                            ' dirty

PRI place(addr, c) | base, m, v

  base := $8000 + (c >> 1) << 7
  repeat m from base to base +127 step 4
    v := $AAAAAAAA - (long[m] >> (c & 1)) & $55555555
    bytemove(addr, @v, 4)
    addr += 4

PRI buttons : b

  ctrl.Update

  if (b := ctrl.A) and pressed
    return
  pressed := b

  if pressed
    ifnot edit                                          ' enter edit mode
      return edit := E_HRS
    if edit & E_CHG                                     ' confirm
      time[1] |= NEGX
    return edit := 0

  if ctrl.B                                             ' cancel
    return edit := 0

' edit mode: deal with joystick navigation

  if ctrl.Left                                          ' edit hours
    return edit := E_HRS | (edit & !E_MIN)

  if ctrl.Right                                         ' edit minutes
    return edit := E_MIN | (edit & !E_HRS)

  if block == (block := time.byte{0})
    return

  if ctrl.Up
    if edit & E_HRS
      updown(6, +1, 24)
    if edit & E_MIN
      updown(5, +1, 60)
    return edit

  if ctrl.Down
    if edit & E_HRS
      updown(6, -1, 24)
    if edit & E_MIN
      updown(5, -1, 60)
    return edit

PRI updown(idx, delta{+/-1}, limit)

  ifnot edit & E_CHG
    edit |= E_CHG
    time[1] := time[2]                                  ' deferred until first change

  if (time.byte[idx] += delta) < 0
    return time.byte[idx] += limit

  time.byte[idx] //= limit

PRI display(current) : idle

  gfx.ClearScreen
  gfx.Sprite(link[index], 32, 0, 0)                     ' background sprite
  gfx.Sprite(@data[-3], 56, 16, 10)                     ' delimiter

  idle := not (ctrl.Up or ctrl.Down)

  ifnot (edit & E_HRS) and (time{0} & 1) and idle
    digits(current.byte[2], 27)

  ifnot (edit & E_MIN) and (time{0} & 1) and idle
    digits(current.byte[1], 67)

  if edit & E_CHG
    gfx.Sprite(@data[-3], 99, 16, 11)

  lcd.DrawScreen                                        ' update when ready

PRI index : n
                                                        '    0: 0
  if n := time.byte[3]                                  ' even: 1
    return n & 1 +1                                     '  odd: 2
  
PRI digits(value, at)

  gfx.Sprite(@data[-3], at,      16, value  / 10)
  gfx.Sprite(@data[-3], at + 16, 16, value // 10)

PRI clock : t | adv, rem

  adv := clkfreq / 3
  rem := clkfreq - adv * 2

  t := cnt                                              ' get reference

  repeat
    repeat 2
      waitcnt(t += adv)
      update
    waitcnt(t += rem)
    update

PRI update

  ifnot time.byte{0} := (time.byte{0} + 1) // 180       ' advance clock
    ifnot time.byte[1] := (time.byte[1] + 1) // 60
      time.byte[2] := (time.byte[2] + 1) // 24
  time.byte[3] := time.byte{0} / 3

  if time[1] < 0
    time{0} := time[1] &= $00FFFF00                     ' update

  time[2] := time{0}                                    ' final value

DAT                                                     ' frame 0 (uncompressed)

        word    1024    ' frame size
        word    64, 64  ' width, height

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

DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT