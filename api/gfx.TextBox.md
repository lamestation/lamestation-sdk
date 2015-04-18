---
layout: learnpage
title: gfx.TextBox
--- 

Draw a string to the screen.

## Syntax

    TextBox(str, x, y, w, h)

-   **str** - Null-terminated string of characters. Can be inline or
    from a DAT block.
-   **x** - Horizontal position on the screen.
-   **y** - Vertical position on the screen.
-   **w** - Allowed width of text box. When the width is exceeded, the
    text cursor will break, or advance to the start of the next line.
-   **h** - Allowed height of text box.

## Description

Draws a null-terminated string of characters to the screen at the
position **(x, y)** with a specified width and height; supports
multi-line strings.

## Example

### Inline String

    gfx.TextBox(string("THIS IS A TEST"), 4, 28, 100, 30)

### Multi-Line String

    gfx.TextBox(string("THIS", 10, "IS", 10, "NOT", 10", "A", 10, "DRILL"), 20, 0, 128, 64)

### DAT String

    PUB Main
        ' init ...
     
        gfx.TextBox(@mystring, 0, 0, 50, 50)
     
    DAT
    mystring    byte "This is also a test!", 0

See `        StarWarsReel.spin       ` for a fun trick you can do with
the `        TextBox       ` command.

See also: [gfx.LoadFont](gfx.LoadFont.html) ,
[gfx.PutString](gfx.PutString.html) .


