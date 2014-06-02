''
'' LameLCD to VGA
''
''        Author: Marko Lukat
'' Last modified: 2014/05/31
''       Version: 0.2
''
CON
  lcd_x = 128
  lcd_y = 64

  res_x = driver#res_x
  res_y = driver#res_y

  quads = res_x / 4

OBJ
  driver: "waitvid.256x192.driver.2048"
  
VAR
  long  palette[256]
  long  frame, scan[quads]
  word  screen[1024]

PUB null
'' This is not a top level object.

PUB Start : n | b
    
  repeat 256
    repeat b from 2 to 8 step 2
      palette.byte[n++] := lookupz((n >> b) & %11: $00, $AA, $C0, $55)

  wordfill(@screen{0}, %%2222_2222, 1024)

  n := driver.init(-1, @scan{0})

  ifnot cognew(@entry, @scan{0}) +1
    cogstop(--n)
    abort
    
  return @screen      

DAT             org     0

entry           add     blnk, par
                add     slcd, par
                add     plte, par

loop            rdlong  lcnt, blnk
                cmp     lcnt, vres wz
        if_ne   jmp     #$-2                    ' wait for vblank

                mov     trgt, #(res_y-lcd_y)/2
                mov     base, slcd

main            rdlong  lcnt, blnk
                cmp     lcnt, trgt wz
        if_ne   jmp     #$-2                    ' wait for target

                mov     eins, #lcd_x/4
                mov     scrn, par
                add     scrn, #(res_x-lcd_x)/2

fill            rdbyte  zwei, base              '  +0 =
                shl     zwei, #2                '  +8
                add     zwei, plte              '  -4
                rdlong  zwei, zwei              '  +0 =
                add     base, #1                '  +8
                
                wrlong  zwei, scrn              '  +0 =
                add     scrn, #4                '  +8
                djnz    eins, #fill             '  -4

                add     trgt, #1
                cmp     trgt, #(res_y-lcd_y)/2 + lcd_y wz
        if_ne   jmp     #main

                rdlong  lcnt, blnk
                cmp     lcnt, trgt wz
        if_ne   jmp     #$-2                    ' wait for target

                mov     eins, #lcd_x/4
                mov     scrn, par
                add     scrn, #(res_x-lcd_x)/2

                wrlong  zero, scrn
                add     scrn, #4
                djnz    eins, #$-2

                jmp     #loop

' initialised data and/or presets

vres            long    res_y

plte            long    -4 -256*4               ' @palette[0]
blnk            long    -4                      ' @frame
slcd            long    quads*4                 ' @screen[0]

' uninitialised data and/or temporaries

trgt            res     1
lcnt            res     1

base            res     1
scrn            res     1

eins            res     1
zwei            res     1

tail            fit
                
CON
  zero = $1F0                                   ' par (dst only)

DAT