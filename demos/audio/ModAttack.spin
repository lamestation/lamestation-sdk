{{
MOD ATTACK!
------------------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
------------------------------------------------------------
}}
' Watch how a makeshift mod filter can DESTROY YOUR EARS
' WITH AN EPIC BATTLE LIKE NONE YOU'VE EVER SEEN!

CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : "LameAudio"
    ctrl    : "LameControl"
    
VAR
    long    frequency
    long    frequency_inc

PUB Main
    audio.Start
    ctrl.Start
    
    frequency := 10000
    frequency_inc := 100
    
    audio.SetEnvelope(0, 0)
    audio.SetEnvelope(1, 0)
    audio.SetEnvelope(2, 0)
    audio.SetEnvelope(3, 0)
    
    audio.SetWaveform(0, audio#_SINE)
    audio.SetWaveform(1, audio#_SAW)
    audio.SetWaveform(2, audio#_SQUARE)
    audio.SetWaveform(3, audio#_SINE)

    repeat
        ctrl.Update
        
        if ctrl.Left
            frequency_inc -= 1
        if ctrl.Right
            frequency_inc += 1
            
        frequency += frequency_inc

        audio.SetFreq(0, frequency // 100000)
        audio.SetFreq(1, frequency >> 1  // 100000)
        audio.SetFreq(2, frequency // 100000)
        audio.SetFreq(3, frequency >> 2  // 100000)
    
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
