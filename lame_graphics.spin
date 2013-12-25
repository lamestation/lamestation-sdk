{{
KS0108 Graphics Library
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


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

OBJ

        lcd     :               "lame_lcd"


VAR
long    screenframe
long    screen[SCREENSIZEB/4]

long    imgpointer
long    frmflip
long    temp
long    temp2
long    temp3

long    instruction1
long    instruction2
long    outputlong
long    frmpointer
long    destscreen
long    sourcegrfx




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




PUB enableGrfx(outputpointer)

  cognew(@graphicsdriver, @instruction1)
  instruction1 := INST_IDLE
  instruction2 := 0   

  destscreen := @screen
  frmpointer := @screenframe
  long[frmpointer] := 1

  clearScreen
  
  lcd.start(@screen)
  
  return @outputlong

{{
PUB getScreen(screenpointer, framepointer)
    destscreen := screenpointer
    frmpointer := framepointer
    long[frmpointer] := 1
}}

PUB switchFrame

repeat until not lockset(SCREENLOCK) 

if long[frmpointer] == 1 
    long[frmpointer] := 0
    frmflip := FRAMEFLIP
else
    long[frmpointer] := 1
    frmflip := 0

lockclr(SCREENLOCK)     


PUB blit(source)

repeat until not lockset(SCREENLOCK)  
            
sourcegrfx := source        
instruction2 := 1 
instruction1 := INST_BLITSCREEN     

repeat while instruction2 <> 0
instruction1 := INST_IDLE
         
  {
repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
    word[destscreen][imgpointer+frmflip] := word[source][imgpointer]
   }
lockclr(SCREENLOCK) 


PUB clearScreen

repeat until not lockset(SCREENLOCK)
      
instruction2 := 1  
instruction1 := INST_CLEARSCREEN 
       

repeat while instruction2 <> 0
instruction1 := INST_IDLE

lockclr(SCREENLOCK) 

'repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
'   word[destscreen][imgpointer+frmflip] := 0


PUB sprite(source, x, y)

repeat until not lockset(SCREENLOCK)

x := x << 3
w := 16
h := 2

'temp := x + (y << 7)
temp3 := 0

repeat indexh from 0 to h-1 step 1
    temp := x + ((y+indexh) << 7)
    repeat indexer from 0 to w-1 step 1
            word[destscreen][temp+indexer+frmflip] := word[source][indexer + temp3]
    temp3 += w


lockclr(SCREENLOCK)

PUB sprite_trans(source, x, y, frame)

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
         
            oldcolorbyte := byte[destscreen][temp+indexer+frmtemp]
            oldflipbyte := byte[destscreen][temp+indexer+frmtemp+1]
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

                           



            byte[destscreen][temp+indexer+frmtemp] := tempcolorbyte
            byte[destscreen][temp+indexer+frmtemp+1] := tempflipbyte

            
    temp3 += w


lockclr(SCREENLOCK)    
    

PUB box(source, x, y)

repeat until not lockset(SCREENLOCK)  
         
temp := (x << 3) + (y << 7) 
                    
repeat indexer from 0 to 7 step 1
    word[destscreen][temp+indexer+frmflip] := word[source][indexer]

lockclr(SCREENLOCK)


PUB box_ex(source, x, y, duration)

repeat until not lockset(SCREENLOCK)  

duration := duration
temp := (x << 3) + (y << 7) 
                    
repeat indexer from 0 to duration step 1
    word[destscreen][temp+indexer+frmflip] := word[source][indexer]

lockclr(SCREENLOCK)


PUB textbox(teststring, boxx, boxy)

repeat until not lockset(SCREENLOCK)  

text_line := (boxy << 8) + (boxx << 4)
screencursor := 0
stringcursor := 0 

temp3 := destscreen + text_line + frmflip<<1             
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

    temp3 := destscreen + frmflip<<1 + text_line

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
      
       
repeat while screencursor < SCREEN_W - (boxx << 4)
    word[temp3][screencursor] := 0
    screencursor++        
     

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
                        org

graphicsdriver          mov     Addr, par

                        mov     instruct1Addr, Addr    'get first instruction long   
                        add     Addr, #4

                        mov     instruct2Addr, Addr    'get second instruction long       
                        add     Addr, #4                         

                        mov     outputAddr, Addr       'get output long              
                        add     Addr, #4

                        mov     frmpointAddr, Addr
                        rdlong  frmpoint, frmpointAddr 'get frame pointer long 
                        add     Addr, #4
 
                        mov     destscrnAddr, Addr     'get destscreen long
                        rdlong  destscrn, destscrnAddr
                        add     Addr, #4

                        mov     sourceAddr, Addr       'get sourceaddr long

'START MAIN LOOP                       
loopytime               rdlong  instruct1, instruct1Addr

                        cmp     instruct1, #0   wz
if_z                    jmp     #loopexit




                        rdlong  frm, frmpoint
                        cmp     frm, #0         wz
if_z                    mov     frmflipcurrent, frmflip1
if_nz                   mov     frmflipcurrent, #0

                         
                        cmp     instruct1, #1   wz      'CLEARSCREEN
if_z                    jmp     #clearscreen1
                        cmp     instruct1, #2   wz      'BLITSCREEN
if_z                    jmp     #blitscreen1
                        cmp     instruct1, #3   wz      'SPRITE
if_z                    jmp     #sprite1
                        cmp     instruct1, #4   wz      'BOX
if_z                    jmp     #box1





'CLEAR THE SCREEN
'repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
 '   word[destscreen][imgpointer+frmflip] := 0

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
 '   word[destscreen][imgpointer+frmflip] := word[source][imgpointer]

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



box1

                        
loopexit                wrlong  sourceAddr, outputAddr
                        wrlong  zero, instruct2Addr

                        jmp     #loopytime



                        
Addr                    long    0
Addrtemp                long    0
Addrtemp2               long    0
instruct1Addr           long    0
instruct2Addr           long    0
outputAddr              long    0      
frmpointAddr            long    0
destscrnAddr            long    0

instruct1               long    0
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
