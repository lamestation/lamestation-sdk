---
layout: learnpage
title: fn.Sleep
--- 

Wait the specified number of milliseconds before continuing.

## Syntax

    Sleep(milliseconds)

-   **milliseconds** - The amount of time to wait in milliseconds.

## Description

This command is useful for adding intentional time delays, like say
during an animated sequence or while you are waiting on a long-running
task to be completed.

## Example

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
        music.Loop
        
        fn.Sleep(2000)
        
        music.Stop
        music.Load(song2.Addr)
        music.Loop


