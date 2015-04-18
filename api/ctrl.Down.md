---
layout: learnpage
title: ctrl.Down
--- 

Return whether the joystick is tilted downwards.

## Syntax

    Down

This command takes no parameters, returns non-zero if tilted, zero
otherwise.

## Description

[ctrl.Update](ctrl.Update.html) must be called before this command will
return a valid result.

<table>
<col width="100%" />
<tbody>
<tr class="odd">
<td align="left"><table>
<caption> </caption>
<tbody>
<tr class="odd">
<td align="left"><img src="attachments/15401035/15302750.png" /></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

## Example

        if ctrl.Down
            y++

See also: [ctrl.Up](ctrl.Up.html), [ctrl.Right](ctrl.Right.html),
[ctrl.Left](ctrl.Left.html), [ctrl.Update](ctrl.Update.html).


