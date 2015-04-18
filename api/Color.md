---
layout: learnpage
title: Color
--- 

In a monochrome, or black and white, LCD, each pixel is given one bit in
memory. This single bit indicates whether that pixel is on or off. So
each byte of data in the buffer represents 8 pixels. Let's call these
the *color* pixels, and represent them as 'c'. Here is one byte of color
data.

    c c c c c c c c

Now, in the 2-bit color format, every 8 pixels now occupies a **word**
of data, and in that word of data, every second pixel is now what I call
a *flip* bit, represented as 'f'.

    cf cf cf cf cf cf cf cf

Let's look at a sample image rendered in black and white.

![](attachments/16547993/16744549.png)   

It's not bad. Depending on your level of artistry, you can make
monochrome look pretty good. But let's look at that same image, but
rendered with black, white, and gray.

![](attachments/16547993/16744550.png)

This is only one additional color, but the difference is massive. How
can we achieve this affect on the LameStation?

First, each pixel is assigned two bits, instead of one.

Upon adding the flip bit, there are now four possible color values:
`    00   ` , `    01   ` , `    10   ` , and `    11   ` . So this
presents us with a couple options:

1.  Add two gray colors
2.  Add one gray color and use the extra bit for something else.

While two shades of gray sounds like a good idea, there are some pretty
compelling reasons to go with option \#2. The pixels on the screen can
only be toggled so fast before you can't even tell, so the benefit of
two shades of gray is questionable. But also, and more importantly, this
extra value can be used as a mask to overlay images onto one another
seamlessly.

Here is the truth table showing the color values and what they mean, for
your reference.

flip

color

result

0

0

black

0

1

white

1

0

transparent

1

1

gray
