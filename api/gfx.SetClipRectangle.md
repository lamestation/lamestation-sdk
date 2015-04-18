---
layout: learnpage
title: gfx.SetClipRectangle
--- 

Change the portion of the screen that will be drawn to by LameGFX.

## Syntax

    SetClipRectangle(x1, y1, x2, y2)

-   **x1** , **y1** - Top-left corner of the desired clip rectangle.
-   **x2** , **y2** - Bottom-right corner of the clip rectangle.

## Description

All drawing operations are bound by this clip rectangle. The maximize
size of the clip rectangle is (0,0,128,64). Larger or off-screen size
values will be automatically restricted to this region.

Point 2 must right to the right and down of point 1. Otherwise the clip
rectangle will be effectively size 0 and nothing will be drawn.

Note: Point 1 is an inclusive coordinate, while point 2 is an exclusive
coordinate.

INSERT ILLUSTRATION OF WHAT THAT MEANS.

The clip rectangle defaults to (0,0,128,64) on startup. This is the
whole screen. Be sure to reset the clip rectangle size to this default
after using it, otherwise all future drawing operations will be confined
to this region.

## Example

    PUB Main
        lcd.Start(gfx.Start)
        gfx.LoadMap(tilemap,level) 
     
        ' more init code
        repeat  ' game loop

            gfx.SetClipRectangle(0, 24, 128, 64)
            gfx.DrawMap(xoffset,yoffset)
            gfx.SetClipRectangle(0,  0, 128, 64)
     
            lcd.DrawScreen

See also: [map.DrawRectangle](map.DrawRectangle.html) .


