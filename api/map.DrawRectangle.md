---
layout: learnpage
title: map.DrawRectangle
--- 

Draw the current map to a portion of the screen.

## Syntax

    DrawRectangle(offset_x, offset_y, x1, y1, x2, y2)

-   **xoffset** - Starting x position on map.
-   **yoffset** - Starting y position on map.
-   **x1** - Left edge of clip rectangle.
-   **y1** - Top edge of clip rectangle.
-   **x2** - Right edge of clip rectangle.
-   **y2** - Bottom edge of clip rectangle.

## Description

Draw a region of the current map loaded by `        Load       ` ,
starting at `        (xoffset, yoffset)       ` , to screen, in a region
of the screen defined by `        (x1, y1, x2, y2)       ` .

Each tile in a level map is one byte, with 1 bit for collision and 7
bits for tilemap index. This means that **tilemaps are limited to 128
different tiles** per map.

xoffset and yoffset select a starting point on the level map from which
to draw the screen from. This is how you control which part of the level
to display.

<table>
<col width="100%" />
<tbody>
<tr class="odd">
<td align="left"><table>
<caption> </caption>
<tbody>
<tr class="odd">
<td align="left"><img src="attachments/15958140/16089150.png" /></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

`        DrawRectangle       ` is more powerful than
`        DrawMap       ` as it allows you to customize the size of the
map region that is drawn to the screen. This is useful for creating
games with multiple screens views, or using `        DrawMap       ` to
create tile-based non-level game assets like enemy spaceships.

<table>
<col width="100%" />
<tbody>
<tr class="odd">
<td align="left"><table>
<caption> </caption>
<tbody>
<tr class="odd">
<td align="left"><img src="attachments/15958140/16089146.png" /></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

## Example

    PUB Main
        lcd.Start(gfx.Start)                         ' setup screen and renderer
        map.Load(@gfx_data, @map_data)               ' prepare map

        repeat
            ' ...
            gfx.ClearScreen                          ' clear screen (map may be transparent)
            map.DrawRectangle(offsetx, offsety, 20, 20, 100, 64)    ' draw map
            ' ...
            ' ...
            lcd.DrawScreen                           ' update when ready

See also: [map.Load](map.Load.html) , [map.Draw](map.Draw.html) .


