'' Lame Graphics Library
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
    
    

VAR

    long    imgpointer
    long    temp
    long    temp2
    long    temp3

    long    valuetemp
    long    screencursor
    long    screencursortemp
    long    stringcursor
    long    texttemp
    
    
    long    ran
    long    frmtemp
    long    indexx
    
    
'' These longs make up the interface between Spin and
'' assembly, as well as between LameGFX and LameLCD.
'' They must apppear in this order.
'' ---------------------------------------------------
    long    instruction1
    long    instruction2
    long    outputlong
    word    sourcegrfx
    word    screen
'' ---------------------------------------------------

    word     screenpointer    




    word    text_line
    word    indexer
    word    indexstart
    word    indexend 

    word    indexh


    word    w
    word    h
    word    frameboost


    byte    oldcolorbyte
    byte    oldflipbyte
    byte    colorbyte
    byte    flipbyte
    byte    selectbyte
    byte    tempcolorbyte
    byte    tempflipbyte

    byte    value
    


PUB Start(screenvar)
'' This function initializes the library. It takes
'' no parameters and takes care of setting up the LCD
'' and frame buffer.

    cognew(@graphicsdriver, @instruction1)
    instruction1 := INST_IDLE
    instruction2 := 0   
    
    screenpointer := screenvar
    screen := screenpointer
      

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
    
    screen := word[screenpointer]
                                
    sourcegrfx := source  
    
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



PUB Static
'' This command sprays garbage data onto the framebuffer
    repeat until not lockset(SCREENLOCK)
    screen := word[screenpointer]    
    
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
    
    return source




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
    SendASMCommand(source, INST_BOX + (x << 8) + (y << 16))     
    


PUB BoxEx(source, x, y, duration)
'' This function is nearly identical to Box but allows you to display
'' a clipped version of the sprite. I created it for the sole purpose
'' of displaying a half-heart in the tank battle game.

    repeat until not lockset(SCREENLOCK)  
    screen := word[screenpointer]

    duration := duration
    temp := (x << 3) + (y << 7) 
                        
    repeat indexer from 0 to duration step 1
        word[screen][temp+indexer] := word[source][indexer]

    lockclr(SCREENLOCK)





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
''
'' Read more on img2dat to see how you can generate source images to use with this
'' drawing command.

    SendASMCommand(source, INST_SPRITE + (x << 8) + (y << 16) + (frame << 24) + (trans << 30) + (clip << 31))




PUB TextBox(teststring, boxx, boxy)
'' This function creates a text with a black background.
''
'' * **teststring** - Address of source string
'' * **boxx** - x position on screen (0-15)
'' * **boxy** - y position on screen (0-7)
''

    repeat until not lockset(SCREENLOCK)  
    screen := word[screenpointer]

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
                        add     Addr, #2
                      
                      ' deferenced pointer to screen address
                        rdword  destscrnAddr, Addr
                        

'START MAIN LOOP                       
loopytime               rdlong  instruct1full, instruct1Addr

                        mov     instruct1, instruct1full
                        and     instruct1, #255
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
       
:loop                   mov     datatemp, Addrtemp
                        wrword  zero, datatemp
                        add     Addrtemp, #2
                        djnz    valutemp, #:loop
                        jmp     #loopexit


' BLIT FULL SCREEN
' --------------------------------------------------- 
' repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
'     word[screen][imgpointer] := word[source][imgpointer]
' --------------------------------------------------- 

blitscreen1             mov     Addrtemp, destscrn
                        rdword  sourceAddrTemp, sourceAddr
                        mov     valutemp, fulscreen
                        
                        
       
:loop                   mov     datatemp, Addrtemp
           
                        rdword  datatemp2, sourceAddrTemp

                        wrword  datatemp2, datatemp
                        
                        add     Addrtemp, #2
                        add     sourceAddrTemp, #2
                        djnz    valutemp, #:loop
                        jmp     #loopexit



' BLIT SPRITE
' ---------------------------------------------------
' clip trans   frame     y        x        instr
'  -     -     ------ -------- --------  --------
'  0     0     000000 00000000 00000000  00000000   
' --------------------------------------------------- 
sprite1                 mov     Addrtemp, destscrn

                        ' get parameters from instruction1 and prepare for use
                               
                        ' clip trans   frame     y        x        instr
                        '  -     -     ------ -------- --------  --------
                        '  0     0     000000 00000000 00000000  00000000                        
                        
                        ' x position
                        mov     instruct1, instruct1full
                        and     instruct1, param1mask   ' get X position
                        shr     instruct1, #4           ' x >> 4        (x >> 8 << 4)
                        add     Addrtemp, instruct1

                        ' y position
                        mov     instruct1, instruct1full
                        and     instruct1, param2mask   ' get Y position
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


{{
  frameboost := word[source][0] 
    w := word[source][1]
    h := word[source][2]

    w := w << 3
    
    repeat temp3 from 0 to frame step 1
        source += frameboost
    source -= frameboost    
    
    x := x << 3
    temp3 := 3
    
    repeat indexh from 0 to h-1 step 1
        temp := x + ((y+indexh) << 7)
        repeat indexer from 0 to w-1 step 1
                word[screen][temp+indexer] := word[source][indexer + temp3]
        temp3 += w
}}











' BLIT BOX
' --------------------------------------------------- 
' temp := (x << 3) + (y << 7)                         
'
' repeat indexer from 0 to 7 step 1
'     word[screen][temp+indexer] := word[source][indexer]
' --------------------------------------------------- 
box1                    mov     Addrtemp, destscrn
                        rdword  sourceAddrTemp, sourceAddr
                        mov     valutemp, #8
                        
                        
                        '' (x << 3) + (y << 7)
                        '' x and y are left-shifted in the instruction register
                        '' so they need to be shifted back so the above relation
                        '' is true.
                        ''
                        '' x << 3 = x << 8 >> 5
                        '' y << 7 = y << 16 >> 9
                        ''
                        '' So it should be shifted x >> 5 and y >> 9
                        '' Then add this data to the starting address position
                        ''
                        '' Another difference though is that the original code
                        '' is word-aligned, so to get the result here, we have to
                        '' left shift all values again once, to go from word
                        '' to byte aligned
                        ''
                        '' x >> 5 << 1 = x >> 4
                        '' y >> 9 << 1 = x >> 8
                     
                        mov     instruct1, instruct1full
                        and     instruct1, param1mask   ' get X position
                        shr     instruct1, #4           ' x >> 4
                        add     Addrtemp, instruct1

                        mov     instruct1, instruct1full
                        and     instruct1, param2mask   ' get Y position
                        shr     instruct1, #8           ' y >> 8
                        add     Addrtemp, instruct1


                        '' Begin copying data       
:loop                   mov     datatemp, Addrtemp
           
                        rdword  datatemp2, sourceAddrTemp

                        wrword  datatemp2, datatemp
                        add     Addrtemp, #2
                        add     sourceAddrTemp, #2
                        djnz    valutemp, #:loop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
                        jmp     #loopexit






                        
loopexit                wrlong  destscrn, outputAddr  'change this to get data back out of assembly
                        wrlong  zero, instruct2Addr

                        jmp     #loopytime



                        
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
trueth                  long    $FF

param1mask              long    $0000FF00
param2mask              long    $00FF0000
param3mask              long    $FF000000

'sourceaddr              long    2260
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
