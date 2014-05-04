'' LameGFX Fast Drawing Library
'' ─────────────────────────────────────────────────
'' Version: 1.0
'' Copyright (c) 2013-2014 LameStation LLC
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir
'' ─────────────────────────────────────────────────
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
'' * **instruction1** - send data to assembly cog
'' * **instruction2** - receive data from cog
''
''
''

CON


    ' screensize constants
    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2
    FRAMES = 2    
    
    SCREEN_H_BYTES = SCREEN_H / 8
    SCREENSIZE = SCREEN_W*SCREEN_H
    SCREENSIZEB = SCREEN_W*SCREEN_H_BYTES*BITSPERPIXEL*FRAMES

    SCREENSIZE_BYTES = SCREEN_W * SCREEN_H_BYTES * BITSPERPIXEL
    SCREENSIZE_BYTES_END = SCREENSIZE_BYTES-1

    SCREENSPACER = SCREEN_W*2


    ' text printing
    NL = 10
    LF = 13
    TEXTPADDING = 2

    SPACEBAR = 32
    SPACEWIDTH = 1
    MAXCHARWIDTH = 6

    ' assembly interface constants
    INST_IDLE = 0
    INST_CLEARSCREEN = 1
    INST_BLITSCREEN = 2
    INST_SPRITE = 3
    INST_BOX = 4
    INST_TEXTBOX = 5
    INST_SETCLIPRECT = 6
    INST_TRANSLATE = 7



    ' locking semaphore
    SCREENLOCK = 0
    
    
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

    long    imgpointer
    long    temp3
    
    
'' These longs make up the interface between Spin and
'' assembly, as well as between LameGFX and LameLCD.
'' They must apppear in this order.
'' ---------------------------------------------------
    long    instruction1
    long    instruction2
    long    outputlong
    long    sourcegfx
    word    screen
'' ---------------------------------------------------

    word    font
    byte    startingchar
    byte    tilesize_x
    byte    tilesize_y


PUB Start(screenvar)
'' This function initializes the library. It takes
'' no parameters and takes care of setting up the LCD
'' and frame buffer.

    cognew(@graphicsdriver, @instruction1)
    instruction1 := INST_IDLE
    instruction2 := 0
    
    screen := screenvar
         

PRI SendASMCommand(source, instruction)
'' This is just a little function to allow for reuse
'' of the assembly interface code.
''
'' * **source** - The memory address of the graphics
'' * **instruction** - Instruction / parameters to send to LameGFX.
''  
'' This command maintains the lock so it is not necessary
'' to request it in your drawing function
''
    
    repeat until not lockset(SCREENLOCK)  
                                
    sourcegfx := source  
    
    instruction1 := instruction     'send instructions to cog
    instruction2 := 1               'receive reply

    repeat while instruction2 <> 0  'cog will set instruction2 to 0 when finished
    instruction1 := INST_IDLE
      
       
    lockclr(SCREENLOCK) 
   


PUB ClearScreen
'' This command clears the screen to black. Recommended if your game
'' display is sparse and not likely to be overdrawn every frame (like
'' in a tile-based game).

    SendASMCommand(0, INST_CLEARSCREEN)

'    repeat until not lockset(SCREENLOCK)
          
    'repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
    '   word[screen][imgpointer] := 0
    
'    lockclr(SCREENLOCK) 



PUB Static | ran
'' This command sprays garbage data onto the framebuffer
    repeat until not lockset(SCREENLOCK)
    
    ran := cnt
    repeat imgpointer from 0 to constant(SCREENSIZE_BYTES/2-1) step 1
         word[screen][imgpointer] := ran?
       
    lockclr(SCREENLOCK) 




PUB Blit(source)
'' This command blits a 128x64 size image to the screen. The source image
'' must not use the sprite header used in other commands. This command is
'' primarily influenced for reference on drawing to the screen, not for
'' its game utility so much.
    
    SendASMCommand(source, INST_BLITSCREEN)

'    repeat until not lockset(SCREENLOCK)               
 '     
  '  repeat imgpointer from 0 to constant(SCREENSIZE_BYTES/2-1) step 1
   '     word[screen][imgpointer] := word[source][imgpointer]
    '   
    'lockclr(SCREENLOCK) 




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
'' Here is the original Spin implementation for reference.
''
'' <pre>
'' repeat until not lockset(SCREENLOCK)
''
'' temp := (x << 3) + (y << 7)
''                       
'' repeat indexer from 0 to 7 step 1
''     word[screen][temp+indexer] := word[source][indexer] 
''
'' lockclr(SCREENLOCK)
'' </pre>
'' 
''
    SendASMCommand(source, INST_BOX + ((x & $FF) << 8) + ((y & $FF) << 16))
    
    
    
PUB DrawMap(source_tilemap, source_levelmap, offset_x, offset_y, box_x1, box_y1, box_x2, box_y2) | tile, tilecnt, tilecnttemp, x, y
'' This function uses the Box command to draw an array of tiles to the screen.
'' Used in conjunction with the map2dat program included with this kit, it is
'' an easy way to draw your first game world to the screen.
''
'' * **source_tilemap** - 
'' * **source_levelmap** -
'' * **offset_x** -
'' * **offset_y** -
'' * **width** -
'' * **height** -
''
''

    SetClipRectangle(box_x1<<3, box_y1<<3, box_x2<<3, box_y2<<3)

    tilecnt := 0
    tilecnttemp := 2
    
    repeat y from 0 to (offset_y>>3)
        tilecnttemp += byte[source_levelmap][1]
        
    repeat y from 0 to box_y2-box_y1
        repeat x from 0 to box_x2-box_x1
            tilecnt := tilecnttemp + (offset_x >> 3) + x
            tile := (byte[source_levelmap][tilecnt] & TILEBYTE) -1 
            if tile > 0
                 Box(source_tilemap + (tile << 4), (box_x1<<3) + (x << 3) - (offset_x & $7), (box_y1<<3) + (y<<3) - (offset_y & $7))

        tilecnttemp += byte[source_levelmap][0]
        
        
    SetClipRectangle(0,0,128,64)




PUB Sprite(source, x, y, frame)
'' This is the original sprite function and has been
'' largely superseded by SpriteTrans, which supports
'' transparency and frames.
''
'' * **source** - Memory address of the source image
'' * **x** - Horizontal destination position (0-15)
'' * **y** - Vertical destination position (0-7)
'' * **frame** - If the image has multiple frames, this integer will select which to use.
'' * **trans** - Turn transparency keying on/off, allowing seamless copying.
'' * **clip** (boolean) - Turn sprite clipping on/off; prevents images from drawing outside frame buffer.
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

    SendASMCommand(source, INST_SPRITE + ((x & $FF) << 8) + ((y & $FF) << 16) + (frame << 24))



PUB LoadFont(sourcevar, startingcharvar, tilesize_xvar, tilesize_yvar)
    font := sourcevar
    startingchar := startingcharvar
    tilesize_x := tilesize_xvar
    tilesize_y := tilesize_yvar

PUB PutChar(char, x, y)
    Box(font + (char - startingchar)<<4, x, y)

PUB PutString(stringvar, origin_x, origin_y) | stringcursor, char, x, y
   
    stringcursor := 0
    x := origin_x
    y := origin_y
    repeat while byte[stringvar][stringcursor] <> 0
        char := byte[stringvar][stringcursor]
        Box(font + (char - startingchar)<<4, x, y)
        x += tilesize_x
        stringcursor++



PUB TextBox(teststring, boxx, boxy) | text_line, stringcursor, screencursor, valuetemp, value, indexx
'' This function creates a text with a black background.
''
'' * **teststring** - Address of source string
'' * **boxx** - x position on screen (0-15)
'' * **boxy** - y position on screen (0-7)
''

{{{
    repeat until not lockset(SCREENLOCK)  

    text_line := (boxy << 8) + (boxx << 4)
    screencursor := 0
    stringcursor := 0 

    temp3 := screen + text_line       
    value := 1

    repeat while screencursor < constant(TEXTPADDING)
        word[temp3][screencursor] := 0
        screencursor++   

        word[temp3][screencursor] := 0
     
       
    repeat while byte[teststring][stringcursor] <> 0
        value := byte[teststring][stringcursor]

        if screencursor > constant(SCREEN_W - MAXCHARWIDTH - TEXTPADDING)
            repeat while screencursor < constant(SCREEN_W + TEXTPADDING + 1)
               word[temp3][screencursor] := 0
               screencursor++

            text_line += SCREENSPACER
            screencursor := TEXTPADDING 

        temp3 := screen + text_line

        if value == SPACEBAR
            repeat indexx from 0 to SPACEWIDTH step 1
               word[temp3][screencursor] := 0
               screencursor++


        elseif value == NL or value == LF
            repeat while screencursor < constant(SCREEN_W + TEXTPADDING + 1)
               word[temp3][screencursor] := 0
               screencursor++

            text_line += SCREENSPACER 
            screencursor := TEXTPADDING

           
        else

            value -= 32
            valuetemp := value*MAXCHARWIDTH

            screencursor++  
            indexx := 0        
            repeat while asciitable[valuetemp + indexx] <> 0
                word[temp3][screencursor] := asciitable[valuetemp + indexx]
                screencursor++
                indexx++
             
             
             
        word[temp3][screencursor] := 0
        stringcursor++     
          
           
'    repeat while screencursor < SCREEN_W - (boxx << 4)
'        word[temp3][screencursor] := 0
'        screencursor++        
         

    lockclr(SCREENLOCK)

}}



PUB SetClipRectangle(clipx1, clipy1, clipx2, clipy2)
'' Sets bounding box for tile/sprite drawing operations, to prevent overdraw.
'' Defaults to 0, 0, 128, 64.
'' Use only multiples of 8.

    SendASMCommand( (clipx1 << 24) + (clipy1 << 16) + (clipx2 << 8) + clipy2, INST_SETCLIPRECT)






PUB TranslateBuffer(sourcebuffer, destbuffer)
'' This command converts a linear framebuffer to one formatted
'' for the KS0108 LCD memory map. The destination and source
'' buffer addresses are packed into the sourcegfx long.

    SendASMCommand(sourcebuffer + (destbuffer << 16), INST_TRANSLATE)






DAT
                        org     0

graphicsdriver          mov     Addr, par

                        mov     instruct1Addr, Addr    'get first instruction long   
                        add     Addr, #4

                        mov     instruct2Addr, Addr    'get second instruction long       
                        add     Addr, #4                         

                        mov     outputAddr, Addr       'get output long              
                        add     Addr, #4
                        
                        mov     sourceAddr, Addr       'get sourceaddr long
                        add     Addr, #4
                      
                      ' deferenced pointer to screen address
'                        rdword  destscrnAddr, Addr
                        mov destscrnAddr, Addr
                        

'START MAIN LOOP                       
mainloop                rdlong  instruct1full, instruct1Addr

                        mov     instruct1, instruct1full
                        and     instruct1, #$FF
                        cmp     instruct1, #0   wz
if_z                    jmp     #loopexit


                        ' read current frame value
                        rdword  destscrn, destscrnAddr

' Decide which command to execute next
                         
                        cmp     instruct1, #1   wz      'CLEARSCREEN
if_z                    jmp     #clearscreen1
                        cmp     instruct1, #2   wz      'BLITSCREEN
if_z                    jmp     #blitscreen1
                        cmp     instruct1, #3   wz      'SPRITE
if_z                    jmp     #sprite1
                        cmp     instruct1, #4   wz      'BOX
if_z                    jmp     #box1
'                        cmp     instruct1, #5   wz      'TEXT
'if_z                    jmp     #tex
                        cmp     instruct1, #6   wz      'SET CLIP RECT
if_z                    jmp     #setcliprect1
                        cmp     instruct1, #7   wz      'TRANSLATE
if_z                    jmp     #translatebuffer1


                        jmp     #loopexit



'' instruct1 does not pass values that are big, and it's reading in a long.
'' I can use the rest of the room in the long to pass through parameters like
'' x, y, frame, duration. The screen isn't any larger than 128x64, so 256
'' should be sufficient; just need to watch for signs.
''
'' param3   param2   param1    instr/flags
''
'' 00000000 00000000 00000000   00000000




' CLEAR THE SCREEN
' --------------------------------------------------- 
' repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
'     word[screen][imgpointer] := 0

clearscreen1            mov     Addrtemp, destscrn
                        mov     valutemp, fulscreen
       
:loop                   wrword  zero, Addrtemp
                        add     Addrtemp, #2
                        djnz    valutemp, #:loop
                        jmp     #loopexit


'' #### BLIT FULL SCREEN
'' --------------------------------------------------- 
'' repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
''     word[screen][imgpointer] := word[source][imgpointer]
'' --------------------------------------------------- 

blitscreen1             mov     Addrtemp, destscrn
                        rdword  sourceAddrTemp, sourceAddr
                        mov     valutemp, fulscreen
                        
                        add     sourceAddrTemp, #6
       
:loop                   mov     datatemp, Addrtemp
           
                        rdword  datatemp2, sourceAddrTemp

                        wrword  datatemp2, datatemp
                        
                        add     Addrtemp, #2
                        add     sourceAddrTemp, #2
                        djnz    valutemp, #:loop
                        jmp     #loopexit




'' #### BLIT SPRITE
'' ---------------------------------------------------
''
'' ###### instruction1 format
''
'' <pre>
'' clip trans   frame     y        x        instr
''  -     -     ------ -------- --------  --------
''  0     0     000000 00000000 00000000  00000000   
'' </pre>

sprite1                 mov     Addrtemp, destscrn
                        rdword  sourceAddrTemp, sourceAddr
                        mov     valutemp, #8
                        
                        ' get x position of box
                        mov     x1, instruct1full
                        shl     x1, #16                 ' perform sign extend with masking
                        sar     x1, #24

                        
                        mov     iter_x, x1             ' this value rotates the word for the blender
                        shl     iter_x, #1             ' x << 1                        
                        and     iter_x, #$F            ' x % 8
                        
                        mov     datatemp, x1
                        sar     datatemp, #2            ' x / 4    ' n pixels = 2*n bits
                        adds    Addrtemp, datatemp                        

                        ' get y position of box
                        mov     y1, instruct1full
                        shl     y1, #8                  ' perform sign extend with masking
                        sar     y1, #24

                        mov     iter_y, y1             ' this value iterates from y1 to y2

                        mov     datatemp, y1
                        shl     datatemp, #5
                        adds    Addrtemp, datatemp

                        
                        'frame
                        mov     frame1, instruct1full
                        shr     frame1, #24
                        and     frame1, #$3F   ' get frame number

                        ' read header from sprite
                        rdword  sourceAddrTemp, sourceAddr                             
                        rdword  frameboost, sourceAddrTemp
                        add     sourceAddrTemp, #2 
                        

                        ' get image width and height
                        rdword  w1, sourceAddrTemp
                        add     sourceAddrTemp, #2
                        rdword  h1, sourceAddrTemp       ' only width is left-shifted because height has 8 pages only
                        add     sourceAddrTemp, #2       'get ready to start reading data
                        
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
                        
                        jmp     #loopexit







'' #### BLIT BOX
'' ---------------------------------------------------
''
'' ###### instruction1 format
''
'' <pre>
'' clip trans   frame     y        x        instr
''  -     -     ------ -------- --------  --------
''  0     0     000000 00000000 00000000  00000000   
'' </pre>

box1                    mov     Addrtemp, destscrn
                        rdword  sourceAddrTemp, sourceAddr

                        
                        ' get x position of box
                        mov     x1, instruct1full
                        shl     x1, #16                 ' perform sign extend with masking
                        sar     x1, #24
                        mov     x2, x1
                        adds    x2, #8
                        
                        mov     iter_x, x1             ' this value rotates the word for the blender
                        shl     iter_x, #1             ' x << 1                        
                        and     iter_x, #$F            ' x % 8
                        
                        mov     datatemp, x1
                        sar     datatemp, #2            ' x / 4    ' n pixels = 2*n bits
                        adds    Addrtemp, datatemp                        

                        ' get y position of box
                        mov     y1, instruct1full
                        shl     y1, #8                  ' perform sign extend with masking
                        sar     y1, #24
                        mov     y2, y1
                        adds    y2, #8
                        
                        mov     iter_y, y1             ' this value iterates from y1 to y2

                        mov     datatemp, y1
                        shl     datatemp, #5
                        adds    Addrtemp, datatemp

'' ---------------------------------------------------
                        '' Begin copying data
                        mov     valutemp, #8
:loop                   mov     datatemp, Addrtemp

                        cmps    iter_y, _clipy1             wc
if_c                    jmp     #:skipall
                        cmps    iter_y, _clipy2             wc
if_nc                   jmp     #:skipall


                        '' Read old data in display buffer
                        rdword  datatemp2, datatemp
                        add     datatemp, #2
                        rdword  blender1, datatemp
                        shl     blender1, #16
                        add     blender1, datatemp2
                        
                        
                        ' read new word
                        rdword  datatemp2, sourceAddrTemp
                        shl     datatemp2, iter_x      ' rotate source word


                        ' prepare mask for blending old and new
                        mov     blendermask, hFFFF
                        shl     blendermask, iter_x
                        
                        andn    blender1, blendermask
                        add     blender1, datatemp2


                        ' split long into two words because we don't know whether this word
                        ' falls on a long boundary, so we have to write it one at a time.
                        mov     blender2, blender1    ' copy situation

                        and     blender1, hFFFF
                        shr     blender2, #16
                        and     blender2, hFFFF
                        
                        
                        
                        
                        mov     datatemp, Addrtemp
                        ' perform sprite clipping
                        cmps    x1, _clipx1                  wc
if_c                    jmp     #:skipblender1
                        cmps    x1, _clipx2                  wc
if_nc                   jmp     #:skipblender1 
                        wrword  blender1, datatemp
:skipblender1
                        add     datatemp, #2
                        
                        cmps    x2, _clipx1                  wc
if_c                    jmp     #:skipblender2
                        cmps    x2, _clipx2                  wc
if_nc                   jmp     #:skipblender2

                        wrword  blender2, datatemp
:skipblender2

                        
:skipall                add     Addrtemp, #32               ' 16 words
                        add     sourceAddrTemp, #2
                        adds    iter_y, #1
                        djnz    valutemp, #:loop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
'' ---------------------------------------------------
                        
                        jmp     #loopexit









'' WRITE TEXT
textbox1

















'' #### SetClipRectangle
'' ---------------------------------------------------
''
'' ###### instruction1 format
''
'' <pre>
''  clipx1 clipy1  clipx2  clipy2  instr
''  ------ ------ ------- -------  ------
''  000000 000000 0000000 0000000  000000   
'' </pre>

setcliprect1            rdlong  sourceAddrTemp, sourceAddr  'use sourcegfx long since instruct1 is too small


                        mov     _clipx1, sourceAddrTemp
                        shr     _clipx1, #24
                        and     _clipx1, #$FF

                        mov     _clipy1, sourceAddrTemp
                        shr     _clipy1, #16
                        and     _clipy1, #$FF

                        mov     _clipx2, sourceAddrTemp
                        shr     _clipx2, #8
                        and     _clipx2, #$FF

                        mov     _clipy2, sourceAddrTemp
                        and     _clipy2, #$FF


                        jmp     #loopexit

'' #### TRANSLATE BUFFER
'' ---------------------------------------------------
'' clip trans   frame     y        x        instr
''  -     -     ------ -------- --------  --------
''  0     0     000000 00000000 00000000  00000000   
'' --------------------------------------------------- 
                        'get extract address words from sourcegfx long
translatebuffer1        rdlong  sourceAddrTemp, sourceAddr   
                        mov     Addrtemp, sourceAddrTemp
                        
                        
                        and     sourceAddrTemp, hFFFF
                        shr     Addrtemp, #16
                        and     Addrtemp, hFFFF


                        ' to translate the linear framebuffer, we divide the
                        ' the buffer into 16 x 8 blocks, each 8x8 pixels,
                        ' and then translate one block at a time.

                       ' Begin copying data       
' INDEX_Y LOOP -------------------------------------
                        mov     index_y, #8                 
:indexyloop             


' INDEX_X LOOP -------------------------------------
                        mov     index_x, #8
:indexxloop                 
          
                        ' srcpointer  := (index_x << 1 )+ (index_y << 8)   (y is the long axis in linear mode; 256 bytes)
                        '             := ((index_y << 7) + index_x) << 1     ' refactor to not need temp variables
                        mov     valutemp, #8
                        sub     valutemp, index_y
                        mov     valutemp2, #8
                        sub     valutemp2, index_x                        
                        
                        
                        mov     srcpointer, valutemp
                        shl     srcpointer, #6
                        add     srcpointer, valutemp2
                        shl     srcpointer, #2

                        add     srcpointer, sourceAddrTemp
                        
                        ' destpointer := (index_x << 4) + (index_y << 8)      ' x is long axis in LCD layout
                        '             := ((index_y << 4) + index_x) << 4          
                        mov     destpointer, valutemp
                        shl     destpointer, #3
                        add     destpointer, valutemp2
                        shl     destpointer, #5
                        add     destpointer, AddrTemp
                       
          

                        ' COPY FROM SRC        
                        ' repeat index1 from 0 to 31
                        '     translatematrix_dest[index1] := 0
                        
                        ' attempt at pointers; read with movs, write with movd
                        ' http://forums.parallax.com/showthread.php/116075-indirect-addressing-in-assembly
                        ' "The "0-0" is just a placeholder. By convention, that implies that the instruction field will be modified somewhere else in the code."
                        ' Apparently when addressing, you add the length and subtract the index; that way, you can use
                        ' djnz for your loop while still address from 0 onwards, instead of the other end.                        
                        
                        ' important note: all cog memory is long-addressed, so you add 1 to get
                        ' to the next long, not 4, as in the byte-addressed hub memory.
' INITDESTMATRIX LOOP -------------------------------------
                        mov     index1, #32
:initmatrixloop                                 
                        mov     datatemp, #translatematrix_dest
                        add     datatemp, #32
                        sub     datatemp, index1
                        movd    :writearray,datatemp
                        nop
:writearray             mov     0-0, #0
                        
                        
                        djnz    index1, #:initmatrixloop
' INITDESTMATRIX LOOP END -------------------------------------



' READSRCMATRIX LOOP -------------------------------------
                        mov     index1, #8
:readsrcmatrixloop      
                        mov     datatemp, #8
                        sub     datatemp, index1
                        shl     datatemp, #5           ' 16 words fit horizontally on the screen = 32 bytes
                        add     datatemp, srcpointer                                

                        rdlong  translatelong, datatemp
 
                        ' potential inverter effect                       
'                        xor     translatelong, invert

                        mov     datatemp2, #translatematrix_src
                        add     datatemp2, #8
                        sub     datatemp2, index1

                        

                        movd    :readsrcarray,datatemp2
                        nop
:readsrcarray           mov     0-0, translatelong
                        
                        djnz    index1, #:readsrcmatrixloop
' READSRCMATRIX LOOP END -------------------------------------





                        ' TRANSLATION
                        ' repeat index1 from 0 to 7
                        '   translatematrix_src[index1] := word[sourcebuffer][srcpointer + (index1 << 4)] 
                        ' 
                        '   rotate := 1
                        '   repeat index2 from 0 to 15
                        '     translatematrix_dest[index2] += ( translatematrix_src[index1] & rotate ) >> index2 << index1
                        '     rotate <<= 1
' TRANSLATE OUTER LOOP -------------------------------------
                        
                        mov     index1, #8
:translateloop_outer                        
                        mov     valutemp, #8
                        sub     valutemp, index1

                        mov     datatemp, #translatematrix_src
                        add     datatemp, #8
                        sub     datatemp, index1                        
                        movs    :readsrcarray_2, datatemp
                        nop
:readsrcarray_2         mov     translatelong, 0-0

                        mov     rotate, #1
                
' TRANSLATE INNER LOOP -------------------------------------    
                        mov     index2, #32
:translateloop_inner

                        mov     datatemp2, translatelong
                        and     datatemp2, rotate
                        
                        mov     valutemp2, #32
                        sub     valutemp2, index2
                        
                        shr     datatemp2, valutemp2
                        shl     datatemp2, valutemp
                        
                        shl     rotate, #1
      
                        mov     datatemp, #translatematrix_dest                       
                        add     datatemp, #32
                        sub     datatemp, index2
                        movd    :translatearray,datatemp
                        nop
:translatearray         add     0-0, datatemp2


                        djnz    index2, #:translateloop_inner
' TRANSLATE INNER LOOP END -------------------------------------   
                        
                        djnz    index1, #:translateloop_outer
' TRANSLATE OUTER LOOP END -------------------------------------



                        ' COPY TO DEST
                        ' repeat index1 from 0 to 15
                        '     byte[destbuffer][destpointer + index1] := translatematrix_dest[index1]
' COPYMATRIX LOOP -------------------------------------
                        mov     index1, #32
:copymatrixloop          
                        mov     datatemp, #translatematrix_dest
                        add     datatemp, #32
                        sub     datatemp, index1
                        movs    :readarray,datatemp
                        nop
:readarray              mov     datatemp2, 0-0
                        
                        mov     datatemp3, destpointer
                        add     datatemp3, #32
                        sub     datatemp3, index1
                        
                        wrbyte  datatemp2, datatemp3

                        
                        djnz    index1, #:copymatrixloop
' COPYMATRIX LOOP END -------------------------------------





                        
                        djnz    index_x, #:indexxloop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' INDEX_X LOOP END -------------------------------------                                                
                        

                        djnz    index_y, #:indexyloop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' INDEX_Y LOOP END -------------------------------------

                        jmp     #loopexit
















                        
loopexit                wrlong  destscrn, outputAddr  'change this to get data back out of assembly
                        wrlong  zero, instruct2Addr

                        jmp     #mainloop



                        
Addr                    long    0
Addrtemp                long    0
sourceAddrTemp          long    0
instruct1Addr           long    0
instruct2Addr           long    0
outputAddr              long    0      

instruct1               long    0
instruct1full           long    0
instruct2               long    0
frmpoint                long    0
destscrn                long    0
destscrnAddr            long    0

fulscreen               long    SCREENSIZE_BYTES/2  'EXTREMELY IMPORTANT TO DIVIDE BY 2; CONSTANT IS WORD-ALIGNED, NOT BYTE-ALIGNED
valutemp                long    0
valutemp2               long    0



datatemp                long    0
datatemp2               long    0
datatemp3               long    0
zero                    long    0

h0000FF00               long    $0000FF00
h00FF0000               long    $00FF0000
hFF000000               long    $FF000000

hFFFF                   long    $FFFF
hAAAA                   long    $AAAA
h5555                   long    $5555

invert                  long    %01010_1010_1010_1010_1010_1010_1010_101
'invert                  long    $FFFF_FFFF

sourceAddr              long    0
frame1                  long    0
frameboost              long    0
w1                      long    0
h1                      long    0

colorbyte1              long    0
flipbyte1               long    0
oldcolorbyte1           long    0
oldflipbyte1            long    0    
selectbyte1             long    0
bit_clipping            long    1 << 31
bit_transparent         long    1 << 30  


index1                  long    0
index2                  long    0
index_x                 long    0
index_y                 long    0
iter_x                  long    0
iter_y                  long    0
srcpointer              long    0
destpointer             long    0


_clipx1                 long    0
_clipy1                 long    0
_clipx2                 long    128
_clipy2                 long    64

blender1                long    0
blender2                long    0
blendermask             long    0
blenderoffset           long    0

translatelong           long    0
rotate                  long    0
translatematrix_src     res     8
translatematrix_dest    res     32
x1                      res     1
y1                      res     1
x2                      res     1
y2                      res     1
xtmp1                   res     1
xtmp2                   res     1



                        fit 496   





{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │
│                                                                                      │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
