{{
It's MIDI Time!
-------------------------------------------------
LameAudio MIDI Keyboard Demo
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2013-2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
This demo shows you how to drive the LameAudio
synthesizer with a MIDI keyboard or device. Play the
LameStation like a piano!
}}

CON     _clkmode = xtal1 + pll16x
        _xinfreq = 5_000_000

        MIDIPIN = 16

VAR
    byte    newbyte
    byte    statusbyte
    byte    statusnibble
    byte    statuschannel

    byte    databyte1
    byte    databyte2

OBJ
    pst     :       "LameSerial"
    pst2    :       "LameSerial" 
    audio   :       "LameAudio"      

PRI ControlNote

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    pst2.Dec(databyte1)
    pst2.Char(" ")
    pst2.Dec(databyte2)
    pst2.Char(" ")
    
    'TURN NOTE ON
    if statusnibble == $90
        audio.PlayNewNote(databyte1)
    'TURN NOTE OFF
    if statusnibble == $80 or databyte2 == 0
        audio.StopNote(databyte1)

PRI ControlKnob

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    'modulation wheel
    case databyte1
        ' Modulation
        $01:
    
        ' ADSR
        $4A:    audio.SetAttack(databyte2)
        $47:    audio.SetDecay(databyte2)
        $0A:    audio.SetSustain(databyte2)
        $07:    audio.SetRelease(databyte2)
        $48:    audio.SetVolume(databyte2)
        $49:    audio.SetWaveform(databyte2)
    
        ' SUSTAIN PEDAL
        $40:    if databyte2 <> 0
                    audio.PressPedal
                else
                    audio.ReleasePedal

PRI ControlPitchBend

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    pst2.Dec(databyte1)
    pst2.Char(" ")
    pst2.Dec(databyte2)
    pst2.Char(" ")
    
    pst2.Char(pst#NL)

PUB Main

    pst.StartRxTx(MIDIPIN, MIDIPIN+1, 0, 31250)
    pst2.StartRxTx(31, 30, 0, 115200)
    pst2.Clear

    audio.Start
  
    repeat
        'system control messages begin with $FF
        'status byte, data bytes (1-2)
        'status messages begin with the left-most bit = 1

        newbyte := pst.CharIn

        if newbyte & $80
            statusbyte := newbyte
            statusnibble := statusbyte & $F0
            statuschannel := statusbyte & $0F
            pst2.Char(pst#NL)
            pst2.Hex(statusbyte, 2)
            pst2.Char(" ")

        else
            case statusnibble
                $E0:        ControlPitchBend
                $B0:        ControlKnob
                $90, $80:   ControlNote
                $FE:    'ACTIVE SENSING (output by some keyboards)
                other:

DAT
{{

 TERMS OF USE: MIT License

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}
DAT