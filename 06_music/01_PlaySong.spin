' 06_music/01_PlaySong.spin
' -------------------------------------------------------
' SDK Version: 0.0.0
' Copyright (c) 2015 LameStation LLC
' See end of file for terms of use.
' -------------------------------------------------------
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000
  
OBJ
    audio   : "LameAudio"
    music   : "LameMusic"
    
    song    : "song_zeroforce"

PUB Main
    audio.Start
    music.Start
    music.Load(song.Addr)
    music.Loop

