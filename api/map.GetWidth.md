---
layout: learnpage
title: map.GetWidth
--- 

Return the width of the currently loaded map in tiles.

## Syntax

    GetWidth

This command takes no parameters.

Returns a 16-bit unsigned value.

## Description

## Example

    PUB Main
        ' ...
        map.Load(..., ...)
        ' ...
     
        repeat ' game loop
            ' ...
            CalculateLevelOffset(map.GetWidth, map.GetWidth)
            ' ...
            if playerx > (map.GetWidth << 3)
                PlayerWins
     
            if playery > (map.GetHeight << 3)
                PlayerDies

See also: [map.GetHeight](map.GetHeight.html) ,
[map.Load](map.Load.html) .


