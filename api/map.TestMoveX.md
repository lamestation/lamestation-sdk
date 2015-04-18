---
layout: learnpage
title: map.TestMoveX
--- 

Apply horizontal movement to an object's position and test if it will
collide.

## Syntax

    TestMoveX(oldx, oldy, w, h, newx)

-   **oldx** - x position of object
-   **oldy** - y position of object
-   **w** - width of object
-   **h** - height of object
-   **newx** - proposed new x position of object

## Description

Returns a non-zero adjustment value if a collision has occurred for the
object and the map at the proposed new horizontal position; 0 otherwise.
With the adjustment applied to the new position it is guaranteed that
the object now lines up with the obstacle.

Important

This function performs a single object location check at ( **newx** ,
**oldy** ). This means that if the distance between **oldx** and
**newx** is sufficiently large it may miss potential map collisions
(e.g. halfway between **oldx** and **newx** ).

## Example

    PUB Main
        lcd.Start(gfx.Start)                         ' setup screen and renderer
        map.Load(@gfx_data, @map_data)               ' prepare map

        repeat
            ' If there is no collision TestMoveX returns 0 so newx
            ' isn't affected. Otherwise the adjustment is applied.
            newx += map.TestMoveX(oldx, oldy, w, h, newx)
            ' ...
            lcd.DrawScreen                           ' update when ready

See also: [map.TestCollision](map.TestCollision.html) ,
[map.TestMoveY](map.TestMoveY.html) .


