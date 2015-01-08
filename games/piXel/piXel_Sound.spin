OBJ
    audio   :   "LameAudio"
    fn      :   "LameFunctions"
    
DAT
    SFXStack    long    0[20]
    
    SFXplay     byte    0
    SFXstop     byte    0
    
CON
    #1, _LASER, _BOOM
    
PUB Start
    cognew(SFXEngine, @SFXStack)
    
PUB RunSound(sound)

    SFXstop := 1
    repeat until not SFXstop
    SFXplay := sound
    
PRI SFXEngine
    repeat
        case SFXplay
            _LASER: Laser(2)
            _BOOM:  Boom(3)
               
        SFXstop := 0
        
PRI Laser(channel) | freq
    
    audio.SetWaveform(channel, audio#_TRIANGLE)   
    audio.SetEnvelope(channel, 0)
    
    freq := 40000
    audio.SetVolume(channel,127)
    repeat while freq > 2000
        if SFXstop
            audio.SetVolume(channel,0)
            SFXplay := 0
            SFXstop := 0
            return
        audio.SetFreq(channel,freq)
        freq -= 30
    
    audio.SetVolume(channel,0)
    SFXplay := 0
    SFXstop := 0
    
PRI Boom(channel)
    audio.SetWaveform(channel, audio#_NOISE)
    audio.SetEnvelope(channel, 1)
    audio.SetADSR(channel, 127,120, 0, 120)
    audio.PlaySound(channel, 60)
    fn.Sleep(100)
    audio.StopSound(channel)
    fn.Sleep(50)
    
    SFXplay := 0
    SFXstop := 0
    
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
