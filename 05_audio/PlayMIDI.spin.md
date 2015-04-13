<p>This demo shows you how to drive the LameAudio synthesizer with a MIDI keyboard or device. Play the LameStation like a piano!</p>
<pre><code>CON     _clkmode = xtal1 + pll16x
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
    pst     :       &quot;LameSerial&quot;
    pst2    :       &quot;LameSerial&quot; 
    audio   :       &quot;LameAudio&quot;
    gfx     :       &quot;LameGFX&quot;
    lcd     :       &quot;LameLCD&quot;

PRI ControlNote

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    pst2.Dec(databyte1)
    pst2.Char(&quot; &quot;)
    pst2.Dec(databyte2)
    pst2.Char(&quot; &quot;)
    
    &#39;TURN NOTE ON
    if statusnibble == $90
        audio.PlaySound(0,databyte1)
    &#39;TURN NOTE OFF
    if statusnibble == $80 or databyte2 == 0
        audio.StopSound(0)

PRI ControlKnob

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    &#39;modulation wheel
    case databyte1
        &#39; Modulation
        $01:
    
        &#39; ADSR
        $4A:    &#39;audio.SetAttack(databyte2)
                attack := databyte2
        $47:    &#39;audio.SetDecay(databyte2)
                decay := databyte2
        $0A:    &#39;audio.SetSustain(databyte2)
                sustain := databyte2
        $07:    &#39;audio.SetRelease(databyte2)
                release := databyte2
        $48:    &#39;audio.SetVolume(databyte2)
                volume := databyte2
        $49:    &#39;audio.SetWaveform(databyte2)
                waveform := databyte2
    
        &#39; SUSTAIN PEDAL
        $40:    if databyte2 &lt;&gt; 0
                &#39;    audio.PressPedal
                else
                &#39;    audio.ReleasePedal

PRI ControlPitchBend

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    pst2.Dec(databyte1)
    pst2.Char(&quot; &quot;)
    pst2.Dec(databyte2)
    pst2.Char(&quot; &quot;)
    
    pst2.Char(pst#NL)

PUB Main

    pst.StartRxTx(MIDIPIN, MIDIPIN+1, 0, 31250)
    pst2.StartRxTx(31, 30, 0, 115200)
    pst2.Clear

    audio.Start  

    cognew(MIDIController, @Stack_MIDIController)


PRI MIDIController

    repeat
        &#39;system control messages begin with $FF
        &#39;status byte, data bytes (1-2)
        &#39;status messages begin with the left-most bit = 1

        newbyte := pst.CharIn

        if newbyte &amp; $80
            statusbyte := newbyte
            statusnibble := statusbyte &amp; $F0
            statuschannel := statusbyte &amp; $0F
            pst2.Char(10)
            pst2.Char(13)
            pst2.Hex(statusbyte, 2)
            pst2.Char(&quot; &quot;)

        else
            case statusnibble
                $E0:        ControlPitchBend
                $B0:        ControlKnob
                $90, $80:   ControlNote
                $FE:    &#39;ACTIVE SENSING (output by some keyboards)
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
            intarray[i] := &quot; &quot;
        intarray[LENGTH-2] := &quot;0&quot;
    else
        repeat i from LENGTH-1 to 0
            intarray[i] := GetChar(number)
            number /= 10

    intarray[LENGTH] := 0

    gfx.PutString(@intarray, x, y)

PRI GetChar(digit)
    if not digit &gt; 0
        setzero := 0

    digit //= 10

    if digit &gt; 0
        digit += 48
        return digit
    else
        if setzero
            return &quot;0&quot;
        else
            return &quot; &quot;</code></pre>
<h2 id="complete-code">Complete Code</h2>
<pre><code>&#39; 05_audio/PlayMIDI.spin
&#39; -------------------------------------------------------
&#39; SDK Version: 0.0.0
&#39; Copyright (c) 2015 LameStation LLC
&#39; See end of file for terms of use.
&#39; -------------------------------------------------------
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
    pst     :       &quot;LameSerial&quot;
    pst2    :       &quot;LameSerial&quot; 
    audio   :       &quot;LameAudio&quot;
    gfx     :       &quot;LameGFX&quot;
    lcd     :       &quot;LameLCD&quot;

PRI ControlNote

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    pst2.Dec(databyte1)
    pst2.Char(&quot; &quot;)
    pst2.Dec(databyte2)
    pst2.Char(&quot; &quot;)
    
    &#39;TURN NOTE ON
    if statusnibble == $90
        audio.PlaySound(0,databyte1)
    &#39;TURN NOTE OFF
    if statusnibble == $80 or databyte2 == 0
        audio.StopSound(0)

PRI ControlKnob

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    &#39;modulation wheel
    case databyte1
        &#39; Modulation
        $01:
    
        &#39; ADSR
        $4A:    &#39;audio.SetAttack(databyte2)
                attack := databyte2
        $47:    &#39;audio.SetDecay(databyte2)
                decay := databyte2
        $0A:    &#39;audio.SetSustain(databyte2)
                sustain := databyte2
        $07:    &#39;audio.SetRelease(databyte2)
                release := databyte2
        $48:    &#39;audio.SetVolume(databyte2)
                volume := databyte2
        $49:    &#39;audio.SetWaveform(databyte2)
                waveform := databyte2
    
        &#39; SUSTAIN PEDAL
        $40:    if databyte2 &lt;&gt; 0
                &#39;    audio.PressPedal
                else
                &#39;    audio.ReleasePedal

PRI ControlPitchBend

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    pst2.Dec(databyte1)
    pst2.Char(&quot; &quot;)
    pst2.Dec(databyte2)
    pst2.Char(&quot; &quot;)
    
    pst2.Char(pst#NL)

PUB Main

    pst.StartRxTx(MIDIPIN, MIDIPIN+1, 0, 31250)
    pst2.StartRxTx(31, 30, 0, 115200)
    pst2.Clear

    audio.Start  

    cognew(MIDIController, @Stack_MIDIController)


PRI MIDIController

    repeat
        &#39;system control messages begin with $FF
        &#39;status byte, data bytes (1-2)
        &#39;status messages begin with the left-most bit = 1

        newbyte := pst.CharIn

        if newbyte &amp; $80
            statusbyte := newbyte
            statusnibble := statusbyte &amp; $F0
            statuschannel := statusbyte &amp; $0F
            pst2.Char(10)
            pst2.Char(13)
            pst2.Hex(statusbyte, 2)
            pst2.Char(&quot; &quot;)

        else
            case statusnibble
                $E0:        ControlPitchBend
                $B0:        ControlKnob
                $90, $80:   ControlNote
                $FE:    &#39;ACTIVE SENSING (output by some keyboards)
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
            intarray[i] := &quot; &quot;
        intarray[LENGTH-2] := &quot;0&quot;
    else
        repeat i from LENGTH-1 to 0
            intarray[i] := GetChar(number)
            number /= 10

    intarray[LENGTH] := 0

    gfx.PutString(@intarray, x, y)

PRI GetChar(digit)
    if not digit &gt; 0
        setzero := 0

    digit //= 10

    if digit &gt; 0
        digit += 48
        return digit
    else
        if setzero
            return &quot;0&quot;
        else
            return &quot; &quot;

</code></pre>
