{{
KS0107/08 Monochrome LCD Framebuffer Driver
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2011 LameStation.
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}

'' The pins of importance on this particular controller are as follows

'' D/I - 0 - Decides whether command is data or instruction
'' R/W -> GND
'' EN - 1 -  Sends command
'' DB[2-9] - Data
'' CS[10-11] - Active high chip enable

CON
  ''These indicate which pins connect to what.
  LCDstart = 0, LCDend = 11

  DI = LCDstart + 0
  EN = LCDstart + 1
  DBstart = LCDstart + 2
  DBend = LCDstart + 9
  CSA = LCDstart + 10
  CSB = LCDstart + 11

  FRAMERATE = 300
  SYNCLOCK = 1


  SCREEN_W = 128
  SCREEN_H = 64
  SCREEN_BH = 8
  SCREENSIZE = SCREEN_W*SCREEN_H  
  SCREENSIZEB = SCREEN_W*SCREEN_BH
  BITSPERPIXEL = 2

PUB start(screenPointer)
    cognew(@lcd_entry, screenPointer)

DAT
                        org

                        'get screen and dirrrr addresses        
lcd_entry               mov     dira, diravalue
                        mov     screenAddr, par
                        mov     frameAddr, screenAddr
                        sub     frameAddr, #4                 

                        mov     LCD_time, cnt
                        add     LCD_time, LCD_frameperiod


'SET UP LCD SCREEN
                        mov     datatemp, LCD_displayon   'turn on LCD
                        call    #sendLCDcommand

                        'set page to value 0
                        mov     datatemp, #0
                        add     datatemp, LCD_setPage     
                        add     datatemp, LCD_CE_B
                        call    #sendLCDcommand
                        
                        'set address to value 0
                        mov     datatemp, #0
                        add     datatemp, LCD_setAddress  
                        add     datatemp, LCD_CE_B
                        call    #sendLCDcommand


                        'set page to value 0
                        mov     datatemp, #0
                        add     datatemp, LCD_setPage     
                        add     datatemp, LCD_CE_B
                        call    #sendLCDcommand
                        
                        'set address to value 0
                        mov     datatemp, #0
                        add     datatemp, LCD_setAddress  
                        add     datatemp, LCD_CE_B
                        call    #sendLCDcommand


                        'initializes counters and shizz
                        mov     pagecnt, #0
                        mov     addrcnt, #0
                        mov     screenindex, #0
                        mov     cselect, LCD_CE_L


'BEGIN SCREEN DRAWING LOOP ------------------------------
restartloop             mov     addrcnt, #64

                        rdlong  frame, frameAddr


'DRAW STUFF LOOK ---------------------------------------     
            
drawscreen              mov     Addrtemp, screenAddr
                        cmp     frame, #0       wz
if_nz                   add     Addrtemp, one24
   
                        add     Addrtemp, screenindex 'inc screen index after using
                        add     screenindex, #2

                        rdword  datatemp, Addrtemp
                        mov     datatemp2, datatemp
                        and     datatemp, #$FF
                        shr     datatemp2, #8

                        cmp     screenflags, #1         wz
if_nz                   andn    datatemp, datatemp2
              
drawbyte                shl     datatemp, LCD_DBstart  
                        add     datatemp, cselect
                        add     datatemp, LCD_writeByte
                        call    #sendLCDcommand

                        djnz    addrcnt, #drawscreen

'ADDRCNT OVER ---------------------------------------     

addrcnt_over            mov     addrcnt, #0

                        cmp     cselect, LCD_CE_L      wz
if_z                    mov     cselect, LCD_CE_R
if_z                    jmp    #skippageover
if_nz                   mov     cselect, LCD_CE_L 

                
if_nz                   add     pagecnt, #1
if_nz                   cmp     pagecnt, #8     wc
if_nz_and_c             jmp    #skippageover          


'PAGECNT OVER ---------------------------------------       

pagecnt_over            mov     pagecnt, #0
                        mov     screenindex, #0

if_nz                   mov     LCD_time, cnt
if_nz                   add     LCD_time, LCD_frameperiod
if_nz                   waitcnt LCD_time, LCD_frameperiod

if_nz                   cmp     screenflags, #1         wc
if_nz_and_c             mov     screenflags, #1
if_nz_and_nc            mov     screenflags, #0    


'FINAL COMMAND --------------------------------------- 
skippageover

if_nz                   mov     datatemp, pagecnt
if_nz                   shl     datatemp, LCD_DBstart  
if_nz                   add     datatemp, LCD_setPage     
if_nz                   add     datatemp, LCD_CE_B

if_nz                   call    #sendLCDcommand

                        jmp     #restartloop







sendLCDcommand          or      datatemp, LCD_enable 
                        mov     outa, datatemp

                        mov     LCD_bytetime, cnt
                        add     LCD_bytetime, LCD_byteperiod
                        waitcnt LCD_bytetime, LCD_byteperiod
                        
                        andn    datatemp, LCD_enable
                        mov     outa, datatemp

                        mov     LCD_bytetime, cnt
                        add     LCD_bytetime, LCD_byteperiod
                        waitcnt LCD_bytetime, LCD_byteperiod

sendLCDcommand_ret      ret




allon                   long    $FFFFFFFF
diravalue               long    (((1 << (LCDend+1))-1)-((1 << LCDstart)-1))
datatemp                long    0        'stores data for intermediate calculations
datatemp2               long    0

Addr                    long    0
screenAddr              long    0
frameAddr               long    0
Addrtemp                long    0

'complete commands
LCD_time                long    0
LCD_frameperiod         long    (80000000/FRAMERATE)
LCD_bytetime            long    0
LCD_byteperiod          long    220


LCD_displayon           long    (3 << CSA + 63 << DBstart)        'complete commands   both screens
LCD_displayoff          long    (3 << CSA + 62 << DBstart)

LCD_DBstart             long    DBstart
LCD_setAddress          long    (64 << DBstart) ' + 0-63        'needs chip select
LCD_setPage             long    (184 << DBstart) ' + 0-7
LCD_writeByte           long    (1 << DI)
LCD_CE_L                long    (1 << CSA)
LCD_CE_R                long    (1 << CSB)
LCD_CE_B                long    (3 << CSA)
LCD_enable              long    (1 << EN)          'already shifted     

LCD_pageToZero          long    (LCD_setPage + LCD_CE_B)
LCD_addressToZero       long    (LCD_setAddress + LCD_CE_B)
one24                   long    1024*BITSPERPIXEL

screenflags             long    1

pagecnt                 long    0
addrcnt                 long    0
screenindex             long    0
cselect                 long    0
frame                   long    0

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
