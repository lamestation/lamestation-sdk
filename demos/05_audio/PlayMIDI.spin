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

    long    Stack_MIDIController[40]

    byte    attack, decay, sustain, release, waveform, volume

OBJ
    pst     :       "LameSerial"
    pst2    :       "LameSerial"
    audio   :       "LameAudio"
    gfx     :       "LameGFX"
    lcd     :       "LameLCD"

PRI ControlNote

    databyte1 := newbyte
    databyte2 := pst.CharIn

    pst2.Dec(databyte1)
    pst2.Char(" ")
    pst2.Dec(databyte2)
    pst2.Char(" ")

    'TURN NOTE ON
    if statusnibble == $90
        audio.PlaySound(0,databyte1)
    'TURN NOTE OFF
    if statusnibble == $80 or databyte2 == 0
        audio.StopSound(0)

PRI ControlKnob

    databyte1 := newbyte
    databyte2 := pst.CharIn

    'modulation wheel
    case databyte1
        ' Modulation
        $01:

        ' ADSR
        $4A:    'audio.SetAttack(databyte2)
                attack := databyte2
        $47:    'audio.SetDecay(databyte2)
                decay := databyte2
        $0A:    'audio.SetSustain(databyte2)
                sustain := databyte2
        $07:    'audio.SetRelease(databyte2)
                release := databyte2
        $48:    'audio.SetVolume(databyte2)
                volume := databyte2
        $49:    'audio.SetWaveform(databyte2)
                waveform := databyte2

        ' SUSTAIN PEDAL
        $40:    if databyte2 <> 0
                '    audio.PressPedal
                else
                '    audio.ReleasePedal

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

    cognew(MIDIController, @Stack_MIDIController)

PRI MIDIController

    repeat
        'system control messages begin with $FF
        'status byte, data bytes (1-2)
        'status messages begin with the left-most bit = 1

        newbyte := pst.CharIn

        if newbyte & $80
            statusbyte := newbyte
            statusnibble := statusbyte & $F0
            statuschannel := statusbyte & $0F
            pst2.Char(10)
            pst2.Char(13)
            pst2.Hex(statusbyte, 2)
            pst2.Char(" ")

        else
            case statusnibble
                $E0:        ControlPitchBend
                $B0:        ControlKnob
                $90, $80:   ControlNote
                $FE:    'ACTIVE SENSING (output by some keyboards)
                other:
CON
    LENGTH = 4

VAR
    byte    setzero
    byte    intarray[LENGTH]

PRI PutNumber(number, x, y) | i
    setzero := 1
    if number == 0
        repeat i from 0 to LENGTH-1
            intarray[i] := " "
        intarray[LENGTH-2] := "0"
    else
        repeat i from LENGTH-1 to 0
            intarray[i] := GetChar(number)
            number /= 10

    intarray[LENGTH] := 0

    gfx.PutString(@intarray, x, y)

PRI GetChar(digit)
    if not digit > 0
        setzero := 0

    digit //= 10

    if digit > 0
        digit += 48
        return digit
    else
        if setzero
            return "0"
        else
            return " "
