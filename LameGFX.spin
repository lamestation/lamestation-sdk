''
'' LameGFX Fast Drawing Library
'' -------------------------------------------------
'' Version: 1.0
'' Copyright (c) 2013-2014 LameStation LLC
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir
'' -------------------------------------------------
'' This is a graphics library designed for use on the
'' LameStation portable gaming handheld. It is designed
'' to be straightforward to use and easy to set up.
''
'' Creating your first program is simple! First, include
'' the graphics object in an object block.
''
'' To communicate between Spin and assembly, the GFX
'' driver establishes two longs, one for sending information
'' and one for receiving. These are:
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
    long    c_clearscreen,    c_blitscreen,    c_sprite,     c_setcliprect,    c_translate
    long    p_clearscreen[0], p_blitscreen[1], p_sprite[4],  p_setcliprect[4], p_translate[2]

PUB null
'' This is not a top level object.

PUB Start(buffer, screen)

    drawsurface := buffer
    copysurface := screen
    cognew(@graphicsdriver, @instruction)
'                                                   function has(1) no(0) argument(s) ----+
'                                                              number of arguments -1 --+ |
'                                                                                       | |
    c_clearscreen := @p_clearscreen << 16 | (@clearscreen1 - @graphicsdriver) >> 2 | %000_0 << 12
    c_blitscreen  := @p_blitscreen  << 16 | (@blitscreen1  - @graphicsdriver) >> 2 | %000_1 << 12
    c_sprite      := @p_sprite      << 16 | (@sprite1      - @graphicsdriver) >> 2 | %011_1 << 12
    c_setcliprect := @p_setcliprect << 16 | (@setcliprect1 - @graphicsdriver) >> 2 | %011_1 << 12
    c_translate   := @p_translate   << 16 | (@translateLCD - @graphicsdriver) >> 2 | %001_1 << 12
'   c_translate   := @p_translate   << 16 | (@translateVGA - @graphicsdriver) >> 2 | %001_1 << 12

PUB WaitToDraw

    repeat
    while instruction

PUB ClearScreen
'' This command clears the screen to black. Recommended if your game
'' display is sparse and not likely to be overdrawn every frame (like
'' in a tile-based game).

    repeat
    while instruction

    instruction := c_clearscreen

PUB Blit(source)
'' This command blits a 128x64 size image to the screen. The source image
'' must not use the sprite header used in other commands. This command is
'' primarily influenced for reference on drawing to the screen, not for
'' its game utility so much.
    
    repeat
    while instruction

    p_blitscreen{0} := source
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

    longmove(@p_sprite{0}, @source, 4)
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
    tilecnttemp := 2
    
    y := 0
    repeat while y < objtiley
        tilecnttemp += byte[map_levelmap][0]
        y++
        
    repeat y from objtiley to objtiley + (objh>>3)
        repeat x from objtilex to objtilex + (objw>>3)
            tilecnt := tilecnttemp + x
            if (byte[map_levelmap][tilecnt] & COLLIDEBIT)
                return 1                
        tilecnttemp += byte[map_levelmap][0]
        
PUB GetMapWidth

    return byte[map_levelmap][0] 
    
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
    tilecnttemp := 2
    
    y := 0
    repeat while y < (offset_y>>3)
        tilecnttemp += byte[map_levelmap][0]
        y++

    repeat y from 0 to box_y2-box_y1
        repeat x from 0 to box_x2-box_x1
            tilecnt := tilecnttemp + (offset_x >> 3) + x
            tile := (byte[map_levelmap][tilecnt] & TILEBYTE) - 1
            if tile => 0
                 Sprite(map_tilemap, (box_x1<<3) + (x << 3) - (offset_x & $7), (box_y1<<3) + (y<<3) - (offset_y & $7),tile)

        tilecnttemp += byte[map_levelmap][0]

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
        
PUB TextBox(stringvar, origin_x, origin_y, w, h) | stringcursor, char, x, y

    stringcursor := 0
    x := origin_x
    y := origin_y
    
    repeat while byte[stringvar][stringcursor] <> 0
        char := byte[stringvar][stringcursor]
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
        stringcursor++

PUB SetClipRectangle(clipx1, clipy1, clipx2, clipy2)
'' Sets bounding box for tile/sprite drawing operations, to prevent overdraw.
'' Defaults to 0, 0, 128, 64.
'' Use only multiples of 8.

    repeat
    while instruction

    longmove(@p_setcliprect{0}, @clipx1, 4)
    instruction := c_setcliprect

PUB TranslateBuffer(sourcebuffer, destbuffer)
'' This command converts a linear framebuffer to one formatted
'' for the KS0108 LCD memory map. The destination and source
'' buffer addresses are packed into the sourcegfx long.

    repeat
    while instruction

    longmove(@p_translate{0}, @sourcebuffer, 2)
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

'' instruct1 does not pass values that are big, and it's reading in a long.
'' I can use the rest of the room in the long to pass through parameters like
'' x, y, frame, duration. The screen isn't any larger than 128x64, so 256
'' should be sufficient; just need to watch for signs.
''
'' param3   param2   param1    instr/flags
''
'' 00000000 00000000 00000000   00000000

' CLEAR THE SCREEN
clearscreen1            mov     arg1, destscrn
                        mov     arg3, fullscreen

:loop                   wrword  zero, arg1
                        add     arg1, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

'' #### BLIT FULL SCREEN
blitscreen1             mov     arg1, destscrn
                        mov     arg3, fullscreen
                        
                        add     arg0, #6
       
:loop                   rdword  arg2, arg0
                        add     arg0, #2
                        wrword  arg2, arg1
                        add     arg1, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

'' #### BLIT SPRITE
'' ---------------------------------------------------
''
'' ###### instruction format
''
'' <pre>
'' clip trans   frame     y        x        instr
''  -     -     ------ -------- --------  --------
''  0     0     000000 00000000 00000000  00000000   
'' </pre>

sprite1                 mov     Addrtemp, destscrn
                        mov     sourceAddrTemp, arg0
                        mov     valutemp, #8
                        
                        ' get x position of box
                        mov     x1, arg1
                        
                        mov     iter_x, x1             ' this value rotates the word for the blender
                        shl     iter_x, #1             ' x << 1                        
                        and     iter_x, #$F            ' x % 8
                        
                        mov     datatemp, x1
                        sar     datatemp, #2            ' x / 4    ' n pixels = 2*n bits
                        adds    Addrtemp, datatemp                        

                        ' get y position of box
                        mov     y1, arg2

                        mov     iter_y, y1             ' this value iterates from y1 to y2

                        mov     datatemp, y1
                        shl     datatemp, #5
                        adds    Addrtemp, datatemp

                        
                        'frame
                        mov     frame1, arg3            ' get frame number

                        ' read header from sprite
'                       rdword  sourceAddrTemp, sourceAddr                             
                        rdword  frameboost, sourceAddrTemp
                        add     sourceAddrTemp, #2 
                        

                        ' get image width and height
                        rdword  w1, sourceAddrTemp
                        add     sourceAddrTemp, #2
                        rdword  h1, sourceAddrTemp       ' only width is left-shifted because height has 8 pages only
                        add     sourceAddrTemp, #2       ' get ready to start reading data
                        
                        mov     x2, x1
                        adds    x2, #8
                        mov     y2, y1
                        adds    y2, h1

                        'add frameboost to sourceAddr (frame) number of times
:frameboostloop         cmp     frame1, #0                  wz
if_nz                   add     sourceAddrTemp, frameboost
if_nz                   sub     frame1, #1
if_nz                   jmp     #:frameboostloop

                        

                       ' Begin copying data       
' INDEX_Y LOOP -------------------------------------
                        mov     index_y, h1           
:indexyloop             mov     datatemp3, Addrtemp
                        mov     xtmp1, x1
                        mov     xtmp2, x2

' INDEX_X LOOP -------------------------------------
                        mov     index_x, w1
                        shr     index_x, #3                     '8 pixels in one word.
:indexxloop             mov     datatemp, datatemp3                        
                        
                        cmps    iter_y, _clipy1             wc
if_c                    jmp     #:skipall
                        cmps    iter_y, _clipy2             wc
if_nc                   jmp     #:skipall


                        '' Read old data in display buffer
                        '' only if this is first block in drawing operation
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
                        andn    flipbyte1, datatemp2 'color bits
                        and     flipbyte1, h5555                        
                        
                        mov     blendermask, flipbyte1
                        shl     flipbyte1, #1
                        add     blendermask, flipbyte1
                        
                        xor     blendermask, hFFFF
                        and     datatemp2, blendermask
                        
                        
                        
                        shl     datatemp2, iter_x      ' rotate source words
                        shl     blendermask, iter_x
                        
                        andn    blender1, blendermask
                        add     blender1, datatemp2


                        ' split long into two words because we don't know whether this word
                        ' falls on a long boundary, so we have to write it one at a time.
                        mov     blender2, blender1    ' copy situation

                        and     blender1, hFFFF
                        shr     blender2, #16
                        and     blender2, hFFFF
                        
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

                        wrword  blender2, datatemp
:skipblender2

                        adds    xtmp1, #8
                        adds    xtmp2, #8

                        
:skipall                
                        add     sourceAddrTemp, #2
                        adds    datatemp3, #2

                        
                        djnz    index_x, #:indexxloop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' INDEX_X LOOP END -------------------------------------                                                
                        adds    Addrtemp, #32
                        adds    iter_y, #1
                        
                        djnz    index_y, #:indexyloop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' INDEX_Y LOOP END -------------------------------------                       

                        jmp     %%0                     ' return




'' WRITE TEXT
textbox1


'' #### SetClipRectangle
'' ---------------------------------------------------
''
'' ###### instruction format
''
'' <pre>
''  clipx1 clipy1  clipx2  clipy2  instr
''  ------ ------ ------- -------  ------
''  000000 000000 0000000 0000000  000000   
'' </pre>

setcliprect1            mov     _clipx1, arg0                   ' |
                        mov     _clipy1, arg1                   ' |
                        mov     _clipx2, arg2                   ' |
                        mov     _clipy2, arg3                   ' copy parameters

                        jmp     %%0                             ' return
                        
'' #### TRANSLATE BUFFER
'' ---------------------------------------------------
'' clip trans   frame     y        x        instr
''  -     -     ------ -------- --------  --------
''  0     0     000000 00000000 00000000  00000000   
'' --------------------------------------------------- 

translateLCD            mov     arg2, #0                ' offset from base

                        mov     rcnt, #8                '  8 blocks of 8 rows
:rows                   mov     ccnt, #16               ' 16 blocks of 8 columns

:columns                mov     addr, arg0              ' |
                        add     addr, arg2              ' base + offset
                        
                        rdword  xsrc+0, addr            ' load 8x8 pixel block
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

                        mov     pcnt, #8

:loop                   shr     xsrc+0, #1 wc           ' even column(s)
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

                        shr     xsrc+0, #1 wc           ' odd column(s)
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

                        wrword  trgt, arg1
                        add     arg1, #2

                        djnz    pcnt, #:loop

                        add     arg2, #2                ' next 8 pixel columns
                        djnz    ccnt, #:columns

                        add     arg2, #256 -32          ' next 8 rows
                        djnz    rcnt, #:rows

                        jmp     %%0                     ' return

' support code

translateVGA            mov     arg3, fullscreen
                        
:loop                   rdword  arg2, arg0
                        add     arg0, #2
                        wrword  arg2, arg1
                        add     arg1, #2
                        djnz    arg3, #:loop

                        jmp     %%0


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
'valutemp2              long    0


datatemp                long    0
datatemp2               long    0
datatemp3               long    0

'h0000FF00              long    $0000FF00
'h00FF0000              long    $00FF0000
'hFF000000              long    $FF000000

hFFFF                   long    $FFFF
h5555                   long    $5555

'invert                 long    %01010_1010_1010_1010_1010_1010_1010_101
'invert                 long    $FFFF_FFFF

frame1                  long    0
frameboost              long    0
w1                      long    0
h1                      long    0

flipbyte1               long    0

'index1                 long    0
'index2                 long    0
index_x                 long    0
index_y                 long    0
iter_x                  long    0
iter_y                  long    0
'srcpointer             long    0
'destpointer            long    0


_clipx1                 long    0
_clipy1                 long    0
_clipx2                 long    128
_clipy2                 long    64

blender1                long    0
blender2                long    0
blendermask             long    0
'blenderoffset          long    0


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