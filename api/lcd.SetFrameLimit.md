---
layout: learnpage
title: lcd.SetFrameLimit
--- 

Set an upper limit to the number of times the screen will be redrawn a
second.

## Syntax

    SetFrameLimit(frequency)

-   **frequency** - The number of frames per second. Setting to 0
    disables frame limiting.

## Description

SetFrameLimit behaves like a speed limit. By setting it, you are
allowing games to run as slow as they want, but no faster than, the set
frame rate.

<table>
<col width="100%" />
<tbody>
<tr class="odd">
<td align="left"><table>
<caption> </caption>
<tbody>
<tr class="odd">
<td align="left"><img src="attachments/14811144/14876721.png" /></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

When frame limiting is disabled, [lcd.DrawScreen](lcd.DrawScreen.html)
does not wait for the vertical syncing period to update the screen,
which may result in tearing. To prevent tearing when frame limiting is
disabled, call the
[lcd.WaitForVerticalSync](lcd.WaitForVerticalSync.html) function before
DrawScreen.

Frame limiting is disabled by default.

## Example

Setting the frame limit to \~36Hz after program startup.

    PUB Main
        lcd.Start(gfx.Start)
        lcd.SetFrameLimit(40)

Setting the frame limit to \~17Hz.

     lcd.SetFrameLimit(20)

Disabling frame limiting.

     lcd.SetFrameLimit(0)


