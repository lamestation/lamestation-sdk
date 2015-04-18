---
layout: learnpage
title: gfx.LoadFont
--- 

Load a font for drawing text.

## Syntax

    LoadFont(source, startingchar, tilewidth, tileheight)

-   **source** - The address where the font graphics are located.
-   **startingchar** - The first character in the font graphics, often
    `         ' '        ` (space).
-   **tilewidth** - The width of the font characters or 0.
-   **tileheight** - The height of the font characters or 0.

If **tilewidth** or **tileheight** are 0 (default) then their respective
values are extracted from the font data ( **source** ).

## Description

Sets text-drawing commands to use the font with the given parameters.

Must be called before any text-drawing operationg is done.

## Example

### 8x8 Font

    gfx.LoadFont(font_8x8.Addr, " ", 8, 8)

### 4x4 Font

    gfx.LoadFont(font_4x4.Addr, " ", 4, 4)


