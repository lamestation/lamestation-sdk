---
layout: learnpage
title: map.TestPoint
--- 

Test whether tile on a map is collidable.

## Syntax

    TestPoint(x, y)

-   **x** - Horizontal index of tile on map.
-   **y** - Vertical index of tile on map.

This function returns 0 is tile is walkable, and 1 if it is not.

## Description

`        TestPoint       ` tests whether a specific tile is collidable.

If a tile is collidable, commands like TestMoveX/Y will detect a
collision when the given object coordinates overlap with said tile. This
is how level/wall boundaries are enforced in a tile-based LameStation
game.

This command is useful when your game implements its own collision
scheme different from the one included in LameMap.

## Example

This example code is taken from
[Pikemanz](https://lamestation.atlassian.net/wiki/display/PIKE) . The
Pikemanz player does not walk freely on the map, instead moving from
square to square on a grid. [map.TestCollision](map.TestCollision.html)
is a poor solution because individual movements are planned then
executed, and it must be known in advance that a tile is walkable before
the player moves there. In this situation, TestPoint is a better
solution.

    PUB HandlePlayer | adjust
        
        if not moving

        moving := 1
        if targetx > playerx
            playerx++
        elseif targetx < playerx
            playerx--
        elseif targety > playery
            playery++
        elseif targety < playery
            playery--
        else
            if ctrl.Left
                dir := LEFT
                if not map.TestPoint((playerx>>3)-1, playery>>3)
                    targetx -= 8
            elseif ctrl.Right
                dir := RIGHT
                if not map.TestPoint((playerx>>3)+1, playery>>3)
                    targetx += 8
            elseif ctrl.Up
                dir := UP
                if not map.TestPoint(playerx>>3, (playery>>3)-1)
                    targety -= 8
            elseif ctrl.Down
                dir := DOWN
                if not map.TestPoint(playerx>>3, (playery>>3)+1)
                    targety += 8
            else
                moving := 0

See also: [map.TestMoveX](map.TestMoveX.html) ,
[map.TestMoveY](map.TestMoveY.html) ,
[map.TestCollision](map.TestCollision.html) ,
[Pikemanz](https://lamestation.atlassian.net/wiki/display/PIKE) .


