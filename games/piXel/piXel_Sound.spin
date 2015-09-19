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
