''
'' simple clock demo
''
''        Author: Marko Lukat
'' Last modified: 2014/06/24
''       Version: 0.2
''
'' 20140624: initial version, WIP
''           use cached sprites
''
CON
  _clkmode = XTAL1|PLL16X
  _xinfreq = 5_000_000

OBJ
   lcd: "LameLCD"
   gfx: "LameGFX"
  
VAR
  long  hours, minutes, seconds, change
  long  buffer[512], stack[32]

  word  size, sx, sy, data[64*11]
  
PUB null : t

  init

  repeat
    t := change
    repeat
    while t == change                                   ' wait until there is a change

    display                                             ' show it
  
PRI init : n

  hours   := 15
  minutes := 50

  cognew(clock, @stack{0})                              ' clock handler
  gfx.start(@buffer{0}, lcd.start)                      ' setup screen and renderer

  size := 128
    sx := 16
    sy := 32                                            ' temporary sprite

  repeat n from 0 to 9
    place(@data[64 * n], "0" + n)                       ' digits

  place(@data[64 * 10], ":")                            ' delimiter

PRI place(addr, c) | base, m, v

  base := $8000 + (c >> 1) << 7
  repeat m from base to base +127 step 4
    v := $AAAAAAAA - (long[m] >> (c & 1)) & $55555555
    bytemove(addr, @v, 4)
    addr += 4
  
PRI display

  gfx.ClearScreen                 
  gfx.Sprite(@background, 32, 0, 0)                     ' background sprite
  
  gfx.Sprite(@data[-3], 37, 16, 10)                     ' |
  gfx.Sprite(@data[-3], 77, 16, 10)                     ' delimiters

  digits(hours,    8)                                   
  digits(minutes, 48)                                   
  digits(seconds, 88)                                   

  repeat 1                                                    
    lcd.WaitForVerticalSync       
  gfx.DrawScreen                                        ' update when ready
  
PRI digits(value, at)

  gfx.Sprite(@data[-3], at,      16, value  / 10)
  gfx.Sprite(@data[-3], at + 16, 16, value // 10)

PRI clock : t

  dira[24] := outa[24] := 1                             ' off initially
  t := cnt                                              ' get reference
  
  repeat
    waitcnt(t += clkfreq - 1000000)
    !outa[24]

    ifnot seconds := (seconds + 1) // 60                ' advance clock
      ifnot minutes := (minutes + 1) // 60
        hours := (hours + 1) // 24

    waitcnt(t += 1000000)
    change++                                            ' announce change
    !outa[24]
    
DAT

background

word    1024 ' frameboost
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