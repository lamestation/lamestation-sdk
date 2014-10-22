{{
MOD ATTACK!
------------------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
------------------------------------------------------------
}}

CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : "LameAudio"
    ctrl    : "LameControl"
    
VAR
    long    volume
    long    volume_inc
    long    freq

PUB Main
    audio.Start
    ctrl.Start
    
    volume:= 10000
    volume_inc := 100
    
    audio.SetParam(0, audio#_WAV, audio#_SINE)
    audio.SetParam(1, audio#_WAV, audio#_SAW)
    audio.SetParam(2, audio#_WAV, audio#_SQUARE)
    audio.SetParam(3, audio#_WAV, audio#_SINE)
    
    audio.PlaySound(1,70)

    repeat
        ctrl.Update
        
        if ctrl.Left
            if volume_inc > 0
                volume_inc -= 1
        if ctrl.Right
            volume_inc += 1
            
        if ctrl.Up
            freq++
        if ctrl.Down
            freq--
            
        volume += volume_inc

        audio.SetFreq(1,freq)
        audio.SetVolume(1,(volume >> 10) // 127)
    
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
