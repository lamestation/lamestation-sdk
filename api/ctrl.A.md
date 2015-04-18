---
layout: learnpage
title: ctrl.A
--- 

Return the current state of the `'A'` button.

## Syntax

    A

This command takes no parameters, returns non-zero if the button is
pressed, zero otherwise.

## Description

This command returns the state of the `'A'` button. It requires
[ctrl.Update](ctrl.Update.html) to be called before it will return a
value.

<table>
<col width="100%" />
<tbody>
<tr class="odd">
<td align="left"><table>
<caption> </caption>
<tbody>
<tr class="odd">
<td align="left"><img src="attachments/15401021/15302767.png" /></td>
</tr>
</tbody>
</table></td>
</tr>
</tbody>
</table>

## Example

        if ctrl.A
            ShootBullet

See also: [ctrl.B](ctrl.B.html), [ctrl.Update](ctrl.Update.html).
