{{
Key Press Demo
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}


CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :   "LameAudio"
    ctrl    :   "LameControl"
    
    
OBJ
    ser : "LameSerial"
    
VAR
    byte    clicked    
    byte    note
    byte    volume
    
PUB Noise
    audio.Start
    ctrl.Start
    
    audio.SetNote(0, note := 60)
    audio.SetVolume(0, volume := 127)
        
    ser.StartRxTx(31,30,0,115200)
    
    ser.Char("B")
    
    repeat
        ctrl.Update
        
        if ctrl.A
            audio.SetEnvelope(0,0,1)
        else
            audio.SetEnvelope(0,0,0)
            
        if ctrl.Left
            if note > 40
                note--
        if ctrl.Right
            if note < 80
                note++
                
        if ctrl.Up
            if volume < 127
                volume++
        if ctrl.Down
            if volume > 0
                volume--
                
        audio.SetNote(0,note)
        audio.SetVolume(0,volume)
            
        ser.Hex(audio.GetValue1, 8)
        ser.Char(" ")
        ser.Hex(audio.GetValue2, 8)
        ser.Char(10)
        ser.Char(13)
        repeat 10000
        
        
                    
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
