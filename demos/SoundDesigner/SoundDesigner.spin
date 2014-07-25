{{
Sound Designer
─────────────────────────────────────────────────
Version: 1.0
Copyright (c) 2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
─────────────────────────────────────────────────
}}


CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000

    #0, _ADSR
    #0, _ATK, _DEC, _SUS, _REL, _VOL, _WAV
    #0, _SQR, _SAW, _TRI, _SIN, _NOISE, _SAMPLE

OBJ
    audio   :               "LameAudio"
    gfx     :               "LameGFX"
    lcd     :               "LameLCD"
    ctrl    :               "LameControl"
    fn      :               "LameFunctions"

    font    :               "font4x6"


VAR
    byte    waveform, volume
    byte    control[10]
    word    controlname[10]
    word    wavename[10]
    word    wavegfx[10]
    byte    ctrlindex[3]
    byte    note, channel
    byte    selected, clicked
    byte    newnote

PRI PlayNote
    audio.PlaySound(channel,note)



OBJ
    box18 : "box_18x9"
    box24 : "box_24x9"

    key_w : "key_w"
    key_b : "key_b"

    val   : "valuebar"
    blip  : "blipbar"

PRI ValueBar(value,x,y) | ox,oy
    ox := x+2
    oy := y+2
    
    value := value * 20 / 128

    gfx.Sprite(box24.Addr,x,y,0)

    gfx.SetClipRectangle(ox,oy,ox+value,oy+5)
    gfx.Sprite(val.Addr,ox,oy,0)
    gfx.SetClipRectangle(0,0,128,64)

PRI ControlBox(str,value,x,y,active)
    gfx.InvertColor(active)
    gfx.Sprite(box18.Addr,x,y,0)
    gfx.PutString(str,x+3,y+2)
    
    ValueBar(value,x+19,y)
    gfx.InvertColor(False)

CON
    ROWS = 5

PRI GUI_ADSR(x,y) | i
    repeat i from _ATK to _VOL
        if i == ctrlindex[_ADSR]
            ControlBox(controlname[i],control[i],x+(i/ROWS)*44,y+(i//ROWS)<<3,1)
        else
            ControlBox(controlname[i],control[i],x+(i/ROWS)*44,y+(i//ROWS)<<3,0)

PRI GUI_Waveform(x,y)
    if _WAV == ctrlindex[_ADSR]
        gfx.InvertColor(True)

    gfx.Sprite(box24.Addr,x,y,0)
    gfx.PutString(wavename[control[_WAV]],x+2,y+2)
    gfx.Sprite(wavegfx[control[_WAV]],x,y+10,0)
    gfx.InvertColor(False)


PRI HelpMenu
    gfx.ClearScreen(0)
    gfx.TextBox(string("Sound Designer",10,10,"A selects",10,"Up/down/left/right navigates"),0,0, 128, 64)


PRI GUI_Keyboard(x,y) | i, k, keys, oldx, keyoffset, keymin, keymax
    keys := 64
    keyoffset := (note - 32) #> 0
    keymin := keyoffset
    keymax := keymin+keys <# 127

    x -= keyoffset~>1
    oldx := x
    
    gfx.Sprite(blip.Addr,x+note,y-2,0)

    repeat i from keymin to keymax
        k := i // 12
        if i == note
            gfx.InvertColor(True)
        else
            gfx.InvertColor(False)
        case k 
            0,2,5,7,9:  gfx.Sprite(key_w.Addr,x,y,0)
                          x += 3
            4, 11:      gfx.Sprite(key_w.Addr,x,y,0)
                          x += 4
            other:        x += 1
    x := oldx
    repeat i from keymin to keymax
        if i == note
            gfx.InvertColor(True)
        else
            gfx.InvertColor(False)
        k := i // 12
        case k
            1,3,6,8,10:   gfx.Sprite(key_b.Addr,x,y,0)
                          x += 1
            4, 11:        x += 4
            other:        x += 3



PRI DrawGUI | x,y
    gfx.ClearScreen(0)
    gfx.PutString(string("SoundDesigner v0.2"),46,1)

    GUI_ADSR(1,1)
    GUI_Waveform(45,17)
    GUI_Keyboard(0,48)




OBJ
    gsin : "wsin"
    gtri : "wtri"
    gsaw : "wsaw"
    gsqr : "wsqr"



DAT

nATK    byte    "ATK",0
nDEC    byte    "DEC",0
nSUS    byte    "SUS",0
nREL    byte    "REL",0
nWAV    byte    "WAV",0
nVOL    byte    "VOL",0


DAT

wSQR    byte    "Sqr",0
wTRI    byte    "Tri",0
wSAW    byte    "Saw",0
wSIN    byte    "Sine",0
wNOISE  byte    "Noise",0
wSAMPLE byte    "Smp",0


PUB AudioDemo
    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#FULLSPEED)
    audio.Start

    control[_ATK] := 127
    control[_DEC] := 60
    control[_SUS] := 80
    control[_REL] := 70
    control[_VOL] := 127

    wavename[_SQR] := @wSQR
    wavename[_TRI] := @wTRI
    wavename[_SAW] := @wSAW
    wavename[_SIN] := @wSIN
    wavename[_NOISE] := @wNOISE
    wavename[_SAMPLE] := @wSAMPLE

    wavegfx[_SQR] := gsqr.Addr    
    wavegfx[_SAW] := gsaw.Addr
    wavegfx[_TRI] := gtri.Addr
    wavegfx[_SIN] := gsin.Addr


    controlname[_ATK] := @nATK
    controlname[_DEC] := @nDEC
    controlname[_SUS] := @nSUS
    controlname[_REL] := @nREL
    controlname[_WAV] := @nWAV
    controlname[_VOL] := @nVOL

    gfx.LoadFont(font.Addr," ",0,0)

    DrawGUI

    note := 50

    repeat
        ctrl.Update



        if ctrl.Left or ctrl.Right or ctrl.Up or ctrl.Down
            if ctrl.Left
                if control[ctrlindex[_ADSR]] > 0
                    control[ctrlindex[_ADSR]]--
                    selected := 1

            if ctrl.Right
                if control[ctrlindex[_ADSR]] < 127
                    control[ctrlindex[_ADSR]]++
                    selected := 1


            if not clicked
              clicked := 1
                if ctrl.Up
                    if ctrlindex[_ADSR] > 0
                        ctrlindex[_ADSR]--

                if ctrl.Down
                    if ctrlindex[_ADSR] < _WAV
                        ctrlindex[_ADSR]++


            if selected
                audio.SetADSR(control[_ATK],control[_DEC],control[_SUS],control[_REL])
                audio.SetWaveform(control[_WAV] // 5)
                audio.SetVolume(control[_VOL])
                'PlayNote
                selected := 0

        else
            clicked := 0

        DrawGUI

        if ctrl.A and ctrl.B
            HelpMenu

        elseif ctrl.A
            if not newnote
                PlayNote
                newnote := 1
        else
            newnote := 0
            audio.StopNote(note)
            audio.StopAllSound

        lcd.DrawScreen