---
layout: learnpage
title: music.Loop
--- 

Play the currently loaded song forever.

## Syntax

    Loop

This command takes no arguments and returns no result.

## Description

LameMusic can play songs either once or forever using
[music.Play](music.Play.html) or Loop.

This command cannot be used until the LameMusic player has started with
[music.Start](music.Start.html) and a song has been loaded with
[music.Load](music.Load.html) .

## Example

    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"
        
        song    : "song_zeroforce"
    PUB Main
        audio.Start
        music.Start
        music.Load(song.Addr)
        music.Loop

See also: [music.Play](music.Play.html) , [music.Stop](music.Stop.html)
, [music.IsPlaying](music.IsPlaying.html) .


