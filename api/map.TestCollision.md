---
layout: learnpage
title: map.TestCollision
--- 

Test if the region has collided with a map tile.

## Syntax

    TestCollision(x, y, w, h)

-   **x** - x position of object
-   **y** - y position of object
-   **w** - width of object
-   **h** - height of object

Returns non-zero <sup>1</sup> if a collision has occurred between an
object and the map; 0 otherwise.

## Description

All LameStation tilemaps are embedded with collision information, so
that levels created through the map editor already have walkable regions
defined when loaded. This command tests an object against those walkable
areas.

Off-Map Regions

Only valid map regions are tested for collisions; positions that are off
the map area will always return 0.

<table>
<col width="100%" />
<tbody>
<tr class="odd">
<td align="left"><table>
<caption> </caption>
<tbody>
<tr class="odd">
<td align="left"><img src="attachments/14286906/14417984.png" /></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

## Example

See the `        02_TestCollision.spin       ` demo in the SDK.

See also: [map.TestMoveX](map.TestMoveX.html) ,
[map.TestMoveY](map.TestMoveY.html) .

<sup>1</sup> The exact value is the coordinate pair of the first map
tile causing a collision, offset by (1, 1).


