{{
Wild Tone
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
    fn      : "LameFunctions"
    
VAR
    long    note

PUB Main
    audio.Start
    ctrl.Start
    
    note := 24
    
    audio.SetEnvelope(0,0)
    audio.SetEnvelope(1,0)
    audio.SetEnvelope(2,0)
    audio.SetEnvelope(3,0)
    
    audio.SetWaveform(0, audio#_SQUARE)
    audio.SetWaveform(1, audio#_SAW)
    audio.SetWaveform(2, audio#_SINE)
    audio.SetWaveform(3, audio#_SINE)
    
    repeat
        ctrl.Update
        
        if ctrl.Left
            if note > 0
                note--
        if ctrl.Right
            if note < 150
                note++

        audio.SetNote(0, note)
        audio.SetNote(1, note - 12)
        audio.SetFreq(2, note << 10)
        audio.SetFreq(3, note >> 2)
        
        fn.Sleep(5)
    
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
