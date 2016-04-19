OBJ
    audio   :   "LameAudio"
    fn      :   "LameFunctions"
    
DAT
    SFXStack    long    0[20]
    
    SFXplay     byte    0[4]
    SFXstop     byte    0[4]
    
CON
    #1, _LASER, _BOOM, _JUMP
    
PUB Start
    cognew(SFXEngine, @SFXStack)
    
PUB RunSound(channel, sound)

    SFXstop.byte[channel] := 1
    repeat until not SFXstop.byte[channel]
    SFXplay.byte[channel] := sound
    
PRI SFXEngine | channel
    repeat
        repeat channel from 0 to 3
            case SFXplay.byte[channel]
                _LASER: Laser(channel)
                _BOOM:  Boom(channel)
                _JUMP:  Jump(channel)
               
            SFXstop.byte[channel] := 0
            SFXplay.byte[channel] := 0

PRI Laser(channel) | freq
    
    audio.SetWaveform(channel, audio#_TRIANGLE)   
    audio.SetEnvelope(channel, 0)
    
    freq := 40000
    audio.SetVolume(channel,127)
    repeat while freq > 2000
        if SFXstop.byte[channel]
            audio.SetVolume(channel,0)
            SFXplay.byte[channel] := 0
            SFXstop.byte[channel] := 0
            return
        audio.SetFrequency(channel,freq)
        freq -= 30
    
    audio.SetVolume(channel,0)
    
PRI Boom(channel)
    audio.SetWaveform(channel, audio#_NOISE)
    audio.SetEnvelope(channel, 1)
    audio.SetADSR(channel, 127,10, 0, 10)
    audio.PlaySound(channel, 60)
    fn.Sleep(100)
    audio.StopSound(channel)
    fn.Sleep(50)

PRI Jump(channel) | freq
    
    audio.SetWaveform(channel, audio#_SINE)   
    audio.SetEnvelope(channel, 0)
    
    freq := 6000
    audio.SetVolume(channel,127)
    repeat while freq < 30000
        if SFXstop.byte[channel]
            audio.SetVolume(channel,0)
            SFXplay.byte[channel] := 0
            SFXstop.byte[channel] := 0
            return
        audio.SetFrequency(channel,freq)
        freq += 5
    
    audio.SetVolume(channel,0)
