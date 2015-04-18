---
layout: learnpage
title: gfx.PutString
--- 

Draw a single-line string to the screen.

## Syntax

    PutString(str, x, y)

-   **str** - Null-terminated string of characters. Usually based on but
    not limited to inline strings or a DAT block label references.
-   **x** - Horizontal position on the screen.
-   **y** - Vertical position on the screen.

## Description

Draws a null-terminated string of characters to the screen at the
position (x,y).

[gfx.LoadFont](gfx.LoadFont.html) must be called before this function
will work.

For multi-line strings, see [gfx.TextBox](gfx.TextBox.html) .

## Example

### Inline String

    gfx.PutString(string("THIS IS A TEST"), 4, 28)

### DAT String

    PUB Main
        ' init ...
     
        gfx.PutString(@mystring, 0, 0)
     
    DAT
    mystring    byte "This is also a test!", 0

See also: [gfx.LoadFont](gfx.LoadFont.html) ,
[gfx.PutChar](gfx.PutChar.html) , [gfx.TextBox](gfx.TextBox.html) .


