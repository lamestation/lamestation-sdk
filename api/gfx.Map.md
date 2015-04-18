---
layout: learnpage
title: gfx.Map
--- 

Draw a tile-based level map at the specified coordinates.

## Syntax

    Map(tilemap, levelmap, offset_x, offset_y, x1, y1, x2, y2)

-   **tilemap** - Address of the tilemap to copy tiles from.
-   **levelmap** - Address of the map to draw to the screen.
-   **offset\_x** , **offset\_y** - The offset origin to draw the map
    from.
-   **x1** **, y1** - The top-left corner of the map window.
-   **x2,** **y2** - The bottom-right corner of the map window.

## Description

This function forms the basis for [LameMap](LameMap.html) , which
offers expanded tile-based map capabilities including built-in collision
detection.

This function is identical to
[map.DrawRectangle](map.DrawRectangle.html) except that the tile and map
addresses are passed inline instead of loaded in advance with
[map.Load](map.Load.html) .

## Example

See Brettris.spin and Helicopter.spin for examples of gfx.Map in action.

See also: [map.Draw](map.Draw.html) ,
[map.DrawRectangle](map.DrawRectangle.html) .


