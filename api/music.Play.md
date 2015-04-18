---
layout: learnpage
title: music.Play
--- 

# music.Play

Play the currently loaded song only once.

## Syntax

    Play

This command takes no arguments and returns no result.

## Description

LameMusic can either Play or [music.Loop](music.Loop.html) a song, based
on the command used.

This command cannot be used until the LameMusic player has started with
[Start](https://lamestation.atlassian.net/wiki/display/MUSIC/Start) and
a song has been loaded with
[Load](https://lamestation.atlassian.net/wiki/display/MUSIC/Load) .

## Example

    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"
        
        song    : "song_zeroforce"

    PUB Main
        audio.Start
        music.Start
        music.Load(song.Addr)
        music.Play

See also: [music.Loop](music.Loop.html) , [music.Stop](music.Stop.html)
, [music.IsPlaying](music.IsPlaying.html) .


