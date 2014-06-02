''
'' LameGFX Fast Drawing Library
'' -------------------------------------------------
'' Version: 1.0
'' Copyright (c) 2013-2014 LameStation LLC
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir, Marko Lukat
'' -------------------------------------------------
'' This is a graphics library designed for use on the
'' LameStation portable gaming handheld. It is designed
'' to be straightforward to use and easy to set up.
''
'' Creating your first program is simple! First, include
'' the graphics object in an object block.
''
'' * **instruction** - send data to assembly cog
''
CON

    ' screensize constants
    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2
    
    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE = SCREEN_W*SCREEN_H

    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    SCREENSIZE_BYTES_END = SCREENSIZE_BYTES-1

    ' text printing
    NL = 10
    LF = 13

'' This table 
'' 
'' +------+-------+------+-------------+
'' | Flip | Color | Mask | Color       |
'' +------+-------+------+-------------+
'' |   0  |   0   |   0  | Black       |
'' +------+-------+------+-------------+
'' |   0  |   1   |   0  | White       |
'' +------+-------+------+-------------+
'' |   1  |   0   |   1  | Transparent |
'' +------+-------+------+-------------+
'' |   1  |   1   |   0  | Black       |
'' +------+-------+------+-------------+
''
'' This operation is equivalent to `Mask = Flip & !Color`.
''
'' The color constant definitions here correspond to this.
''    
    BLACK = 0
    WHITE = 1
    TRANSPARENT = 2
    GRAY = 3
    
    
    ' draw map function    
    COLLIDEBIT = $80
    TILEBYTE = COLLIDEBIT-1
    

VAR
'' These longs make up the interface between Spin and
'' assembly.
'' They must apppear in this order.
'' ---------------------------------------------------
    long    instruction
    long    outputlong
    long    drawsurface
'' ---------------------------------------------------

    word    copysurface

    word    font
    byte    startingchar
    byte    tilesize_x
    byte    tilesize_y

VAR
    long    c_blitscreen, c_sprite, c_setcliprect, c_translate
    long    c_parameters[4]

PUB null
'' This is not a top level object.

PUB Start(buffer, screen)

    drawsurface := buffer
    copysurface := screen
    cognew(@graphicsdriver, @instruction)
'                                                  function has(1) no(0) argument(s) ----+
'                                                             number of arguments -1 --+ |
'                                                                                      | |
    c_blitscreen  := @c_parameters << 16 | (@blitscreen   - @graphicsdriver) >> 2 | %000_1 << 12
    c_sprite      := @c_parameters << 16 | (@drawsprite   - @graphicsdriver) >> 2 | %011_1 << 12
    c_setcliprect := @c_parameters << 16 | (@setcliprect  - @graphicsdriver) >> 2 | %011_1 << 12
    c_translate   := @c_parameters << 16 | (@translateLCD - @graphicsdriver) >> 2 | %001_1 << 12
'   c_translate   := @c_parameters << 16 | (@translateVGA - @graphicsdriver) >> 2 | %001_1 << 12

PUB WaitToDraw

    repeat
    while instruction

PUB ClearScreen
'' This command clears the screen to black. Recommended if your game
'' display is sparse and not likely to be overdrawn every frame (like
'' in a tile-based game).

    Blit(0)

PUB Blit(source)
'' This command blits a 128x64 size image to the screen. The source image
'' must not use the sprite header used in other commands. This command is
'' primarily influenced for reference on drawing to the screen, not for
'' its game utility so much.
    
    repeat
    while instruction

    c_parameters{0} := source
    instruction := c_blitscreen

PUB Box(source, x, y)
'' This function displays an 8x8 tile from an address. This address could
'' be a single image or it could be full tileset; the user is responsible
'' for structuring their data. However, take a look at some of the tile
'' functions to see how Box can be used to build larger functionality
'' like tile mapping.
''
'' This is the instruction mapping for Box.
''
'' <pre>
''             y        x        instr
''          -------- --------  --------
'' 00000000 00000000 00000000  00000000
'' </pre>
''
    Sprite(source, x, y, 0)

PUB Sprite(source, x, y, frame)
'' * **source** - Memory address of the source image
'' * **x** - Horizontal destination position (0-15)
'' * **y** - Vertical destination position (0-7)
'' * **frame** - If the image has multiple frames, this integer will select which to use.
''
'' This is the instruction mapping for Sprite.
''
'' <pre>
'' clip  frame     y        x        instr
''  -   ------- -------- --------  --------
''  0   0000000 00000000 00000000  00000000
'' </pre>
''
'' This function allows the user to blit an arbitrarily-sized image
'' from a memory address. It is designed to accept the sprite output from img2dat,
'' and can handle multi-frame sprites, 3-color sprites, and sprites with transparency.
''
'' Read more on img2dat to see how you can generate source images to use with this
'' drawing command.

    repeat
    while instruction

    longmove(@c_parameters{0}, @source, 4)
    instruction := c_sprite

' *********************************************************
'  Maps
' *********************************************************  
VAR
    word    map_tilemap
    word    map_levelmap
    
PUB LoadMap(source_tilemap, source_levelmap)

    map_tilemap  := source_tilemap
    map_levelmap := source_levelmap
    
PUB TestMapCollision(objx, objy, objw, objh) | objtilex, objtiley, tile, tilecnt, tilecnttemp, x, y
'' Returns 1 if collision, 0 otherwise

    objx #>= 0
    objy #>= 0
    objtilex := objx >> 3 
    objtiley := objy >> 3
     
    tilecnt := 0
    tilecnttemp := 2 + byte[map_levelmap]{0} * objtiley
        
    repeat y from objtiley to objtiley + (objh>>3)
        repeat x from objtilex to objtilex + (objw>>3)
            tilecnt := tilecnttemp + x
            if (byte[map_levelmap][tilecnt] & COLLIDEBIT)
                return 1                
        tilecnttemp += byte[map_levelmap]{0}
        
PUB GetMapWidth

    return byte[map_levelmap]{0} 
    
PUB GetMapHeight

    return byte[map_levelmap][1]
    
PUB DrawMap(offset_x, offset_y, box_x1, box_y1, box_x2, box_y2) | tile, tilecnt, tilecnttemp, x, y
'' This function uses the Box command to draw an array of tiles to the screen.
'' Used in conjunction with the map2dat program included with this kit, it is
'' an easy way to draw your first game world to the screen.
''
'' * **offset_x** -
'' * **offset_y** -
'' * **width** -
'' * **height** -
''

    SetClipRectangle(box_x1<<3, box_y1<<3, box_x2<<3, box_y2<<3)

    tilecnt := 0
    tilecnttemp := 2 + byte[map_levelmap]{0} * (offset_y>>3)

    repeat y from 0 to box_y2-box_y1
        repeat x from 0 to box_x2-box_x1
            tilecnt := tilecnttemp + (offset_x >> 3) + x
            tile := (byte[map_levelmap][tilecnt] & TILEBYTE) - 1
            if tile => 0
                 Sprite(map_tilemap, (box_x1<<3) + (x << 3) - (offset_x & $7), (box_y1<<3) + (y<<3) - (offset_y & $7),tile)

        tilecnttemp += byte[map_levelmap]{0}

    SetClipRectangle(0, 0, 128, 64)

' *********************************************************
'  Text
' *********************************************************  
PUB LoadFont(sourcevar, startingcharvar, tilesize_xvar, tilesize_yvar)

    font := sourcevar
    startingchar := startingcharvar
    tilesize_x := tilesize_xvar
    tilesize_y := tilesize_yvar

PUB PutChar(char, x, y)

    Sprite(font, x, y, char - startingchar)

PUB PutString(stringvar, origin_x, origin_y)
   
    repeat strsize(stringvar)
        Sprite(font, origin_x, origin_y, byte[stringvar++] - startingchar)
        origin_x += tilesize_x
        
PUB TextBox(stringvar, origin_x, origin_y, w, h) | char, x, y

    x := origin_x
    y := origin_y
    
    repeat strsize(stringvar)
        char := byte[stringvar++]
        if char == NL or char == LF
            y += tilesize_y
            x := origin_x          
        elseif char == " "
            x += tilesize_x
        else   
            Sprite(font, x, y, char - startingchar)
            if x+tilesize_x => origin_x+w      
                y += tilesize_y
                x := origin_x
            else
                x += tilesize_x

PUB SetClipRectangle(clipx1, clipy1, clipx2, clipy2)
'' Sets bounding box for tile/sprite drawing operations, to prevent overdraw.
'' Defaults to 0, 0, 128, 64.
'' Use only multiples of 8.

    repeat
    while instruction

    longmove(@c_parameters{0}, @clipx1, 4)
    instruction := c_setcliprect

PUB TranslateBuffer(sourcebuffer, destbuffer)
'' This command converts a linear framebuffer to one formatted
'' for the KS0108 LCD memory map. The destination and source
'' buffer addresses are packed into the sourcegfx long.

    repeat
    while instruction

    longmove(@c_parameters{0}, @sourcebuffer, 2)
    instruction := c_translate

PUB DrawScreen

    TranslateBuffer(drawsurface, copysurface)

DAT                     org     0

graphicsdriver          jmpret  $, #setup

{done}                  wrlong  zero, par
{idle}                  rdlong  code, par wz
                        test    code, argn wc           ' check for arguments
                if_z    jmp     #$-2

                        mov     addr, code              ' args:n:[!Z]:cmd = 16:4:3:9
                        ror     addr, #16               ' extract argument location
                if_c    call    #args                   ' fetch arguments
'{n/a}          if_c    addx    addr, #3                ' advance beyond last argument
                        jmp     code                    ' execute function

' #### DRAW SPRITE
' ------------------------------------------------------
' parameters: arg0: source buffer (word aligned)
'             arg1: x
'             arg2: y
'             arg3: frame

drawsprite              mov     Addrtemp, destscrn
                        mov     sourceAddrTemp, arg0
                        mov     valutemp, #8
                        
                        ' get x position of box
                        mov     x1, arg1
                        
                        mov     iter_x, x1              ' this value rotates the word for the blender
                        shl     iter_x, #1              ' x << 1                       
                        and     iter_x, #$F             ' x % 8
                        
                        mov     datatemp, x1
                        sar     datatemp, #2            ' x / 4    ' n pixels = 2*n bits
                        adds    Addrtemp, datatemp                        

                        ' get y position of box
                        mov     y1, arg2

                        mov     iter_y, y1              ' this value iterates from y1 to y2

                        mov     datatemp, y1
                        shl     datatemp, #5
                        adds    Addrtemp, datatemp

                        
                        ' read header from sprite
                        rdword  frameboost, sourceAddrTemp
                        add     sourceAddrTemp, #2 
                        

                        ' get image width and height
                        rdword  w1, sourceAddrTemp
                        add     sourceAddrTemp, #2
                        rdword  h1, sourceAddrTemp      ' only width is left-shifted because height has 8 pages only
                        add     sourceAddrTemp, #2      ' get ready to start reading data
                        
                        mov     x2, x1
                        adds    x2, #8
                        mov     y2, y1
                        adds    y2, h1

                        'frame
                        cmp     arg3, #0 wz             ' frame number

                        'add frameboost to sourceAddr (frame) number of times
                if_nz   add     sourceAddrTemp, frameboost
                if_nz   djnz    arg3, #$-1              ' a proper multiply may be beneficial here
                                                        ' depending on max framecount
                       ' Begin copying data       
' INDEX_Y LOOP -------------------------------------
                        mov     index_y, h1           
:indexyloop             mov     datatemp3, Addrtemp
                        mov     xtmp1, x1
                        mov     xtmp2, x2

' INDEX_X LOOP -------------------------------------
                        mov     index_x, w1
                        shr     index_x, #3             '8 pixels in one word.
:indexxloop             mov     datatemp, datatemp3                        
                        
                        cmps    iter_y, _clipy1             wc
if_c                    jmp     #:skipall
                        cmps    iter_y, _clipy2             wc
if_nc                   jmp     #:skipall

                        ' Read old data in display buffer
                        ' only if this is first block in drawing operation
                        rdword  datatemp2, datatemp
                        add     datatemp, #2
                        rdword  blender1, datatemp
                        shl     blender1, #16
                        add     blender1, datatemp2
                        
                        ' read new word
                        rdword  datatemp2, sourceAddrTemp

                        ' prepare mask for blending old and new
                        mov     flipbyte1, datatemp2
                        shr     flipbyte1, #1
                        andn    flipbyte1, datatemp2    'color bits
                        and     flipbyte1, h5555                        
                        
                        mov     blendermask, flipbyte1
                        add     blendermask, flipbyte1
                        add     blendermask, flipbyte1
                        
                        xor     blendermask, hFFFF
                        and     datatemp2, blendermask
                        
                        shl     datatemp2, iter_x       ' rotate source words
                        shl     blendermask, iter_x
                        
                        andn    blender1, blendermask
                        add     blender1, datatemp2

                        ' split long into two words because we don't know whether this word
                        ' falls on a long boundary, so we have to write it one at a time.
                        mov     datatemp, datatemp3

                        ' perform sprite clipping
                        cmps    xtmp1, _clipx1                  wc
if_c                    jmp     #:skipblender1
                        cmps    xtmp1, _clipx2                  wc
if_nc                   jmp     #:skipblender1 
                        wrword  blender1, datatemp
:skipblender1
                        adds     datatemp, #2
                        
                        cmps    xtmp2, _clipx1                  wc
if_c                    jmp     #:skipblender2
                        cmps    xtmp2, _clipx2                  wc
if_nc                   jmp     #:skipblender2

                        shr     blender1, #16
                        wrword  blender1, datatemp
:skipblender2

                        adds    xtmp1, #8
                        adds    xtmp2, #8


:skipall                
                        add     sourceAddrTemp, #2
                        adds    datatemp3, #2

                        
                        djnz    index_x, #:indexxloop   ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' INDEX_X LOOP END -------------------------------------                                                
                        adds    Addrtemp, #32
                        adds    iter_y, #1
                        
                        djnz    index_y, #:indexyloop   ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' INDEX_Y LOOP END -------------------------------------                       

                        jmp     %%0                     ' return

' #### SET CLIP RECTANGLE
' ------------------------------------------------------
' parameters: arg0: x1
'             arg1: y1
'             arg2: x2
'             arg3: y2

setcliprect             mov     _clipx1, arg0           ' |
                        mov     _clipy1, arg1           ' |
                        mov     _clipx2, arg2           ' |
                        mov     _clipy2, arg3           ' copy parameters

                        jmp     %%0                     ' return
                        
' #### TRANSLATE BUFFER
' ------------------------------------------------------
' parameters: arg0: source buffer       (word aligned)
'             arg1: destination buffer  (word aligned)
'
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

translateLCD            mov     rcnt, #8                '  8 blocks of 8 rows
:rows                   mov     ccnt, #16               ' 16 blocks of 8 columns

' read 8 words of an 8x8 pixel block (words are separated by a whole line, 32 bytes)
                        
:columns                rdword  xsrc+0, arg0            ' load 8x8 pixel block
                        add     arg0, #32
                        rdword  xsrc+1, arg0
                        add     arg0, #32
                        rdword  xsrc+2, arg0
                        add     arg0, #32
                        rdword  xsrc+3, arg0
                        add     arg0, #32
                        rdword  xsrc+4, arg0
                        add     arg0, #32
                        rdword  xsrc+5, arg0
                        add     arg0, #32
                        rdword  xsrc+6, arg0
                        add     arg0, #32
                        rdword  xsrc+7, arg0

                        mov     pcnt, #8                ' scan 8 columns

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
                        rcr     trgt, #17

                        wrword  trgt, arg1              ' write out one pixel column
                        add     arg1, #2                ' advance destination

                        djnz    pcnt, #:loop

                        sub     arg0, #32*7 -2          ' rewind loader, next 8 columns
                        djnz    ccnt, #:columns

                        add     arg0, #256 -32          ' next 8 rows
                        djnz    rcnt, #:rows

                        jmp     %%0                     ' return

' #### CLEAR SCREEN
' ------------------------------------------------------
' parameters: none

clear                   mov     arg3, fullscreen

:loop                   wrword  zero, arg1
                        add     arg1, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

' #### BLIT SCREEN
' ------------------------------------------------------
' parameters: arg0: source buffer       (word aligned)
'             arg1: destination buffer  (word aligned)

blitscreen              mov     arg1, destscrn          ' override destination
                        tjz     arg0, #clear            ' no source, clear screen
                        add     arg0, #6                ' skip sprite header

translateVGA            mov     arg3, fullscreen        ' words per screen
                        
:loop                   rdword  arg2, arg0
                        add     arg0, #2
                        wrword  arg2, arg1
                        add     arg1, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

' support code (fetching up to 4 arguments)

args                    rdlong  arg0, addr              ' read 1st argument                 
                        cmpsub  addr, delta wc          ' [increment address and] check exit
                if_nc   jmpret  zero, args_ret nr,wc    ' cond: early return                
                                                                                            
                        rdlong  arg1, addr              ' read 2nd argument                 
                        cmpsub  addr, delta wc                                              
                if_nc   jmpret  zero, args_ret nr,wc                                        
                                                                                            
                        rdlong  arg2, addr              ' read 3rd argument                 
                        cmpsub  addr, delta wc                                              
                if_nc   jmpret  zero, args_ret nr,wc                                        
                                                                                            
                        rdlong  arg3, addr              ' read 4th argument                 
'                       cmpsub  addr, delta wc                                              
'               if_nc   jmpret  zero, args_ret nr,wc                                        

args_ret                ret

' initialised data and/or presets

Addrtemp                long    0
sourceAddrTemp          long    0

outputAddr              long    4      
destscrn                long    8

fullscreen              long    SCREENSIZE_BYTES/2  'EXTREMELY IMPORTANT TO DIVIDE BY 2; CONSTANT IS WORD-ALIGNED, NOT BYTE-ALIGNED
valutemp                long    0


datatemp                long    0
datatemp2               long    0
datatemp3               long    0

hFFFF                   long    $FFFF
h5555                   long    $5555

frameboost              long    0
w1                      long    0
h1                      long    0

flipbyte1               long    0

index_x                 long    0
index_y                 long    0
iter_x                  long    0
iter_y                  long    0


_clipx1                 long    0
_clipy1                 long    0
_clipx2                 long    128
_clipy2                 long    64

blender1                long    0
blender2                long    0
blendermask             long    0


delta                   long    %001_0 << 28 | $FFFC    ' %10 deal with movi setup
                                                        ' -(-4) address increment
argn                    long    |< 12                   ' function does have arguments

' Stuff below is re-purposed for temporary storage.

setup                   add     outputAddr, par         ' get output long            
                        add     destscrn, par
                        rdword  destscrn, destscrn                           

                        jmp     %%0                     ' return

' uninitialised data and/or temporaries

                        org     setup

x1                      res     1
y1                      res     1
x2                      res     1
y2                      res     1
xtmp1                   res     1
xtmp2                   res     1


addr                    res     1
code                    res     1

arg0                    res     1
arg1                    res     1
arg2                    res     1
arg3                    res     1

pcnt                    res     1
rcnt                    res     1
ccnt                    res     1
trgt                    res     1
xsrc                    res     8

tail                    fit       

CON
  zero = $1F0                                           ' par (dst only)

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