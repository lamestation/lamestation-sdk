---
layout: learnpage
title: ctrl.Up
--- 

Return whether the joystick is tilted upwards.

## Syntax

    Up

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
<td align="left"><img src="attachments/15401033/15302739.png" /></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

## Example

        if ctrl.Up
            y--

See also: [ctrl.Right](ctrl.Right.html) , [ctrl.Down](ctrl.Down.html) ,
[ctrl.Left](ctrl.Left.html) , [ctrl.Update](ctrl.Update.html) .


