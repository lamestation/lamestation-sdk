{{
KS0108 Text-Drawing Library
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2011 LameStation.
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


CON

  SCREEN_W = 128
  SCREEN_H = 64
  BITSPERPIXEL = 2
  SCREEN_BH = 8
  SCREENSIZE = SCREEN_W*SCREEN_H
  SCREENSIZEB = SCREEN_W*SCREEN_BH*BITSPERPIXEL
  FRAMEFLIP = SCREENSIZEB/2

  SCREENSPACER = SCREEN_W*2


  'particularly relevant ASCII codes
  NL = 10
  SPACEBAR = 32

          
  TEXTPADDING = 2
  SPACEWIDTH = 1
  MAXCHARWIDTH = 6
  SCREENLOCK = 0
  

VAR

long    imgpointer
long    frmflip
long    temp
long    temp2
long    temp3

long    outputlong
long    frmpointer
long    destscreen




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

long    frmtemp
long    indexx

word    w
word    h
word    frameboost




PUB enableGrfx(outputpointer, screenpointer, framepointer)

  long[outputpointer] := @outputlong 

  destscreen := screenpointer
  frmpointer := framepointer
  long[frmpointer] := 1
  
  clearScreen

PUB switchFrame

repeat until not lockset(SCREENLOCK) 

if long[frmpointer] == 1
    long[frmpointer] := 0
    frmflip := FRAMEFLIP
else
    long[frmpointer] := 1
    frmflip := 0


lockclr(SCREENLOCK)     



PUB clearScreen

repeat until not lockset(SCREENLOCK)
      
repeat imgpointer from 0 to constant(SCREENSIZEB/BITSPERPIXEL-1) step 1
    word[destscreen][imgpointer+frmflip] := 0

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

'Uncomment to fill entire line with black after word.    
    {        
repeat while screencursor < SCREEN_W - (boxx << 4)
    word[temp3][screencursor] := 0
    screencursor++        
     }

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
