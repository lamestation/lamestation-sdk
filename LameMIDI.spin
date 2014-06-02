{{
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

            pst2.Hex(databyte1,2)
            pst2.Char(" ")
            pst2.Hex(databyte2,2)
            pst2.Char(" ")

            'modulation wheel
           if databyte1 == $01

            'ADSR controls
           elseif databyte1 == $4A          'attack
                audio.SetAttack(databyte2)

           elseif databyte1 == $47          'decay
                audio.SetDecay(databyte2)

           elseif databyte1 == $0A          'sustain
                audio.SetSustain(databyte2)

           elseif databyte1 == $07          'release
                audio.SetRelease(databyte2)

            'waveform control
           elseif databyte1 == $49          'waveform
                audio.SetWaveform(databyte2)

           'same knobs with assign button pressed
           elseif databyte1 == $48
                audio.SetVolume(databyte2)

           elseif databyte1 == $5B

           elseif databyte1 == $5D

             'SUSTAIN PEDAL
           elseif databyte1 == $40
                if databyte2 <> 0
                    audio.PressPedal
                else
                    audio.ReleasePedal


           else

PRI ControlPitchBend

            databyte1 := newbyte
            databyte2 := pst.CharIn

            pst2.Dec(databyte1)
            pst2.Char(" ")
            pst2.Dec(databyte2)
            pst2.Char(" ")
            
            pst2.Char(pst#NL)

PRI InitPlugin


PUB go | x                                                 
    pst.StartRxTx(MIDIPIN, MIDIPIN+1, 0, 31250)
    pst2.StartRxTx(31, 30, 0, 115200)
    pst2.Clear

    audio.Start
  
    repeat
        'system control messages begin with $FF
      'status byte, data bytes (1-2)

      newbyte := pst.CharIn

      if newbyte & $80
         statusbyte := newbyte
         statusnibble := statusbyte & $F0
         statuschannel := statusbyte & $0F
         pst2.Char(pst#NL)
         pst2.Hex(statusbyte, 2)
         pst2.Char(" ")

      else
         if statusnibble == $E0
           ControlPitchBend

         elseif statusnibble == $B0
           ControlKnob

         elseif statusnibble == $90 or statusnibble == $80
           ControlNote

         'ACTIVE SENSING (output by some keyboards)
         elseif statusbyte == $FE


{{
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                           TERMS OF USE: MIT License                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this  │
│software and associated documentation files (the "Software"), to deal in the Software │ 
│without restriction, including without limitation the rights to use, copy, modify,    │
│merge, publish, distribute, sublicense, and/or sell copies of the Software, and to    │
│permit persons to whom the Software is furnished to do so, subject to the following   │
│conditions:                                                                           │
│                                                                                      │
│The above copyright notice and this permission notice shall be included in all copies │
│or substantial portions of the Software.                                              │
│                                                                                      │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,   │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A         │
│PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT    │
│HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION     │
│OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE        │
│SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                │
└──────────────────────────────────────────────────────────────────────────────────────┘
}}
