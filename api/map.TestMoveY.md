---
layout: learnpage
title: map.TestMoveY
--- 

Apply vertical movement to an object's position and test if it will
collide.

## Syntax

    TestMoveY(oldx, oldy, w, h, newy)

-   **oldx** - x position of object
-   **oldy** - y position of object
-   **w** - width of object
-   **h** - height of object
-   **newy** - proposed new y position of object

## Description

Returns a non-zero adjustment value if a collision has occurred for the
object and the map at the proposed new vertical position; 0 otherwise.
With the adjustment applied to the new position it is guaranteed that
the object now lines up with the obstacle.

Important

This function performs a single object location check at ( **oldx** ,
**newy** ). This means that if the distance between **oldy** and
**newy** is sufficiently large it may miss potential map collisions
(e.g. halfway between **oldy** and **newy** ).

## Example

    PUB Main
        lcd.Start(gfx.Start)                         ' setup screen and renderer
        map.Load(@gfx_data, @map_data)               ' prepare map

        repeat
            ' If there is no collision TestMoveY returns 0 so newx
            ' isn't affected. Otherwise the adjustment is applied.
            newy += map.TestMoveY(oldx, oldy, w, h, newy)
            ' ...
            lcd.DrawScreen                           ' update when ready

See also: [map.TestCollision](map.TestCollision.html) ,
[map.TestMoveX](map.TestMoveX.html) .


