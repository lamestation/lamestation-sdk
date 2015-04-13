' 05_audio/04_Volume.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

OBJ
    audio   :   "LameAudio"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"
    
VAR
    byte    volume
    
PUB Noise
    audio.Start
    ctrl.Start

    volume := 127

    audio.SetWaveform(1,2)
    audio.SetEnvelope(1,0)
    audio.SetADSR(1,127, 1, 0, 70)
    audio.SetNote(1,70)
        
    repeat
        ctrl.Update

        if ctrl.Up
            if volume < 127
                volume++
                fn.Sleep(10)
        if ctrl.Down
            if volume > 0
                volume--
                fn.Sleep(10)
                
        audio.SetVolume(1,volume)

