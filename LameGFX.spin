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


PUB Start(screenvar)
'' This function initializes the library. It takes
'' no parameters and takes care of setting up the LCD
'' and frame buffer.

    cognew(@graphicsdriver, @instruction1)
    instruction1 := INST_IDLE
    instruction2 := 0
    
    screen := screenvar
    
'PUB SetClipRectangle(x, y, w, h)
' Rectangles are composed of 8x8 tiles



      

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




PUB Sprite(source, x, y, frame, trans, clip) | cw, ch
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

    SendASMCommand(source, INST_SPRITE + (x << 8) + (y << 16) + (frame << 24) + (trans << 30) + (clip << 31))




PUB TextBox(teststring, boxx, boxy) | text_line, stringcursor, screencursor, valuetemp, value, indexx
'' This function creates a text with a black background.
''
'' * **teststring** - Address of source string
'' * **boxx** - x position on screen (0-15)
'' * **boxy** - y position on screen (0-7)
''

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



asciitable

'32 to 64
byte    $0, $0, $0, $0, $0, $0
byte    $2F, $0, $0, $0, $0, $0
byte    $3, $4, $3, $4, $0, $0
byte    $12, $3F, $12, $3F, $12, $0
byte    $4, $2A, $7F, $2A, $10, $0
byte    $24, $10, $8, $4, $12, $0
byte    $1A, $25, $2A, $10, $28, $0
byte    $3, $0, $0, $0, $0, $0
byte    $3E, $41, $0, $0, $0, $0
byte    $41, $3E, $0, $0, $0, $0
byte    $14, $8, $3E, $8, $14, $0
byte    $8, $8, $3E, $8, $8, $0
byte    $40, $30, $0, $0, $0, $0
byte    $8, $8, $8, $8, $8, $0
byte    $30, $30, $0, $0, $0, $0
byte    $40, $30, $8, $6, $1, $0
byte    $3E, $51, $49, $45, $3E, $0
byte    $44, $42, $7F, $40, $40, $0
byte    $42, $61, $51, $49, $46, $0
byte    $22, $41, $49, $49, $36, $0
byte    $F, $8, $8, $7F, $8, $0
byte    $4F, $49, $49, $49, $31, $0
byte    $3E, $49, $49, $49, $30, $0
byte    $1, $1, $61, $1D, $3, $0
byte    $36, $49, $49, $49, $36, $0
byte    $6, $49, $49, $49, $3E, $0
byte    $24, $0, $0, $0, $0, $0
byte    $40, $24, $0, $0, $0, $0
byte    $8, $14, $14, $22, $22, $0
byte    $14, $14, $14, $14, $0, $0
byte    $22, $22, $14, $14, $8, $0
byte    $2, $1, $51, $9, $6, $0
byte    $3E, $49, $55, $5D, $3E, $0

'ABC...
byte    $7E, $9, $9, $9, $7E, $0
byte    $7F, $49, $49, $49, $36, $0
byte    $3E, $41, $41, $41, $22, $0
byte    $7F, $41, $41, $41, $3E, $0
byte    $3E, $49, $49, $49, $41, $0
byte    $7F, $9, $9, $9, $1, $0
byte    $3E, $41, $41, $51, $32, $0
byte    $7F, $8, $8, $8, $7F, $0
byte    $41, $41, $7F, $41, $41, $0
byte    $41, $41, $41, $3F, $1, $0
byte    $7F, $8, $14, $22, $41, $0
byte    $7F, $40, $40, $40, $40, $0
byte    $7F, $1, $E, $1, $7F, $0
byte    $7F, $2, $C, $30, $7F, $0
byte    $3E, $41, $41, $41, $3E, $0
byte    $7E, $9, $9, $9, $6, $0
byte    $3E, $41, $51, $21, $5E, $0
byte    $7F, $9, $9, $9, $76, $0
byte    $6, $49, $49, $49, $30, $0
byte    $1, $1, $7F, $1, $1, $0
byte    $3F, $40, $40, $40, $3F, $0
byte    $3, $1C, $60, $1C, $3, $0
byte    $F, $70, $C, $70, $F, $0
byte    $63, $14, $8, $14, $63, $0
byte    $3, $4, $78, $4, $3, $0
byte    $61, $51, $49, $45, $43, $0

byte    $7F, $41, $0, $0, $0, $0
byte    $1, $6, $8, $30, $40, $0
byte    $41, $7F, $0, $0, $0, $0
byte    $4, $2, $1, $2, $4, $0
byte    $40, $40, $40, $40, $40, $0
byte    $2, $4, $0, $0, $0, $0

'abc...
byte    $18, $24, $24, $3C, $0, $0
byte    $3F, $24, $24, $18, $0, $0
byte    $18, $24, $24, $0, $0, $0
byte    $18, $24, $24, $3F, $0, $0
byte    $1C, $2A, $2A, $C, $0, $0
byte    $8, $3F, $9, $0, $0, $0
byte    $18, $A4, $A4, $7C, $0, $0
byte    $3F, $4, $4, $38, $0, $0
byte    $3D, $0, $0, $0, $0, $0
byte    $80, $80, $7D, $0, $0, $0
byte    $3F, $8, $14, $24, $0, $0
byte    $3F, $0, $0, $0, $0, $0
byte    $3C, $4, $38, $4, $38, $0
byte    $3C, $4, $38, $0, $0, $0
byte    $18, $24, $24, $18, $0, $0
byte    $FC, $24, $24, $18, $0, $0
byte    $18, $24, $24, $FC, $80, $0
byte    $3C, $4, $8, $0, $0, $0
byte    $24, $2A, $12, $0, $0, $0
byte    $4, $3F, $4, $0, $0, $0
byte    $1C, $20, $20, $3C, $0, $0
byte    $C, $10, $20, $10, $C, $0
byte    $1C, $20, $18, $20, $1C, $0
byte    $24, $18, $18, $24, $0, $0
byte    $4, $98, $60, $18, $4, $0
byte    $32, $2A, $2A, $26, $0, $0









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
'' --------------------------------------------------- 
sprite1                 mov     Addrtemp, destscrn

                        ' get parameters from instruction1 and prepare for use

                        ' x position
                        mov     instruct1, instruct1full
                        and     instruct1, h0000FF00   ' get X position
                        shr     instruct1, #4           ' x >> 4        (x >> 8 << 4)
                        add     Addrtemp, instruct1

                        ' y position
                        mov     instruct1, instruct1full
                        and     instruct1, h00FF0000   ' get Y position
                        shr     instruct1, #8           ' y >> 8        (y >> 16 << 8)
                        add     Addrtemp, instruct1
                        
                        'frame
                        mov     instruct1, instruct1full
                        shr     instruct1, #24
                        and     instruct1, #$3F   ' get frame number



                        ' read header from sprite
                        rdword  sourceAddrTemp, sourceAddr                             
                        rdword  frameboost1, sourceAddrTemp
                        add     sourceAddrTemp, #2 
                        

                        ' get image width                                               
                        rdword  w1, sourceAddrTemp
                        shl     w1, #3              ' left-shift by 3 for 16x8 grid, 1 because assembly is always byte-aligned
                        add     sourceAddrTemp, #2
                        
                        rdword  h1, sourceAddrTemp       ' only width is left-shifted because height has 8 pages only
                        add     sourceAddrTemp, #2       'get ready to start reading data
                                                

                        'add frameboost to sourceAddr (frame) number of times
:frameboostloop         cmp     instruct1, #0   wz
if_nz                   add     sourceAddrTemp, frameboost1
if_nz                   sub     instruct1, #1
if_nz                   jmp     #:frameboostloop



                        ' Begin copying data       
' OUTER LOOP --------------------------------------
                        mov     valutemp2, h1 
:outerloop              mov     datatemp, Addrtemp


' INNER LOOP --------------------------------------                        
                        mov     valutemp, w1
:innerloop                                      
                        ' the copy operation           
                        rdword  datatemp2, sourceAddrTemp
                        
                        
                        
                        
                        ' check if transparency enabled
                        ' if not, skip this block
                        cmp     instruct1full, bit_transparent   wz      
if_z                    jmp     #:skiptransparency
                        
                        ' ---- TRANSPARENCY ----
                        mov colorbyte1, datatemp2
                        and colorbyte1, #$FF
                        
                        mov flipbyte1, datatemp2
                        shr flipbyte1, #8
                        
                        
                        ' get bytes from destination
                        rdword  datatemp2, datatemp
                        
                        mov oldcolorbyte1, datatemp2
                        and oldcolorbyte1, #$FF
                        
                        mov oldflipbyte1, datatemp2
                        shr oldflipbyte1, #8
                        
                        
                        
                        
                        mov selectbyte1, flipbyte1
                        andn selectbyte1, colorbyte1
                        
                        and oldcolorbyte1, selectbyte1
                        andn colorbyte1, selectbyte1
                        add oldcolorbyte1, colorbyte1
                        
                        and oldflipbyte1, selectbyte1
                        andn flipbyte1, selectbyte1
                        add oldflipbyte1, flipbyte1
                        
       
                        mov datatemp2, oldflipbyte1
                        shl datatemp2, #8
                        add datatemp2, oldcolorbyte1
                                          
                        
                        
:skiptransparency       ' ---- TRANSPARENCY END ----       
                        
                        
                        wrword  datatemp2, datatemp
                        
                        
                        add     datatemp, #2
                        add     sourceAddrTemp, #2
                        
                        djnz    valutemp, #:innerloop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' INNER LOOP END ----------------------------------                                                
                        add     Addrtemp, #$100           ' add width of screen in bytes
                        

                        djnz    valutemp2, #:outerloop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
' OUTER LOOP END ----------------------------------

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
' --------------------------------------------------- 
' temp := (x << 3) + (y << 7)                         
'
' repeat indexer from 0 to 7 step 1
'     word[screen][temp+indexer] := word[source][indexer]
' --------------------------------------------------- 
box1                    mov     Addrtemp, destscrn
                        rdword  sourceAddrTemp, sourceAddr
                        mov     valutemp, #8
                        
                        '' (x << 1) + (y << 5)
                        '' x and y are left-shifted in the instruction register
                        '' so they need to be shifted back so the above relation
                        '' is true.
                        ''
                        '' Another difference though is that the original code
                        '' is word-aligned, so to get the result here, we have to
                        '' left shift all values again once, to go from word
                        '' to byte aligned
                        ''
                        '' x << 1 = x << 8 >> 7
                        '' y << 5 = y << 16 >> 11
                        ''
                        '' So it should be shifted x >> 7 and y >> 11
                        '' Then add this data to the starting address position
                        ''
                        
                        ' get x position of box
                        mov     x1, instruct1full
                        shl     x1, #16                 ' perform sign extend with masking
                        sar     x1, #24
                        mov     x2, x1
                        adds    x2, #8
                        
                        mov     index_x, x1             ' this value rotates the word for the blender
                        shl     index_x, #1             ' x << 1                        
                        and     index_x, #$F            ' x % 8
                        
                        mov     datatemp, x1
                        sar     datatemp, #2            ' x / 4    ' n pixels = 2*n bits
                        adds    Addrtemp, datatemp                        

                        ' get x position of box
                        mov     y1, instruct1full
                        shl     y1, #8                  ' perform sign extend with masking
                        sar     y1, #24
                        mov     y2, y1
                        adds    y2, #8
                        
                        mov     index_y, y1             ' this value iterates from y1 to y2

                        mov     datatemp, y1
                        shl     datatemp, #5
                        adds    Addrtemp, datatemp

'' ---------------------------------------------------
                        '' Begin copying data
:loop                   mov     datatemp, Addrtemp

                        cmps    index_y, _clipy1             wc
if_c                    jmp     #:skipall
                        cmps    index_y, _clipy2             wc
if_nc                   jmp     #:skipall


                        '' Read old data in display buffer
                        rdword  datatemp2, datatemp
                        add     datatemp, #2
                        rdword  blender1, datatemp
                        shl     blender1, #16
                        add     blender1, datatemp2
                        
                        
                        ' read new word
                        rdword  datatemp2, sourceAddrTemp
                        shl     datatemp2, index_x      ' rotate source word


                        ' prepare mask for blending old and new
                        mov     blendermask, hFFFF
                        shl     blendermask, index_x
                        
                        andn    blender1, blendermask
                        add     blender1, datatemp2


                        ' split long into two words because we don't know whether this word
                        ' falls on a long boundary, so we have to write it one at a time.
                        mov     blender2, blender1    ' copy situation

                        and     blender1, hFFFF
                        shr     blender2, #16
                        and     blender2, hFFFF
                        
                        
                        
                        
                        mov     datatemp, Addrtemp

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
                        adds    index_y, #1
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

sourceAddr              long    0
frameboost1             long    0
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
srcpointer              long    0
destpointer             long    0


_clipx1                 long    0
_clipy1                 long    0
_clipx2                 long    128
_clipy2                 long    64

blender1                long    0
blender2                long    0
blendermask

translatelong           long    0
rotate                  long    0
translatematrix_src     res     8
translatematrix_dest    res     32
x1                      res     1
y1                      res     1
x2                      res     1
y2                      res     1



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
