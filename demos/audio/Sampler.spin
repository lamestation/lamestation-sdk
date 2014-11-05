{{
Sampler
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
' This demo shows how to use the built-in sampler
' as well as a simple chord playback.

CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :   "LameAudio"
    fn      :   "LameFunctions"
    sample  :   "ins_hammond"

PUB Main
    audio.Start
    audio.SetSample(sample.Addr)
    audio.SetWaveform(0, audio#_SAMPLE)
    audio.SetWaveform(1, audio#_SAMPLE)
    audio.SetWaveform(2, audio#_SAMPLE)
    audio.SetWaveform(3, audio#_SAMPLE)
    
    audio.PlaySound(0,50)
    fn.Sleep(1000)
    audio.PlaySound(1,54)
    fn.Sleep(1000)
    audio.PlaySound(2,57)
    fn.Sleep(1000)
    audio.PlaySound(3,62)
    fn.Sleep(2000)
    audio.StopAllSound
    
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
