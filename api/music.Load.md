---
layout: learnpage
title: music.Load
--- 

Load song data from the given address.

## Syntax

    Load(songAddr)

-   **songAddr** - A long-sized value containing the address and object
    address of a song object.

## Description

After initializing LameMusic, a song must be loaded into the music
player before it can be used.

## Example

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

See also: [Start](music.Start.html) , [music.Play](music.Play.html) ,
[music.Loop](music.Loop.html) , [music.Stop](music.Stop.html) .

Loads song data from the given address.
