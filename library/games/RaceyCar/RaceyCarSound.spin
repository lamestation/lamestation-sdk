OBJ
    audio : "LameAudio"
    
DAT

    SFXStack    long    0[20]

    volume      long    10000
    volume_inc  long    100
    freq        long    1200
    speed       long    100
    targetspeed long    100
    
    belltimer   long    -1
    bellcount   byte    0
    
    cog         byte    0

PUB Start

    Stop
    audio.SetWaveform(1, audio#_SAW)
    audio.SetEnvelope(1,0)

    audio.SetADSR (2, 127, 40, 100, 40)
    audio.SetWaveform(2, audio#_SQUARE)
    audio.SetEnvelope(2,1)

    cog := cognew(SFXEngine, @SFXStack) + 1
    
PUB Stop

    if cog
        cogstop(cog)

PUB SFXEngine

    repeat
    
        ' engine rumble
        if speed =< targetspeed
            speed := speed + 80 <# targetspeed
        elseif speed => targetspeed
            speed := speed - 40 #> targetspeed
        
        freq := 800 + speed << 1
            
        volume += freq

        audio.SetFrequency(1,freq)
        audio.SetVolume(1,(volume >> 10) // 127)
        
        ' start  bell
        if belltimer == 0
            if bellcount < 3
                audio.PlaySound (2, 57)
                belltimer := 6000
            elseif bellcount == 3
                audio.PlaySound (2, 69)
                belltimer := 8000
            else
                belltimer := -1

            bellcount++
        elseif belltimer > 0
            belltimer--
            
            if  belltimer == 3000
                audio.StopSound (2)

                ' 40 makes good warning, 57

PUB RevEngine(newspeed)

    targetspeed := newspeed << 6

PUB Bell

    if belltimer == -1
        belltimer := 0
        bellcount := 0
        
PUB IsBellActive

    return (bellcount =< 3 and belltimer <> -1)
