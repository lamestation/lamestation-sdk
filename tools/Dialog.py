#!/usr/bin/python

import wx

def Quit():
    dial = wx.MessageDialog(None, "Are you sure you want to quit?","Question",
            wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
    return dial.ShowModal()

    if result == wx.ID_YES:
        self.Destroy()


def About():

    info = wx.AboutDialogInfo()

    description = """IMG2DAT is an image conversion tool for the LameStation
gaming handheld.

It supports many image types and renders them all in
beautiful eye-popping 3-color display.
    """

    license = """IMG2DAT is free software; you can redistribute 
it and/or modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 of the License, 
or (at your option) any later version.

IMG2DAT is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See the GNU General Public License for more details. You should have 
received a copy of the GNU General Public License along with IMG2DAT; 
if not, write to the Free Software Foundation, Inc., 59 Temple Place, 
    Suite 330, Boston, MA  02111-1307  USA"""

#    info.SetIcon(wx.Icon('hunter.png', wx.BITMAP_TYPE_PNG))
    info.SetName('IMG2DAT')
    info.SetVersion('1.0')
    info.SetDescription(description)
    info.SetCopyright('(C) 2014 LameStation LLC')
    info.SetWebSite('http://www.lamestation.com')
    info.SetLicence(license)
    info.AddDeveloper('Brett Weir')

    wx.AboutBox(info)
