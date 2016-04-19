{{
SoundDesigner - MIDI Controller
------------------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
------------------------------------------------------------
}}

CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    MIDIPIN = 16

VAR
    byte    newbyte
    byte    statusbyte
    byte    statusnibble
    byte    statuschannel

    byte    databyte1
    byte    databyte2

    long    Stack_MIDIController[50]

OBJ
    audio   :   "LameAudio"
    ser     :   "LameSerial"

PUB Main
    audio.Start
    
    Start

PUB Start
    ser.StartRxTx(31, 30, 0, 115200)

    cognew(MIDIController, @Stack_MIDIController)

PRI ControlKnob

    databyte1 := newbyte
    databyte2 := ser.CharIn
    
    case databyte1
        $40:    

PRI ControlNote

    databyte1 := newbyte
    databyte2 := ser.CharIn
    
    if statusnibble == $90
        audio.PlaySound(0,databyte1)
    if statusnibble == $80 or databyte2 == 0
        audio.StopSound(0)
        
    ser.Hex (databyte1, 2)
    ser.Hex (databyte2, 2)

PRI ControlPitchBend

    databyte1 := newbyte
    databyte2 := ser.CharIn

PRI MIDIController

    repeat

        newbyte := ser.CharIn
        
        ser.Hex (newbyte, 2)

        if newbyte & $80
            statusbyte := newbyte
            statusnibble := statusbyte & $F0
            statuschannel := statusbyte & $0F

        else
            case statusnibble
                $E0:        ControlPitchBend
                $B0:        ControlKnob
                $90, $80:   ControlNote
                other:

        ser.Char (10)
