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
'' |   1  |   1   |   0  | Gray        |
'' +------+-------+------+-------------+
''
'' This operation is equivalent to `Mask = Flip & !Color`.
''
'' The color constant definitions here correspond to this.
''
    BLACK = $0000
    WHITE = $5555
    TRANSPARENT = $AAAA
    GRAY = $FFFF


    ' draw map function
    COLLIDEBIT = $80
    TILEBYTE = COLLIDEBIT-1

CON
    #0, MX, MY                                          ' level map header indices
    #1, SX, SY                                          '  tile map header indices

    F_INVERTCOLOR = %00000001                           ' color inversion (black/white)

VAR
'' These longs make up the interface between Spin and
'' assembly.
'' They must apppear in this order.
'' ---------------------------------------------------
    long    instruction                                 ' |
    long    drawsurface                                 ' order/type locked
'' ---------------------------------------------------
    word    font
    byte    startingchar
    byte    tilesize_x
    byte    tilesize_y

VAR
    long    c_fillbuffer, c_blitscreen, c_setmode, c_setcliprect, c_drawtilemap, c_sprite
    long    c_parameters[9]

VAR
    long    map_tilemap                                 ' |
    long    map_levelmap                                ' order/type locked

PUB Start

    drawsurface := @graphicsdriver                      ' reuse DAT section
    instruction := NEGX                                 ' lock (see below)
    cognew(@graphicsdriver, @instruction)
'                                                 function has(1) no(0) argument(s) -----+
'                                                            number of arguments -1 ---+ |
'                                                                                      | |
    c_fillbuffer  := @c_parameters << 16 | (@fillbuffer  - @graphicsdriver) >> 2 | %0001_1 << 11
    c_blitscreen  := @c_parameters << 16 | (@blitscreen  - @graphicsdriver) >> 2 | %0001_1 << 11
    c_setmode     := @c_parameters << 16 | (@setmode     - @graphicsdriver) >> 2 | %0001_1 << 11
    c_setcliprect := @c_parameters << 16 | (@setclip     - @graphicsdriver) >> 2 | %0011_1 << 11
    c_drawtilemap := @c_parameters << 16 | (@drawtilemap - @graphicsdriver) >> 2 | %1000_1 << 11
    c_sprite      := @c_parameters << 16 | (@drawsprite  - @graphicsdriver) >> 2 | %0100_1 << 11

' Since we reuse the DAT section holding the driver we have to make sure that the cog is up
' and running before we make it public (and someone e.g. clears it). As part of the command
' loop the instruction field is cleared. This also happens at startup, IOW we can simply
' monitor said location becoming zero again (NEGX == $80000000).

    repeat
    while instruction

    longfill(drawsurface, 0, 512)                       ' clear screen

    return drawsurface

PUB WaitToDraw

    repeat
    while instruction

PUB ClearScreen(color)
'' Fill the composition buffer with the given color.

    repeat
    while instruction

    longmove(@c_parameters{0}, @result, 2)
    instruction := c_fillbuffer

PUB Blit(source)
'' This command blits a 128x64 size image to the screen. It is
'' primarily influenced for reference on drawing to the screen,
'' not for its game utility so much.

    repeat
    while instruction

    longmove(@c_parameters{0}, @result, 2)
    instruction := c_blitscreen

PUB Sprite(source, x, y, frame)
'' This function allows the user to blit an arbitrarily-sized image
'' from a memory address. It is designed to accept the sprite output from img2dat,
'' and can handle multi-frame sprites, 3-color sprites, and sprites with transparency.
''
'' Read more on img2dat to see how you can generate source images to use with this
'' drawing command.

    repeat
    while instruction

    longmove(@c_parameters{0}, @result, 5)
    instruction := c_sprite

PUB InvertColor(enabled) ' boolean value
'' When enabled colors black and white are plotted inverted (gray is left unchanged).

    repeat
    while instruction

    c_parameters{0} := enabled
    c_parameters[1] := F_INVERTCOLOR
    instruction := c_setmode

' *********************************************************
'  Maps
' *********************************************************
PUB LoadMap(source_tilemap, source_levelmap)

    map_tilemap  := source_tilemap
    map_levelmap := source_levelmap

PUB TestMapCollision(objx, objy, objw, objh) | tilebase, x, y, tx, ty
'' Returns non-zero if a collision has occurred between an object and the map; 0 otherwise.
'' Returned tiles are offset by (1,1).

    ty := word[map_tilemap][SY]

    objh  := (word[map_levelmap][MY] * ty) <# (objh += objy)
    objy #>= 0

    if objh-- =< objy
        return

    tx := word[map_tilemap][SX]

    objw  := (word[map_levelmap][MX] * tx) <# (objw += objx)
    objx #>= 0

    if objw-- =< objx
        return

    objx /= tx
    objy /= ty
    objw /= tx
    objh /= ty

    tilebase := 4 + word[map_levelmap][MX] * objy + map_levelmap

    repeat y from objy to objh
        repeat x from objx to objw
            if (byte[tilebase][x] & COLLIDEBIT)
                return (x+1)+((y+1) << 16)

        tilebase += word[map_levelmap][MX]

PUB TestMapMoveY(x, y, w, h, newy) | tmp, ty

    if newy == y
        return

    tmp := TestMapCollision(x, newy, w, h)
    if not tmp
        return

    ty  := word[map_tilemap][SY]
    tmp := ((tmp >> 16)-1) * ty - newy

    if newy > y
        return tmp - h
    if newy < y
        return tmp + ty

PUB TestMapMoveX(x, y, w, h, newx) | tmp, tx

    if newx == x
        return

    tmp := TestMapCollision(newx, y, w, h)
    if not tmp
        return

    tx  := word[map_tilemap][SY]
    tmp := ((tmp & $FFFF)-1) * tx - newx

    if newx > x
        return tmp - w
    if newx < x
        return tmp + tx

PUB GetMapWidth

    return word[map_levelmap][MX]

PUB GetMapHeight

    return word[map_levelmap][MY]

PUB DrawMap(offset_x, offset_y)
'' This function uses the Sprite command to draw an array of tiles to the screen.
'' Used in conjunction with the map2dat program included with this kit, it is
'' an easy way to draw your first game world to the screen.

  DrawMapRectangle(offset_x, offset_y, 0, 0, res_x, res_y)

PUB DrawMapRectangle(offset_x, offset_y, x1, y1, x2, y2)
'' Underlying method to DrawMap which lets you specify the clipping region.

    repeat
    while instruction

    longmove(@c_parameters{0}, @result,      7)
    longmove(@c_parameters[7], @map_tilemap, 2)
    instruction := c_drawtilemap

' *********************************************************
'  Text
' *********************************************************
PUB LoadFont(sourcevar, startingcharvar, tilesize_xvar, tilesize_yvar)

    font := sourcevar
    startingchar := startingcharvar
    ifnot tilesize_x := tilesize_xvar
      tilesize_x := word[font][SX]
    ifnot tilesize_y := tilesize_yvar
      tilesize_y := word[font][SY]

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

    repeat
    while instruction

    longmove(@c_parameters{0}, @clipx1, 4)
    instruction := c_setcliprect

DAT                     org     0

graphicsdriver          jmpret  $, #setup               ' run setup once, then used
                                                        ' as return vector
{done}                  wrlong  zero, par               ' command finished
{idle}                  rdlong  code, par wz            ' fetch next command
                        test    code, argn wc           ' check for arguments
                if_z    jmp     #$-2                    ' try again

                        mov     addr, code              ' args:n:[!Z]:cmd = 16:5:2:9
                        ror     addr, #16               ' extract argument location
                if_c    call    #args                   ' fetch arguments
'{n/a}          if_c    addx    addr, #3                ' advance beyond last argument
                        jmp     code                    ' execute function

' #### FILL BUFFER
' ------------------------------------------------------
' parameters: arg0: dst buffer (word aligned) or NULL
'             arg1: fill value

fillbuffer              cmp     arg0, #0 wz
                if_e    rdword  arg0, surface           ' draw surface
                        mov     arg3, wcnt              ' words per buffer

:loop                   wrword  arg1, arg0
                        add     arg0, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

' #### BLIT SCREEN
' ------------------------------------------------------
' parameters: arg0: dst buffer (word aligned) or NULL
'             arg1: src buffer (word aligned)

blitscreen              cmp     arg0, #0 wz
                if_e    rdword  arg0, surface           ' draw surface
                        add     arg1, #6                ' skip sprite header

                        mov     arg3, wcnt              ' words per screen

' Do word-aligned copy (no 4n guarantee) from src to dst.

:loop                   rdword  arg2, arg1
                        add     arg1, #2
                        wrword  arg2, arg0
                        add     arg0, #2
                        djnz    arg3, #:loop

                        jmp     %%0                     ' return

' #### SET MODE
' ------------------------------------------------------
' parameters: arg0: on/off (boolean, NZ/Z)
'             arg1: flag mask

setmode                 cmp     arg0, #0 wz
                        muxnz   mode, arg1              ' re/set flag

                        jmp     %%0                     ' return

' #### SET CLIP RECTANGLE
' ------------------------------------------------------
' parameters: arg0: x1
'             arg1: y1
'             arg2: x2
'             arg3: y2

setclip                 mov     c_x1, arg0              ' copy ...
                        mov     c_y1, arg1
                        mov     c_x2, arg2
                        mov     c_y2, arg3

validateCR              mins    c_x1, #0                ' ... and sanity check
                        maxs    c_x1, #res_x

                        mins    c_y1, #0
                        maxs    c_y1, #res_y

                        mins    c_x2, #0
                        maxs    c_x2, #res_x

                        mins    c_y2, #0
                        maxs    c_y2, #res_y

                        test    $, #1 wc                ' set carry

' Calculate two sets of clipping masks which are used for pixel exact clipping.
' This is based on how far the clipping x coordinates reach into their respective
' double word of pixels. Note, this is specific to the current sprite renderer.

                        mov     mskLH, c_x1
                        and     mskLH, #%111
                        mov     mskLL, #0
                        rcl     mskLL, mskLH
                        rcl     mskLL, mskLH            ' %%00000000_0???????
                        mov     mskLH, mskLL
                        rcl     mskLH, #16              ' %%0???????_????????

                        neg     mskRH, c_x2
                        and     mskRH, #%111
                        mov     mskRL, #0
                        rcr     mskRL, mskRH
                        rcr     mskRL, mskRH            ' %%???????0_00000000
                        mov     mskRH, mskRL
                        rcr     mskRH, #16              ' %%????????_???????0

                        jmp     %%0                     ' return


pushCR                  mov     backup+0, clip+0        ' preserve clipping rectangle
                        mov     backup+1, clip+1
                        mov     backup+2, clip+2
                        mov     backup+3, clip+3
                        mov     backup+4, clip+4
                        mov     backup+5, clip+5
                        mov     backup+6, clip+6
                        mov     backup+7, clip+7
pushCR_ret              ret


popCR                   mov     clip+0, backup+0        ' restore clipping rectangle
                        mov     clip+1, backup+1
                        mov     clip+2, backup+2
                        mov     clip+3, backup+3
                        mov     clip+4, backup+4
                        mov     clip+5, backup+5
                        mov     clip+6, backup+6
                        mov     clip+7, backup+7
popCR_ret               ret

' #### DRAW TILE MAP
' ------------------------------------------------------
' parameters: arg0: dst buffer (word aligned) or NULL
'             arg1: x offset
'             arg2: y offset
'             arg3: cx1
'             arg4: cy1
'             arg5: cx2
'             arg6: cy2
'             arg7: tile data
'             arg8: level map
{
PUB DrawMap(offset_x, offset_y) | tile, tilecnttemp, x, y, tx, ty

    tx := word[map_tilemap][SX]
    ty := word[map_tilemap][SY]

    tilecnttemp := 4 + word[map_levelmap][MX] * (offset_y / ty) + (offset_x / tx) + map_levelmap

    offset_x := cx1 - offset_x // tx
    offset_y := cy1 - offset_y // ty

    repeat y from offset_y to cy2 -1 step ty
        repeat x from offset_x to cx2 -1 step tx
            if tile := byte[tilecnttemp][(x - offset_x) / tx] & TILEBYTE
                 Sprite(map_tilemap, x, y, --tile)

        tilecnttemp += word[map_levelmap][MX]
}
drawtilemap             call    #pushCR                 ' preserve current clipping rectangle

                        mov     c_x1, arg3              ' copy local settings
                        mov     c_y1, arg4
                        mov     c_x2, arg5
                        mov     c_y2, arg6

                        jmpret  %%0, #validateCR        ' validate local settings

' Get logical tile size (previously 8n by 8m).

                        mov     tadr, arg7              ' local copy                    (%%)
                        add     arg7, #2
                        rdword  tm_x, arg7              ' word[map_tilemap][SX]
                        add     arg7, #2
                        rdword  tm_y, arg7              ' word[map_tilemap][SY]

' This routine calls another one which means that arg# can't be used for temporary
' registers. We therefore preserve arg0, arg7 and arg8 (dest, tadr, madr).

                        mov     dest, arg0              ' local copy (fill hub window)  (%%)

' Grab the map width and skip the header of the level map.
'   tilecnttemp := 4 + word[map_levelmap][MX] * (offset_y / ty) + (offset_x / tx) + map_levelmap
'                  =                                                              ==============

                        mov     madr, arg8              ' local copy                    (%%)
                        rdword  madv, madr              ' map (byte) width
                        add     madr, #4                ' skip header

' Now we add the x offset (divided by tile width).
'   tilecnttemp := 4 + word[map_levelmap][MX] * (offset_y / ty) + (offset_x / tx) + map_levelmap
'                  =                                            ================================

                        mov     eins, arg1
                        mov     zwei, tm_x
                        call    #divide                 ' offset_x / tx
                        add     madr, eins              ' high word (remainder) ignored

' Calculate X loop start value (while we have the remainder available).

                        shr     eins, #16 wz            ' offset_x // tx
                        mov     lp_x, c_x1
                        sumnz   lp_x, eins              ' offset_x := cx1 - offset_x // tx

                        cmps    lp_x, c_x2 wc
                if_nc   jmp     #:restore               ' early exit (invisible)

' Then we do the same for the y offset but have to multiply it by the map width.
'   tilecnttemp := 4 + word[map_levelmap][MX] * (offset_y / ty) + (offset_x / tx) + map_levelmap
'                  =============================================================================

                        mov     eins, arg2
                        mov     zwei, tm_y
                        call    #divide                 ' offset_y / ty
                        mov     zwei, eins              ' preserve value

' Calculate Y loop start value (while we have the remainder available).

                        shr     eins, #16 wz            ' offset_y // ty
                        mov     lp_y, c_y1
                        sumnz   lp_y, eins              ' offset_y := cy1 - offset_y // ty

                        cmps    lp_y, c_y2 wc
                if_nc   jmp     #:restore               ' early exit (invisible)

' Now do the multiply with the map width.

                        mov     eins, madv
                        shl     zwei, #16               ' offset_y / ty
                        shr     zwei, #1                ' align operand for 16x16bit

                        shr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc           ' 16x4bit, precision: 16

                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc           ' 16x4bit, precision: 16

                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc           ' 16x4bit, precision: 16

                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc
                        rcr     eins, #1 wc
                if_c    add     eins, zwei wc           ' 16x4bit, precision: 16

                        add     madr, eins              ' apply offset

' Run the nested loop(s).

:yloop                  mov     eins, lp_x              ' reload temporary
                        mov     zwei, madr              ' map address

:xloop                  rdbyte  drei, zwei              ' get tile info
                        add     zwei, #1                ' advance
                        and     drei, #TILEBYTE wz      ' tile index (0 is transparent)
                if_z    jmp     #:xnext

                        sub     drei, #1                ' adjust index

                        mov     arg0, dest              ' |
                        mov     arg1, tadr              ' |
                        mov     arg2, eins              ' |
                        mov     arg3, lp_y              ' transfer parameters
                        mov     arg4, drei              ' |
                        jmpret  %%0, #drawsprite        ' call sprite function

:xnext                  add     eins, tm_x
                        cmps    eins, c_x2 wc
                if_c    jmp     #:xloop                 ' for all (tile) columns

                        add     madr, madv              ' next row

                        add     lp_y, tm_y
                        cmps    lp_y, c_y2 wc
                if_c    jmp     #:yloop                 ' for all (tile) rows

:restore                call    #popCR                  ' restore clipping rectangle
                        movs    %%0, #1                 ' restore vector
                        jmp     %%0                     ' return

' Propeller Manual v1.2
' Divide x[31..0] by y[15..0] (y[16] must be 0)
' on exit, quotient is in x[15..0] and remainder is in x[31..16]
'
divide                  shl     zwei, #15               ' get divisor into y[30..15]
                        mov     drei, #16               ' ready for 16 quotient bits
                        cmpsub  eins, zwei wc           ' y =< x? Subtract it, quotient bit in c
                        rcl     eins, #1                ' rotate c into quotient, shift dividend
                        djnz    drei, #$-2              ' loop until done
divide_ret              ret                             ' div in x[15..0], rem in x[31..16]

' #### DRAW SPRITE
' ------------------------------------------------------
' parameters: arg0: dst buffer (word aligned) or NULL
'             arg1: src buffer (word aligned)
'             arg2: x
'             arg3: y
'             arg4: frame

drawsprite              mov     scrn, arg0 wz
                if_z    rdword  scrn, surface           ' draw surface

' Extract pixel position for shift in destination value, then create bit offset.

                        mov     iter_x, arg2            ' this value rotates the word for the blender
                        and     iter_x, #%111           ' x % 8
                        shl     iter_x, #1              ' x << 1

                        mov     iter_y, arg3            ' row index

' Calculate start and end address of the first (unclipped) line.

                        shl     arg3, #5                ' y * 32
                        add     scrn, arg3              ' line start (inclusive)
                        mov     send, #32
                        add     send, scrn              ' line end (exclusive)

' Apply x offset which is first transformed into a word index then into its byte index.

                        sar     arg2, #3                ' x /= 8, n pixels = 2n bits
                        shl     arg2, #1                ' back to byte offset
                        add     arg2, scrn              ' address ready, 2n

' Same for lhs clipping value, which is then applied to the line start address.

                        mov     arg3, c_x1
                        shr     arg3, #3                ' word offset
                        shl     arg3, #1                ' back to byte offset
                        add     scrn, arg3              ' apply clipping, 2n

' And again for rhs clipping value which is applied to the line end address. These two
' addresses hold the possible drawing target for the sprite (left/right limits).

                        mov     arg3, #128
                        sub     arg3, c_x2
                        shr     arg3, #3                ' word offset
                        shl     arg3, #1                ' back to byte offset
                        sub     send, arg3              ' apply clipping, 2n

' Get sprite header info, i.e. frame size (in bytes), width and height.

                        rdword  arg3, arg1
                        add     arg1, #2                ' get frame size

                        rdword  ws, arg1
                        add     arg1, #2
                        add     ws, #7                  ' align to 8n (1/2)
                        rdword  hs, arg1
                        add     arg1, #2                ' get image width and height
                        andn    ws, #7                  ' align to 8n (2/2)

' Calculate the byte width of the sprite (for line advancement).

                        mov     wb, ws
                        shr     wb, #2                  ' byte length (4 px/byte)

' X loop runs in words, calculate length.

                        shr     ws, #3                  ' 8 px/word

' Lazy multiply if a sprite index <>0 is requested.

                        cmp     arg4, #0 wz             ' frame index
                if_nz   add     arg1, arg3              ' a proper multiply may be beneficial here
                if_nz   djnz    arg4, #$-1              ' depending on max framecount

' arg1: src byte address (xxword OK)
' arg2: dst byte address (xxword OK)
'   ws: column (word) count
'   hs: row count
'   wb: source width in byte (row advance)

' ----- Y LOOP -----------------------------------------
:yloop                  cmps    iter_y, c_y1 wc         ' ToDo: clipping belongs outside any loop
                if_c    jmp     #:skipall
                        cmps    iter_y, c_y2 wc
                if_nc   jmp     %%0                     ' if greater equal _clipy2 just exit

                        mov     index_x, ws             ' temporary copy, we run several lines

                        mov     dstT, arg2              ' |
                        mov     srcT, arg1              ' temporary target address copies
' ----- X LOOP -----------------------------------------
                        rdword  dstL, dstT
:xloop                  add     dstT, #2
                        rdword  dstH, dstT
                        shl     dstH, #16
                        or      dstL, dstH              ' extract 16 dst pixel

                        rdword  srcW, srcT              ' extract 8 src pixel
                        add     srcT, #2                ' advance
                        or      srcW, trns              ' high word is always transparent
                        rol     srcW, iter_x            ' align with dst

' dstL now holds the long "below" the source word srcW. Any unused pixel in the latter is
' marked transparent. A bit pattern of %10 marks the transparent color which is now extracted
' for all 16 pixels (transparent will result in %01, filled in %00).

                        mov     frqb, srcW              ' %10 is transparent
                        shr     frqb, #1
                        and     frqb, grid              ' extract transparent pixel marker
                        mov     vier, frqb              ' copy high bit pattern
                        andn    frqb, srcW              ' only keep transparent pixels

                        xor     vier, grid              ' invert

' Multiply the resulting mask by 3, e.g. %010001 becomes %110011 or %%303. This uses the fact
' that phsx of a counter has frqx added twice before it can be read in the next insn.

                        mov     phsb, frqb
                        mov     frqb, phsb              ' frqb *= 3

' We now have a valid clipping mask based on the color information. Next we apply the left/right
' clipping masks which may modify the existing mask or leave it as is. dstT points to the high word
' of the destination long.

'      |scrn|.............|send|
'      |dstT|
' |dstL|dstH|                                           mask for high word required

                        cmp     dstT, scrn wz
                if_e    or      frqb, mskLH

'      |scrn|.............|send
'                         |dstT|
'                    |dstL|dstH|                        mask for high word required

                        cmp     dstT, send wz
                if_e    or      frqb, mskRH

'      |scrn|.............|send|
'                    |dstT| +2
'               |dstL|dstH|                             mask for low word required

                        add     dstT, #2
                        cmp     dstT, send wz
                if_e    or      frqb, mskRL

' dstT now points to the low word location (+2 -4)
'
'      |scrn|.............|send|
'      |dstT|
'      |dstL|dstH|                                      mask for low word required

                        sub     dstT, #4                ' rewind
                        cmp     dstT, scrn wz
                if_e    or      frqb, mskLL

' Mask is complete, filter the relevant info from src/dst and combine all pixels in the dst long.

                        test    mode, #F_INVERTCOLOR wc ' if enabled ...
                if_c    xor     srcW, vier              ' invert black/white
                        andn    srcW, frqb              ' clear transparent pixels
                        and     dstL, frqb              ' make space for src
                        or      dstL, srcW              ' combine dst/src

' Write back low/high words based on clipping info.

                        cmp     dstT, scrn wc
                if_c    jmp     #$+3
                        cmp     dstT, send wc
                if_c    wrword  dstL, dstT

                        shr     dstL, #16               ' dstL := dstH
                        add     dstT, #2                ' advance (again)

                        cmp     dstT, scrn wc
                if_c    jmp     #$+3
                        cmp     dstT, send wc
                if_c    wrword  dstL, dstT

                        djnz    index_x, #:xloop        ' for all columns
' ----- X LOOP END -------------------------------------
:skipall                add     scrn, #128/4            ' |
                        add     send, #128/4            ' |
                        add     arg2, #128/4            ' |
                        add     arg1, wb                ' advance
                        add     iter_y, #1              ' |

                        djnz    hs, #:yloop             ' for all rows
' ----- Y LOOP END -------------------------------------
                        jmp     %%0                     ' return

' support code (fetch up to 9 arguments)

args                    rdlong  arg0, addr              ' read 1st argument
                        cmpsub  addr, delta wc          ' [increment address and] check exit
                if_nc   jmpret  zero, args_ret wc,nr    ' cond: early return

                        rdlong  arg1, addr              ' read 2nd argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret wc,nr

                        rdlong  arg2, addr              ' read 3rd argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret wc,nr

                        rdlong  arg3, addr              ' read 4th argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret wc,nr

                        rdlong  arg4, addr              ' read 5th argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret wc,nr

                        rdlong  arg5, addr              ' read 6th argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret wc,nr

                        rdlong  arg6, addr              ' read 7th argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret wc,nr

                        rdlong  arg7, addr              ' read 8th argument
                        cmpsub  addr, delta wc
                if_nc   jmpret  zero, args_ret wc,nr

                        rdlong  arg8, addr              ' read 9th argument
'                       cmpsub  addr, delta wc
'               if_nc   jmpret  zero, args_ret wc,nr

args_ret                ret

' initialised data and/or presets

surface                 long    4                       ' address of composition buffer

wcnt                    long    res_x * res_y / 4 / 2   ' 4 pixels / byte
                                                        ' 2 bytes / word
clip                    long                            ' covers clipping rectangle (8 longs)

c_x1                    long    0                       ' |
c_y1                    long    0                       ' |
c_x2                    long    res_x                   ' |
c_y2                    long    res_y                   ' clipping rectangle

mskLH                   long    0                       ' |
mskLL                   long    0                       ' |
mskRH                   long    0                       ' clipping masks for pixel exactness
mskRL                   long    0                       ' (this is required by the current implementation)

delta                   long    %001_0 << 27 | $FFFC    ' %10 deal with movi setup
                                                        ' -(-4) address increment
argn                    long    |< 11                   ' function does have arguments
mode                    long    0                       ' miscellaneous flags

trns                    long    $AAAA0000               ' transparent color filler
grid                    long    $55555555               ' transparent color extraction mask

' Stuff below is re-purposed for temporary storage.

setup                   add     surface, par            ' default render buffer location

                        movi    ctrb, #%0_11111_000     ' LOGIC.always counter for math support
                        jmp     %%0                     ' return

EOD{ata}                fit

' uninitialised data and/or temporaries

                        org     setup

index_x                 res     1                       ' column counter
iter_x                  res     1                       ' destination pixel offset
iter_y                  res     1                       ' sprite y loop index (for clipping)

scrn                    res     1                       ' screen start | (visible line)
send                    res     1                       ' screen end   |

ws                      res     1                       ' sprite width
hs                      res     1                       ' sprite height
wb                      res     1                       ' sprite byte width

dstT{ransfer}           res     1                       ' current screen address
srcT{ransfer}           res     1                       ' current sprite address

dstH{igh}               res     1                       ' |
dstL{ow}                res     1                       ' current screen long
srcW{ord}               res     1                       ' current sprite word

vier                    res     1                       ' temporary register (4)


lp_x                    res     1                       ' |
lp_y                    res     1                       ' map loop indices
madv                    res     1                       ' map advance (byte width)
madr                    res     1                       ' map base address
tm_x                    res     1                       ' |
tm_y                    res     1                       ' logical tile size
tadr                    res     1                       ' tile base address

dest                    res     1                       ' destination buffer

eins                    res     1                       ' |
zwei                    res     1                       ' |
drei                    res     1                       ' temporary registers (1..3)

backup                  res     8                       ' clipping rectangle backup area


addr                    res     1                       ' parameter location
code                    res     1                       ' command entry

arg0                    res     1                       ' |
arg1                    res     1                       ' |
arg2                    res     1                       ' |
arg3                    res     1                       ' |
arg4                    res     1                       ' |
arg5                    res     1                       ' |
arg6                    res     1                       ' |
arg7                    res     1                       ' |
arg8                    res     1                       ' command arguments

tail                    fit

{screen padding}        long    -1[0 #> (512 - (@EOD - @graphicsdriver) / 4)]

CON
  zero = $1F0                                           ' par (dst only)

  res_x = 128                                           ' |
  res_y = 64                                            ' UI support

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
