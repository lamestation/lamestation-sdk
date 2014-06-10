''
'' KS0107/08 Monochrome LCD Framebuffer Driver
'' -------------------------------------------------
'' Version: 1.0
'' Copyright (c) 2013-2014 LameStation LLC
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir, Marko Lukat
'' -------------------------------------------------
''
CON
'' These indicate which pins connect to what. If developing your own prototype,
'' you can change the value of LCDstart to change the location of the LCD
'' pinout.
''
  #0, LCDstart[11], LCDend

'' The pins on a KS0108 LCD are as follows.
''
'' * **D/I** - Indicates whether next command is data or instruction. 
'' * **R/W** - Controls whether reading from or writing to the LCD. On the LameStation, this pin is wired to ground.
'' * **EN** - This pin controls whether data is being sent. It remains off while data is prepared then toggled on to deliver.
'' * **DB0-7** - These 8 bits are how data is delivered to the LCD, whether it is pixel data, address values, or otherwise.
'' * **CSA, CSB** - Each KS0108 controller only actually handles 64x64 on-screen pixels, so a 128x64 LCD
''           requires two of these chips in order to function. To handle this, the control signals are demultiplexed
''           to one or both of the two chips, depending on which one is selected. In most cases, the Propeller is only
''           talking to one of these chips at a time, because most time is spending sending screen data. The rare case
''
  #LCDstart, DI, EN, DB[8], CSA, CSB

'' I have this constant so that the frame rate can be limited;
'' however, in practice, I set it to some high value like 300
'' so that the screen will refresh as fast as possible.
''
'' ### Ideal settings
''
'' * LCD - (FRAMERATE,BYTEPERIOD)
''
'' * KS0108, white on blue STN LCD - (133, 190)
''
  FRAMERATE = 134
  BYTEPERIOD = 190
    
  ' screensize constants
  SCREEN_W = 128
  SCREEN_H = 64
  BITSPERPIXEL = 2

  SCREEN_H_BYTES = SCREEN_H / 8
  SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
  TOTALBUFFER_BYTES = SCREENSIZE_BYTES

VAR
  long  insn
  long  sync
        
PUB null
'' This is not a top level object.

PUB init(primary)
'' Initializes the viewer object and any underlying graphics driver.
''
'' parameters
''  primary: optional screen buffer (to be attached at index 0) or NULL (none)
''
'' result
''   Aborts when any part of the initialization fails, otherwise an address
''   of an internal buffer which can be used as a screen buffer (DAT reuse)
''   or NULL of no such buffer is available.

  ifnot cognew(@screen, @insn) +1
    abort

  if primary
    setn(primary, 0)

  return @screen{0}

PUB setn(address, sidx)
'' Add or remove a screen buffer from display.
''
'' parameters
''  address: ... of 128x64 px buffer or NULL (remove)
''     sidx: screen index (must be 0)

  ifnot sidx
    sidx.word[1] := address
    insn := sidx|%100

    repeat
    while insn

PUB waitVBL
'' Block execution until vertical sync pulse starts.

  repeat
  until sync
  repeat
  while sync                                            ' 1/0 transition
  
DAT                     org     0                       ' single screen LCD driver

screen                  jmpret  $, #setup               ' once

main                    movs    read, #line             ' reset
                        call    #translateLCD           ' flip data for this page

                        mov     eins, rcnt
                        or      eins, CMD_SetPage       ' chip select embedded
                        call    #sendLCDcommand         ' set page
                        
fill                    mov     ccnt, #64

                        mov     eins, scrn wz           ' |
read            if_nz   mov     eins, line              ' read data or black (detached)
                        add     $-1, #1                 ' |
                        
                        mov     zwei, eins
                        shr     zwei, #8

                        test    idnt, #1 wc             ' even or odd frame?
                if_nc   andn    eins, zwei              ' apply gray value
                        and     eins, dmsk              ' limit to valid pins
              
                        or      eins, CMD_WriteByte     ' chip select embedded
                        call    #sendLCDcommand         ' send data

                        djnz    ccnt, #read-1           ' for all columns

                        test    CMD_WriteByte, LCD_CE_L wz
                        xor     CMD_WriteByte, LCD_CE_B ' swap displays (L/R)
                if_nz   jmp     #fill                   ' |

                        cmp     rcnt, rmsk wz           ' check recently drawn page
                if_ne   jmp     #main                   ' for all pages

                        waitcnt LCD_time, LCD_frameperiod
{
                        add     ina, cnt
                        wrlong  ina, $+1
                        long    $7FFC
                        neg     ina, cnt
}
                        rdlong  eins, par wz            ' |
                if_nz   shr     eins, #16               ' |
                if_nz   mov     scrn, eins              ' update display buffer
                if_nz   wrlong  zero, par               ' acknowledge command

                        xor     idnt, #1                ' advance frame counter
                        wrlong  idnt, blnk              ' and announce it
                
                        jmp     #main                   ' next frame

' min enable pulse width: 450ns
'    min data setup time: 200ns
'     min data hold time:  10ns

sendLCDcommand          mov     outa, eins

                        mov     cnt, cnt
                        add     cnt, #13{18} +22
                        or      outa, LCD_Enable
                        waitcnt cnt, #BYTEPERIOD
                        
                        andn    outa, LCD_Enable

                        waitcnt cnt, #BYTEPERIOD
                        waitcnt cnt, #0

sendLCDcommand_ret      ret

' Given screen dimensions of 128x64 pixel and 2 bits/pixel we're looking at
' a linear buffer of 64*128*2 bits == 64*32 bytes == 2K. The LCD buffers needs
' the bytes effectively rotated by 90 deg.
'                                         
'    +---------------+---------------+    An 8x8 pixel block holds 16bytes or     
' R0 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    8 words. The LCD expects data to be     
'    +---------------+---------------+    formatted in a way that all 0 bits      
' R1 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    are delivered first starting with R0.0  
'    +---------------+---------------+    in bit position 0 and R7.0 in position  
' R2 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    7. This new byte is followed by column  
'    +---------------+---------------+    1 and so on until column F.             
' R3 |0 1 2 3 4 5 6 7|8 9 A B C D E F|                                            
'    +---------------+---------------+    To achieve this we scan all 16x8 blocks 
' R4 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    of the structure shown to the left. This
'    +---------------+---------------+    gives us outer and inner loop. Address  
' R5 |0 1 2 3 4 5 6 7|8 9 A B C D E F|    offsets increment by 2 (word) for each
'    +---------------+---------------+    column and 8*32 == 256 for each row.    
' R6 |0 1 2 3 4 5 6 7|8 9 A B C D E F|
'    +---------------+---------------+
' R7 |0 1 2 3 4 5 6 7|8 9 A B C D E F|
'    +---------------+---------------+

translateLCD            add     rcnt, radv              ' 8 blocks of 8 rows
                        and     rcnt, rmsk wz

                if_z    mov     addr, scrn              ' |
                        movd    :set, #line             ' rewind
                
                        mov     ccnt, #16               ' 16 blocks of 8 columns

' read 8 words of an 8x8 pixel block (words are separated by a whole line, 32 bytes)
                        
:columns                rdword  xsrc+0, addr            ' load 8x8 pixel block
                        add     addr, #32
                        rdword  xsrc+1, addr
                        add     addr, #32
                        rdword  xsrc+2, addr
                        add     addr, #32
                        rdword  xsrc+3, addr
                        add     addr, #32
                        rdword  xsrc+4, addr
                        add     addr, #32
                        rdword  xsrc+5, addr
                        add     addr, #32
                        rdword  xsrc+6, addr
                        add     addr, #32
                        rdword  xsrc+7, addr

                        mov     bcnt, #8                ' scan 8 columns

:loop                   shr     xsrc+0, #1 wc           ' extract even column(s)
                        rcr     trgt, #1
                        shr     xsrc+1, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+2, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+3, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+4, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+5, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+6, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+7, #1 wc
                        rcr     trgt, #1

                        shr     xsrc+0, #1 wc           ' extract odd column(s)
                        rcr     trgt, #1
                        shr     xsrc+1, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+2, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+3, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+4, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+5, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+6, #1 wc
                        rcr     trgt, #1
                        shr     xsrc+7, #1 wc
                        rcr     trgt, #17 -DB

:set                    mov     line, trgt              ' store one pixel column
                        add     :set, dst1              ' advance destination

                        djnz    bcnt, #:loop

                        sub     addr, #32*7 -2          ' rewind loader, next 8 columns
                        djnz    ccnt, #:columns

                        add     addr, #256 -32          ' next 8 rows
translateLCD_ret        ret                             ' return

' initialised data and/or presets

LCD_time                long    80_000_000/73
LCD_frameperiod         long    80_000_000/73

CMD_DisplayOff          long    %11 << CSA | $3E << DB
CMD_DisplayOn           long    %11 << CSA | $3F << DB
CMD_SetAddress          long    %11 << CSA | $40 << DB  ' +0..63
CMD_SetPage             long    %11 << CSA | $B8 << DB  ' +0..7

CMD_WriteByte           long    %01 << CSA | $00 << DB | 1 << DI

LCD_CE_L                long    %01 << CSA
LCD_CE_B                long    %11 << CSA

LCD_Enable              long    1 << EN                                 

mask                    long    |< (LCDend +1) - |< LCDstart

scrn                    long    0                       ' active screen buffer
idnt                    long    0                       ' frame ID (even/odd)
dst1                    long    |< 9                    ' dst +/-= 1

dmsk                    long    $FF << DB

rmsk                    long    $07 << DB
radv                    long    $01 << DB
rcnt                    long    $07 << DB               ' row counter 0..7

blnk                    long    4                       ' frame identifier

' Stuff below is re-purposed for temporary storage.

setup                   mov     dira, mask              ' drive outputs
                        add     blnk, par               ' @long[par][1]
                        add     LCD_time, cnt           ' finalize 1st frame target

                        mov     eins, CMD_DisplayOn     ' chip select embedded
                        call    #sendLCDcommand         ' turn on LCD

                        mov     eins, CMD_SetAddress    ' chip select embedded
                        call    #sendLCDcommand         ' reset address

                        jmp     %%0                     ' return

EOD{ata}                fit

' uninitialised data and/or temporaries

                        org     setup

addr                    res     1
trgt                    res     1

reuse                   res     alias

xsrc                    res     8
bcnt                    res     1
ccnt                    res     1

line                    res     128

tail                    fit

' aliases (different functions share VAR space)

                        org     reuse

eins                    res     1
zwei                    res     1

                        fit     tail
                        
{screen padding}        long    -1[0 #> (512 - (@EOD - @screen) / 4)]

CON
  zero  = $1F0                                          ' par (dst only)

  alias = 0
  
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