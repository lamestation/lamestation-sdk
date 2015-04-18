---
layout: learnpage
title: music.Start
--- 

# music.Start

Start the LameMusic song player core.

## Syntax

    Start

This command takes no arguments and returns no values.

## Description

This command must be run before any other LameMusic commands can be
used.

## Example

    OBJ
        audio   : "LameAudio"
        music   : "LameMusic"
    PUB Main
        audio.Start
        music.Start

See also: [music.Load](music.Load.html) , [music.Play](music.Play.html)
.


