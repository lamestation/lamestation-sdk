---
layout: learnpage
title: map.Load
--- 

Load a map into LameMap for drawing to the screen.

## Syntax

    Load(tilemap, level)

-   **tilemap** - The address of the tilemap to use.
-   **level** - The address of a map file.

## Description

Maps must be loaded with `        Load       ` before they can be drawn
with `        Draw       ` . Level maps can be provided by the current
file or a separate file.

Each tile in a level map is one byte, with 1 bit for collision and 7
bits for tilemap index. This means that **tilemaps are limited to 128
different tiles** per map.

`        Start       ` must be called before `        Load       ` .

## Example

Load map from DAT blocks.

    PUB Main
        ' ...
        map.Load(@gfx_data, @map_data)
        ' ...
     
    DAT
     
    map_data

    word     16, 16  'width, height
    byte    148,148,173,161,161,162,  2,248,249,221,108,108,233,223,234,108
    byte    173,161,162,  2,  2,  2,  2,  2,  2,248,249,249,221,247,220,249
    byte    149,  2,  2,  2,  2,  2, 97, 98, 98, 99,  2,  2,248,249,250,  2
    byte    186,136,  2,  2,  2, 97, 86,111,111, 85, 98, 99,  2,  2,  2,  2
    byte    173,162,  2,  2,  2,110,111,111,111,111,111,112,  2,  2,  2,  2
    byte    149,  2,  2,  2,  2,110,111,111,  3,  4,  4,  4,  4,  4,  4,  4
    byte    162,  2,  2,  2, 97, 86,  3,111,  3,  2,  2,110,111,111,112,  2
    byte      2,  2,  2,  2,  3,111,111,111,112,  2,  2,123,124,124,125,  2
    byte    224,  2,  2,  2,  3,124,  4,124,125,  2,  2,  2,  2,  2,  2,  2
    byte    233,224,  2,  2,  3,  3,  4,  2,  2,  2,  2,  2,  2,  2,222,223
    byte    247,233,224,  2,  2,  3,  4,  2,  2,  2,  2,  2,222,223,234,108
    byte    108,247,237,  2,  2,  4,  4, 99,  2,  2,142,222,234,108,220,221
    byte    108,220,250, 97, 98,  4,111,112,  2,  2,  2,235,108,108,233,234
    byte    108,237, 97, 86,111,  4,124,125,  2,  2,  2,248,221,108,108,247
    byte    220,250,110,111,111,  4,  2,222,223,223,223,223,234,108,108,108
    byte    250, 97, 86,111,  4,  2,222,234,247,108,108,108,108,108,108,108
     
     
    gfx_data

    word    16 ' frameboost
    word    8, 8 ' width, height
    ' frame 0
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    ' ...
    ' ...
    ' ...
    ' frame 129
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░
    word    $5555 ' ░░░░░░░░

Load a map with an external tilemap object called
`        TileMap.spin       ` and a map object called
`        LevelMap.spin       ` . External files must be in the same
directory as your game code file.

    OBJ
        tilemap : "TileMap"
        levelmap : "LevelMap"
     
    PUB Main
        ' ...
        map.Load(tilemap.Addr, levelmap.Addr)

See also: [map.Draw](map.Draw.html) and
[gfx.SetClipRectangle](gfx.SetClipRectangle.html) .


