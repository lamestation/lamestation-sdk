OBJ
    audio : "LameAudio"
DAT

    SFXStack    long    0[20]

    volume      long    10000
    volume_inc  long    100
    freq        long    1200
    speed       long    100
    targetspeed long    100
    
    cog         byte    0

PUB Start

    Stop
    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1,0)

    cog := cognew(SFXEngine, @SFXStack) + 1
    
PUB Stop

    if cog
        cogstop(cog)

PUB SFXEngine

    repeat
        if speed =< targetspeed
            speed := speed + 80 <# targetspeed
        elseif speed => targetspeed
            speed := speed - 40 #> targetspeed
        
        freq := 800 + speed << 1
            
        volume += freq

        audio.SetFrequency(1,freq)
        audio.SetVolume(1,(volume >> 10) // 127)        

PUB RevEngine(newspeed)

    targetspeed := newspeed << 6
    