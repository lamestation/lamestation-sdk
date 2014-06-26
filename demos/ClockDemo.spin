''
'' simple clock demo
''
''        Author: Marko Lukat
'' Last modified: 2014/06/26
''       Version: 0.5
''
''        A: NORM: enter EDIT mode
''           EDIT: confirm change (*)
''        B: EDIT: cancel
'' joystick: select and modify digits
''
'' 20140624: initial version, WIP
''           use cached sprites
'' 20140626: added edit functionality
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

CON
  E_HRS = %01000 << 16
  E_MIN = %00100 << 16
  E_SEC = %00010 << 16
  E_CHG = %00001
  
OBJ
   lcd: "LameLCD"
   gfx: "LameGFX"
  ctrl: "LameControl"

   dbg: "FullDuplexSerial"
  
VAR
  long  time[2], edit, pressed
  long  buffer[512], stack[32]

  word  size, sx, sy, data[12 << 6]
  
PUB null : t
  
  init

  repeat
    t := time{0}
    repeat
      repeat 1
        lcd.WaitForVerticalSync
      buttons
      repeat                                            ' wait for potential change
      while time[1] < 0                                 ' to be picked up
    while t == time{0}                                  ' wait until there is a change
    
    display(time[edit])                                 ' show it
  
PRI init : n

  cognew(clock, @stack{0})                              ' clock handler
  gfx.start(@buffer{0}, lcd.start)                      ' setup screen and renderer

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
      time[1] := time{0}
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

  if time.byte[3] == (time.byte[3] := $FE & time.byte{0})
    return

  if ctrl.Up
    if edit & E_HRS
      return updown(6, +1, 24)
    if edit & E_MIN
      return updown(5, +1, 60)

  if ctrl.Down
    if edit & E_HRS
      return updown(6, -1, 24)
    if edit & E_MIN
      return updown(5, -1, 60)

PRI updown(idx, delta{+/-1}, limit)

  edit |= E_CHG

  if (time.byte[idx] += delta) < 0
    return time.byte[idx] += limit

  time.byte[idx] //= limit
  
PRI display(current)

  gfx.ClearScreen
  gfx.Sprite(@background, 32, 0, 0)                     ' background sprite
  gfx.Sprite(@data[-3], 56, 16, 10)                     ' delimiter

  ifnot (edit & E_HRS) and (time{0} & 1)
    digits(current.byte[2], 27)

  ifnot (edit & E_MIN) and (time{0} & 1)
    digits(current.byte[1], 67)

  if edit & E_CHG
    gfx.Sprite(@data[-3], 99, 16, 11)

  repeat 1                                                    
    lcd.WaitForVerticalSync       
  gfx.DrawScreen                                        ' update when ready
  
PRI digits(value, at)

  gfx.Sprite(@data[-3], at,      16, value  / 10)
  gfx.Sprite(@data[-3], at + 16, 16, value // 10)

PRI clock : t | adv, rem

  adv := clkfreq / 3
  rem := clkfreq - adv * 2
  
  t := cnt                                              ' get reference
  
  repeat
    waitcnt(t += adv)
    update
    waitcnt(t += adv)
    update
    waitcnt(t += rem)
    update

    if time[1] < 0
      time{0} := time[1] &= $00FFFF00                   ' update

PRI update

  ifnot time.byte{0} := (time.byte{0} + 1) // 180       ' advance clock
    ifnot time.byte[1] := (time.byte[1] + 1) // 60
      time.byte[2] := (time.byte[2] + 1) // 24

DAT

background

word    1024   ' frame size
word    64, 64 ' width, height
' frame 0
word    $AAAA, $AAAA, $AAAA, $FFFF, $BFFF, $AAAA, $AAAA, $AAAA '
word    $AAAA, $AAAA, $FEAA, $ABFF, $FFFA, $AAAF, $AAAA, $AAAA '
word    $AAAA, $AAAA, $BFEA, $AAAA, $AAAA, $ABFF, $AAAA, $AAAA '
word    $AAAA, $AAAA, $AAFE, $AAAA, $AAAA, $BFEA, $AAAA, $AAAA '
word    $AAAA, $EAAA, $AAAF, $AAAA, $AAAA, $FEAA, $AAAB, $AAAA '
word    $AAAA, $FEAA, $AAAA, $AAAA, $AAAA, $EAAA, $AAAF, $AAAA '
word    $AAAA, $BFAA, $AAAA, $AAAA, $AAAA, $AAAA, $AABE, $AAAA '
word    $AAAA, $ABEA, $FAAA, $FFFF, $AAFF, $AAAA, $ABFA, $AAAA '
word    $AAAA, $AAFA, $BAAA, $AAAA, $AAEA, $AAAA, $AFAA, $AAAA '
word    $AAAA, $AABE, $BAAA, $AAAA, $AAEA, $AAAA, $BEAA, $AAAA '
word    $AAAA, $AAAF, $BAAA, $AAAA, $AAEA, $AAAA, $FAAA, $AAAA '
word    $EAAA, $AAAB, $BAAA, $AAAA, $AAEA, $AAAA, $EAAA, $AAAB '
word    $FAAA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $EAAA, $AAAB '
word    $BEAA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $AAAF '
word    $BEAA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $AABE '
word    $AFAA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $AABA '
word    $ABEA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $AAFA '
word    $ABEA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $ABEA '
word    $AAFA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $ABEA '
word    $AAFA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $ABAA '
word    $AABA, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $AFAA '
word    $AABE, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $AEAA '
word    $AABE, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $BEAA '
word    $AAAE, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $BEAA '
word    $AAAF, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $BEAA '
word    $AAAF, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $BAAA '
word    $AAAF, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $FAAA '
word    $AAAB, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $FAAA '
word    $AAAB, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $FAAA '
word    $AAAB, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $FAAA '
word    $AAAB, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $EAAA '
word    $AAAB, $AAAA, $BAAA, $AAAA, $AAEA, $AAAA, $AAAA, $EAAA '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $FFFF '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF '
word    $FFFF, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF '
word    $FFFE, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF '
word    $FFFE, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $BFFF '
word    $FFFE, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF '
word    $FFFA, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF '
word    $FFFA, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AFFF '
word    $FFFA, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $ABFF '
word    $FFEA, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $ABFF '
word    $FFAA, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AAFF '
word    $FFAA, $FFFF, $BFFF, $AAAA, $FFEA, $FFFF, $FFFF, $AAFF '
word    $FEAA, $FFFF, $BFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA '
word    $FEAA, $FFFF, $BFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA '
word    $FAAA, $FFFF, $BFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA '
word    $EAAA, $FFFF, $BFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA '
word    $AAAA, $FFFF, $BFFF, $AAAA, $AAAA, $AAAA, $AAAA, $AAAA '
word    $AAAA, $FFFE, $FFFF, $FFFF, $FFFF, $FFFF, $BFFF, $AAAA '
word    $AAAA, $FFFA, $FFFF, $FFFF, $FFFF, $FFFF, $AFFF, $AAAA '
word    $AAAA, $FFEA, $FFFF, $FFFF, $FFFF, $FFFF, $ABFF, $AAAA '
word    $AAAA, $FFAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAFF, $AAAA '
word    $AAAA, $FEAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAAF, $AAAA '
word    $AAAA, $EAAA, $FFFF, $FFFF, $FFFF, $FFFF, $AAAB, $AAAA '
word    $AAAA, $AAAA, $FFFE, $FFFF, $FFFF, $BFFF, $AAAA, $AAAA '
word    $AAAA, $AAAA, $FFEA, $FFFF, $FFFF, $ABFF, $AAAA, $AAAA '
word    $AAAA, $AAAA, $FEAA, $FFFF, $FFFF, $AABF, $AAAA, $AAAA '
word    $AAAA, $AAAA, $AAAA, $FFFF, $BFFF, $AAAA, $AAAA, $AAAA '

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