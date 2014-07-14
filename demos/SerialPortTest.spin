'' Serial Port Test
'' -------------------------------------------------
'' Version: 1.0
'' Copyright (c) 2014 LameStation LLC.
'' See end of file for terms of use.
'' 
'' Authors: Brett Weir
'' -------------------------------------------------
''
'' This tutorial demonstrates that the Propeller itself is
'' alive by blinking a connected LED
''


'' It verifies that the crystal oscillator is working too
''

CON
  _clkmode        = xtal1 + pll16x           ' Feedback and PLL multiplier
  _xinfreq        = 5_000_000                ' External oscillator = 5 MHz

 '   RX_PIN = 23
  '  TX_PIN = 22

    RX_PIN = 31
    TX_PIN = 30
    
    TXT_SIZE = 150
    TXT_SIZE_END = TXT_SIZE-1

OBJ
    ser :   "LameSerial"
    gfx :   "LameGFX"
    lcd :   "LameLCD"

VAR
    word    x
    word    y
    byte    thingy[TXT_SIZE]

PUB SerialPortTest

    lcd.Start(gfx.Start)
    
 '   ser.StartRxTx(RX_PIN, TX_PIN, 0, 115200)
    ser.StartRxTx(RX_PIN, TX_PIN, 0, 38400)    
    repeat
        gfx.ClearScreen(0)
        
        {
        if ser.RxCount
            thingy[x] := ser.CharIn
            if thingy[x] == gfx#LF or thingy[x] == gfx#NL
                ser.Char(gfx#NL)
                ser.Char(gfx#LF)
            else                
                ser.Char(thingy[x])
            x++
            if x > TXT_SIZE_END-1
                repeat x from 0 to TXT_SIZE_END-1
                    thingy[x] := 0
                x := 0


        gfx.TextBox(string("Receiving..."),0,0)
        gfx.TextBox(@thingy, 0,1)
               }
             
                 
         
        gfx.TextBox(string("Transmitting..."),0,0)
        repeat y from 0 to 25
            repeat x from 0 to 50
                ser.Char("a")
        
            ser.Char(ser#NL)
            ser.Char(ser#LF)

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