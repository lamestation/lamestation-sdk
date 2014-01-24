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

    FRAMES = 2
    FRAMERATE = 10
    FRAMEPERIOD = 6000000 

    SCREEN_W = 128
    SCREEN_H = 64
    BITSPERPIXEL = 2
    SCREEN_BW = 16   
    SCREEN_BH = 8
    SCREENSIZE = SCREEN_W*SCREEN_H
    SCREENSIZEB = SCREEN_W*SCREEN_BH*BITSPERPIXEL*FRAMES

    FRAMEFLIP = SCREENSIZEB/2/FRAMES

    SCREENSPACER = SCREEN_W*2


    NL = 10
    TEXTPADDING = 2

    SPACEBAR = 32
    SPACEWIDTH = 1
    MAXCHARWIDTH = 6

    INST_IDLE = 0
    INST_CLEARSCREEN = 1
    INST_BLITSCREEN = 2
    INST_SPRITE = 3
    INST_BOX = 4
    INST_TEXTBOX = 5


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
    
    
    

OBJ

    lcd     :               "LameLCD"


VAR

'' These longs make up the interface between Spin and
'' assembly, as well as between LameGFX and LameLCD.
'' They must apppear in this order.
'' ---------------------------------------------------
    long    instruction1
    long    instruction2
    long    outputlong
    long    sourcegrfx
    long    screenframe
    long    screen[SCREENSIZEB/4]
'' ---------------------------------------------------


    long    imgpointer
    long    frmflip
    long    temp
    long    temp2
    long    temp3







    byte    value
    long    valuetemp
    long    screencursor
    long    screencursortemp
    long    stringcursor
    long    text_line
    long    texttemp

    word    indexer
    word    indexstart
    word    indexend 

    word    indexh


    byte    oldcolorbyte
    byte    oldflipbyte
    byte    colorbyte
    byte    flipbyte
    byte    selectbyte
    byte    tempcolorbyte
    byte    tempflipbyte

    long    frmtemp
    long    indexx

    word    w
    word    h
    word    frameboost




PUB Start
'' This function initializes the library. It takes
'' no parameters and takes care of setting up the LCD
'' and frame buffer.

    cognew(@graphicsdriver, @instruction1)
    instruction1 := INST_IDLE
    instruction2 := 0   
    
    screenframe := 1

    clearScreen
    
    lcd.Start(@screen)
    
    return @screen

PUB SwitchFrame
'' Lame LCD, when initialized, sets up a double-buffered drawing surface
'' to work with. It then switches back and forth between drawing to a
'' buffer and outputting the contents of that buffer to the screen.
'' This allows the screen to be redrawn at predictable intervals and
'' eliminates screen tearing.
''
'' Whenever you wish to update the screen, simply call this function and it
'' switch to the other frame. This command has no parameters.

    repeat until not lockset(SCREENLOCK) 

    if screenframe
        screenframe := 0
        frmflip := FRAMEFLIP
    else
        screenframe := 1
        frmflip := 0

    lockclr(SCREENLOCK)
    

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
                
    sourcegrfx := source
    
    instruction1 := instruction     'send instructions to cog
    instruction2 := 1               'receive reply
   
    repeat while instruction2 <> 0  'cog will set instruction2 to 0 when finished
    instruction1 := INST_IDLE
             
    lockclr(SCREENLOCK) 




PUB Blit(source)
'' This command blits a 128x64 size image to the screen. The source image
'' must not use the sprite header used in other commands. This command is
'' primarily influenced for reference on drawing to the screen, not for
'' its game utility so much.

    SendASMCommand(source, INST_BLITSCREEN)

'    repeat until not lockset(SCREENLOCK)               
      
    'repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
    '    word[@screen][imgpointer+frmflip] := word[source][imgpointer]
       
'    lockclr(SCREENLOCK) 


PUB ClearScreen
'' This command clears the screen to black. Recommended if your game
'' display is sparse and not likely to be overdrawn every frame (like
'' in a tile-based game).

    SendASMCommand(0, INST_CLEARSCREEN)

'    repeat until not lockset(SCREENLOCK)
          
    'repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
    '   word[@screen][imgpointer+frmflip] := 0
    
'    lockclr(SCREENLOCK) 




PUB Sprite(source, x, y)
'' **BROKEN - this command currently does not work**
''
'' This is the original sprite function and has been
'' largely superseded by SpriteTrans, which supports
'' transparency and frames.

    repeat until not lockset(SCREENLOCK)

    x := x << 3
    w := 16
    h := 2

    'temp := x + (y << 7)
    temp3 := 0

    repeat indexh from 0 to h-1 step 1
        temp := x + ((y+indexh) << 7)
        repeat indexer from 0 to w-1 step 1
                word[@screen][temp+indexer+frmflip] := word[source][indexer + temp3]
        temp3 += w


    lockclr(SCREENLOCK)

PUB SpriteTrans(source, x, y, frame)
'' This function allows the user to blit an arbitrarily-sized image
'' from a memory address. It is designed to accept the sprite output from img2dat,
'' and can handle multi-frame sprites, 3-color sprites, and sprites with transparency.
''
'' * **source** - Memory address of the source image
'' * **x** - Horizontal destination position (0-15)
'' * **y** - Vertical destination position (0-7)
'' * **frame** - If the image has multiple frames, this integer will select which to use
''
'' The only limitation on size is that per-pixel blitting is not yet supported, so
'' image dimensions must be in multiples of 8 to be drawn correctly, and positions
'' must be divided by 8 to fit on the screen grid.
''
'' Read more on img2dat to see how you can generate source images to use with this
'' drawing command.
''
    repeat until not lockset(SCREENLOCK)

    frameboost := word[source][0] 
    w := word[source][1]
    h := word[source][2]

    w := w << 4



    repeat temp3 from 0 to frame step 1
      source += frameboost

    source -= frameboost

    temp3 := 6  'offset from size words
    x := x << 3
    x += x

    frmtemp := w + x
    if frmtemp => SCREENSPACER
      x := SCREENSPACER - w
    elseif x < 0
      x := 0

    frmtemp := y + h
    if frmtemp => SCREEN_BH
      y := SCREEN_BH - h
    elseif y < 0
      y := 0


    frmtemp := frmflip << 1

    repeat indexh from 0 to h-1 step 1
        temp := x + ((y+indexh) << 8)
        repeat indexer from 0 to w-1 step 2
             
            oldcolorbyte := byte[@screen][temp+indexer+frmtemp]
            oldflipbyte := byte[@screen][temp+indexer+frmtemp+1]
            colorbyte := byte[source][indexer + temp3]
            flipbyte := byte[source][indexer + temp3 + 1]
            selectbyte := flipbyte
            selectbyte &= !colorbyte
                          
            oldcolorbyte &= selectbyte
            tempcolorbyte := oldcolorbyte
            colorbyte &= !selectbyte
            tempcolorbyte += colorbyte
            
            oldflipbyte &= selectbyte
            tempflipbyte := oldflipbyte
            flipbyte &= !selectbyte
            tempflipbyte += flipbyte

                           



            byte[@screen][temp+indexer+frmtemp] := tempcolorbyte
            byte[@screen][temp+indexer+frmtemp+1] := tempflipbyte

                
        temp3 += w


    lockclr(SCREENLOCK)    


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
''     word[@screen][temp+indexer+frmflip] := word[source][indexer] 
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

    duration := duration
    temp := (x << 3) + (y << 7) 
                        
    repeat indexer from 0 to duration step 1
        word[@screen][temp+indexer+frmflip] := word[source][indexer]

    lockclr(SCREENLOCK)


PUB TextBox(teststring, boxx, boxy)
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

    temp3 := @screen + text_line + frmflip<<1             
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

        temp3 := @screen + frmflip<<1 + text_line

        if value == SPACEBAR
            repeat indexx from 0 to SPACEWIDTH step 1
               word[temp3][screencursor] := 0
               screencursor++


        elseif value == NL
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
                        add     Addr, #4

                       'mov     frmpointAddr, Addr
                       ' rdlong  frmpoint, frmpointAddr 'get frame pointer long 
                        mov     frmpoint, Addr
                        add     Addr, #4
 
                       ' mov     destscrnAddr, Addr     'get @screen long
                      '  rdlong  destscrn, destscrnAddr
                        mov     destscrn, Addr     'get @screen long


'START MAIN LOOP                       
loopytime               rdlong  instruct1full, instruct1Addr

                        mov     instruct1, instruct1full
                        and     instruct1, #255
                        cmp     instruct1, #0   wz
if_z                    jmp     #loopexit




                        rdlong  frm, frmpoint
                        cmp     frm, #0         wz
if_z                    mov     frmflipcurrent, frmflip1
if_nz                   mov     frmflipcurrent, #0


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




'CLEAR THE SCREEN
'repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
 '   word[@screen][imgpointer+frmflip] := 0

clearscreen1            mov     Addrtemp, destscrn
                        mov     valutemp, fulscreen
       
:loop                   mov     datatemp, Addrtemp
                        add     datatemp, frmflipcurrent
                        wrword  zero, datatemp
                        add     Addrtemp, #2
                        djnz    valutemp, #:loop
                        jmp     #loopexit


'BLIT FULL SCREEN
'repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
 '   word[@screen][imgpointer+frmflip] := word[source][imgpointer]

blitscreen1             mov     Addrtemp, destscrn
                        rdlong  Addrtemp2, sourceAddr
                        mov     valutemp, fulscreen
       
:loop                   mov     datatemp, Addrtemp
                        add     datatemp, frmflipcurrent
           
                        rdword  datatemp2, Addrtemp2

                        wrword  datatemp2, datatemp
                        add     Addrtemp, #2
                        add     Addrtemp2, #2
                        djnz    valutemp, #:loop
                        jmp     #loopexit



sprite1







'BLIT BOX
'temp := (x << 3) + (y << 7)                         
'
'repeat indexer from 0 to 7 step 1
'    word[@screen][temp+indexer+frmflip] := word[source][indexer]

box1                    mov     Addrtemp, destscrn
                        rdlong  Addrtemp2, sourceAddr
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
                        add     datatemp, frmflipcurrent
           
                        rdword  datatemp2, Addrtemp2

                        wrword  datatemp2, datatemp
                        add     Addrtemp, #2
                        add     Addrtemp2, #2
                        djnz    valutemp, #:loop    ' djnz stops decrementing at 0, so valutemp needs to be initialized to 8, not 7.
                        jmp     #loopexit






                        
loopexit                wrlong  sourceAddr, outputAddr
                        wrlong  zero, instruct2Addr

                        jmp     #loopytime



                        
Addr                    long    0
Addrtemp                long    0
Addrtemp2               long    0
instruct1Addr           long    0
instruct2Addr           long    0
outputAddr              long    0      

instruct1               long    0
instruct1full           long    0
instruct2               long    0
frmpoint                long    0
destscrn                long    0

frm                     long    0
frmflipcurrent          long    0
frmflip1                long    FRAMEFLIP*2
fulscreen               long    SCREENSIZEB/BITSPERPIXEL/FRAMES
valutemp                long    0
datatemp                long    0
datatemp2               long    0
zero                    long    0
trueth                  long    $FF

param1mask              long    $0000FF00
param2mask              long    $00FF0000
param3mask              long    $FF000000

'sourceaddr              long    2260
sourceAddr              long    0
                      

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
