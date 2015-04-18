---
layout: learnpage
title: music.Stop
--- 

# music.Stop

Stop the currently playing song.

## Syntax

    Stop

This command takes no arguments and returns no parameters.

## Description

This song will immediately stop whatever song is playing.

## Example

    CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000
      
    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"
        fn      : "LameFunctions"
        song    : "song_pixeltheme"

    PUB Play
        audio.Start
        music.Start
        
        music.Load(song.Addr)
        music.Loop
        
        fn.Sleep(2000)
        
        music.Stop

See also: [music.Play](music.Play.html) , [music.Loop](music.Loop.html)
, [music.IsPlaying](music.IsPlaying.html) .


