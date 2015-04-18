---
layout: learnpage
title: music.IsPlaying
--- 

Return whether a song is currently playing.

## Syntax

    IsPlaying

This command takes no arguments. It returns 1 if a song is playing, and
0 otherwise.

## Description

Sometimes it's helpful to determine the state of the song, so that you
can avoid interrupting an already playing song or wait until a song has
finished to perform some other action.

## Example

    CON
        _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000
     
    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"
        fn      : "LameFunctions"
        song    : "song_pixeltheme"
        song2   : "song_lastboss"

    PUB Play
        audio.Start
        music.Start
        
        music.Load(song.Addr)
        music.Play
        
        repeat until not music.IsPlaying
        
        music.Load(song2.Addr)
        music.Play

See also: [music.Play](music.Play.html) , [music.Loop](music.Loop.html)
, [Stop](music.Stop.html) .


