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
    
VAR
    long    volume
    long    target
    long    volinc
    byte    decay
    byte    clicked
    byte    clickb
    byte    waveform
    byte    state
    
PUB Noise
    audio.Start
    ctrl.Start
    
    decay := 8
    state := audio#_R
    
    audio.SetNote(1, 70)
        
    repeat
        ctrl.Update

        if ctrl.Left or ctrl.Right
            if not clicked
                clicked := 1
                if ctrl.Left        
                    if decay > 0
                        decay--
                        volume ~>= 1
                if ctrl.Right
                    if decay < 10
                        volume <<= 1
                        decay++
        else
            clicked := 0
            
            
        if ctrl.A
            if state == audio#_R
                state := audio#_A
        else
            state := audio#_R
            
           
        if state == audio#_A
            target := 127 << decay
        elseif state == audio#_S
            target := 40 << decay
        elseif state == audio#_R
            target := 0
            
        if ctrl.B
            if not clickb
                clickb := 1
                waveform := (waveform + 1)//6
                audio.SetWaveform(1,waveform)
        else
            clickb := 0
      
     
        if volume < target
            volume += 10
        if volume > target
            volume -= 10
        if volume < 0
            volume := 0
        if volume => (127 << decay)
            volume := (127 << decay)
            if state == audio#_A
                state := audio#_S
                
    
                    
        audio.SetVolume(1,volume ~> decay)
                

        
        

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
