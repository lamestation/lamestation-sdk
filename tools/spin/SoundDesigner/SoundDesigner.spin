{{
Sound Designer
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

    #0, _SND, _PAT, _SNG
    #0, _NAV, _ATK, _DEC, _SUS, _REL, _VOL, _WAV, _NOTE
    #0, _SQR, _SAW, _TRI, _SIN, _NOI, _SAMP

    MIDIPIN = 16
    ROWS    = 4

VAR
    byte    control[10]
    word    controlname[10]
    word    wavename[10]
    word    wavegfx[10]
    byte    ctrlindex[3]
    byte    channel
    byte    selected, clicked
    byte    newnote

    byte    apress
    byte    bpress

    byte    newbyte
    byte    statusbyte
    byte    statusnibble
    byte    statuschannel

    byte    databyte1
    byte    databyte2

    long    Stack_MIDIController[50]
    long    Stack_PatternPlayer[40]


' **********************************************************
' * Main
' **********************************************************
OBJ
    audio   :   "LameAudio"
    gfx     :   "LameGFX"
    lcd     :   "LameLCD"
    ctrl    :   "LameControl"
    fn      :   "LameFunctions"
    pst     :   "LameSerial"

    font    :   "gfx_font4x6"

PUB AudioDemo
    lcd.Start(gfx.Start)
    lcd.SetFrameLimit(lcd#FULLSPEED)

    pst.StartRxTx(MIDIPIN, MIDIPIN+1, 0, 31250)

    audio.Start

    'cognew(MIDIController, @Stack_MIDIController)
    cognew(PatternPlayer, @Stack_PatternPlayer)

    control[_NAV]  := _PAT
    control[_ATK]  := 127
    control[_DEC]  := 8
    control[_SUS]  := 80
    control[_REL]  := 0
    control[_VOL]  := 127
    control[_NOTE] := 50
    control[_WAV] := _SAMP

    patindex_max := 16

    SetChannel

    LoadAssets

    gfx.LoadFont(font.Addr," ",0,0)

    repeat
        ctrl.Update

        gfx.ClearScreen(0)
        gfx.PutString(string("SoundDesigner v0.2"),1,1)
        GUI_TabBrowser(77,0)

        case control[_NAV]
            _SND:   Control_SND
            _PAT:   Control_PAT
                    

        if ctrl.B
            if not bpress
                bpress := 1
                if control[_NAV] < _SNG
                    control[_NAV]++
                else
                    control[_NAV] := 0

        else
            bpress := 0

        lcd.DrawScreen




' **********************************************************
' * Controls
' **********************************************************

PRI Control_Slider(index)
    if ctrl.Left
        if control[index] > 0
            control[index]--
            return 1
    
    if ctrl.Right
        if control[index] < 127
            control[index]++
            return 1

PRI Control_Rotary(index,minchoice,maxchoice)
    if ctrl.Left
        if control[index] > minchoice
            control[index]--
            return 1
        
    if ctrl.Right
        if control[index] < maxchoice
            control[index]++
            return 1

PRI Control_Navigation(minchoice, maxchoice)
                    
    if ctrl.Up
        if ctrlindex > minchoice
            ctrlindex--

    if ctrl.Down
        if ctrlindex < maxchoice
            ctrlindex++


PRI Control_SND

    if ctrl.Left or ctrl.Right or ctrl.Up or ctrl.Down

        case ctrlindex[_SND]
            _ATK.._VOL: selected := Control_Slider(ctrlindex[_SND])
            _NOTE:      selected := Control_Slider(ctrlindex[_SND])
           
        if not clicked
            clicked := 1
            case ctrlindex[_SND]
                _WAV:   selected := Control_Rotary(ctrlindex[_SND],0,5)

            Control_Navigation(0,_NOTE)

        if selected
            SetChannel                        
            selected := 0

    else
        clicked := 0

    if ctrl.A
        if not apress
            audio.PlaySound(channel,control[_NOTE])
        apress := 1
    else
        if apress
            audio.StopSound(channel)
        apress := 0

    GUI_ADSR(1,10)
    GUI_Waveform(45,20)
    GUI_Keyboard(0,48)

OBJ
    patview : "map_pattern"
    pat     : "gfx_pat_piano"
    key     : "gfx_pat_key"
    cur     : "gfx_cursor"
    led     : "gfx_led"

VAR
    byte    patindex
    byte    patindex_max
    byte    pattern[16]
    byte    cursor_x
    byte    cursor_y
    long    patoffset
    byte    play

CON
    VIEW_Y1 = 10
    VIEW_Y2 = 56
    VIEW_H = VIEW_Y2-VIEW_Y1

    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252 

PRI PatternPlayer | repeattime

    repeat patindex from 0 to patindex-1
        pattern[patindex] := SNOP

    repeat
        repeattime := cnt
            
        if play
            patindex := 0
            repeat while patindex < patindex_max 'and play                        
                if pattern[patindex] == SNOP

                elseif pattern[patindex] == SOFF
                    audio.StopSound( 0 )                                   
                else
                    audio.PlaySound( 0, pattern[patindex] )
                patindex++

                waitcnt(repeattime += 10000000)
            play := 0

PRI GUI_Pattern(x,y,h,active)

       gfx.DrawMapRectangle(0,patoffset,x,y,x+8,y+h+1)
       gfx.Sprite(led.Addr, x, y+h, active)

PRI Control_PAT | i

    if ctrl.Left
        if cursor_x > 0
            cursor_x--

    if ctrl.Right
        if cursor_x < patindex_max-1
            cursor_x++
    
    if ctrl.Down
        if cursor_y < 96
            cursor_y++
        if cursor_y > patoffset+VIEW_H
            patoffset := cursor_y-VIEW_H

    if ctrl.Up
        if cursor_y > 0
            cursor_y--
        if cursor_y < patoffset
            patoffset := cursor_y

    if ctrl.A
        if not apress
            audio.PlaySound(channel,cursor_y)
            pattern[cursor_x] := cursor_y
        apress := 1
    else
        if apress
            audio.StopSound(channel)
        apress := 0

    play := 1
    gfx.LoadMap(pat.Addr, patview.Addr)

    repeat i from 0 to patindex_max-1
        if patindex == i
            GUI_Pattern(i<<3,VIEW_Y1,VIEW_H,1)
        else
            GUI_Pattern(i<<3,VIEW_Y1,VIEW_H,0)

        if pattern[i] <> 0
            gfx.Sprite(key.Addr, i<<3, pattern[i]+VIEW_Y1-patoffset,0)   

    gfx.Sprite(cur.Addr, cursor_x<<3, cursor_y-1+VIEW_Y1-patoffset,0)

' **********************************************************
' * Widgets
' **********************************************************

OBJ
    box18 : "gfx_box_18x9"
    box24 : "gfx_box_24x9"

    key_w : "gfx_key_w"
    key_b : "gfx_key_b"

    val   : "gfx_valuebar"
    blip  : "gfx_blipbar"

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

PRI GUI_ADSR(x,y) | i

    repeat i from _ATK to _VOL
        if i == ctrlindex
            ControlBox(controlname[i],control[i],x+((i-_ATK)/ROWS)*44,y+((i-_ATK)//ROWS)<<3,1)
        else
            ControlBox(controlname[i],control[i],x+((i-_ATK)/ROWS)*44,y+((i-_ATK)//ROWS)<<3,0)

PRI GUI_Waveform(x,y)

    if _WAV == ctrlindex
        gfx.InvertColor(True)

    gfx.Sprite(box24.Addr,x,y,0)
    gfx.PutString(wavename[control[_WAV]],x+2,y+2)
    gfx.Sprite(wavegfx[control[_WAV]],x,y+10,0)
    gfx.InvertColor(False)

PRI GUI_Keyboard(x,y) | i, k, keys, oldx, keyoffset, keymin, keymax

    keys := 64
    keyoffset := (control[_NOTE] - 32) #> 0
    keymin := keyoffset
    keymax := keymin+keys <# 127

    x -= keyoffset~>1
    oldx := x
    
    gfx.Sprite(blip.Addr, x + control[_NOTE],y-2,0)

    repeat i from keymin to keymax
        k := i // 12
        if i == control[_NOTE]
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
        if i == control[_NOTE]
            gfx.InvertColor(True)
        else
            gfx.InvertColor(False)
        k := i // 12
        case k
            1,3,6,8,10:   gfx.Sprite(key_b.Addr,x,y,0)
                          x += 1
            4, 11:        x += 4
            other:        x += 3
            
PRI GUI_Tab(text,x,y,inv)

    if inv == control[_NAV]
        gfx.InvertColor(True)

    gfx.Sprite(box18.Addr,x,y,0)
    gfx.PutString(text,x+3,y+2)

    gfx.InvertColor(False)

PRI GUI_TabBrowser(x,y)

    GUI_Tab(string("SND"),x,y,_SND)
    GUI_Tab(string("PAT"),x+18,y,_PAT)
    GUI_Tab(string("SNG"),x+33,y,_SNG)

' **********************************************************
' * Graphics
' **********************************************************

PRI LoadAssets
    wavename[_SQR] := @wSQR
    wavename[_TRI] := @wTRI
    wavename[_SAW] := @wSAW
    wavename[_SIN] := @wSIN
    wavename[_NOI] := @wNOI
    wavename[_SAMP] := @wSAMP

    wavegfx[_SQR] := gsqr.Addr    
    wavegfx[_SAW] := gsaw.Addr
    wavegfx[_TRI] := gtri.Addr
    wavegfx[_SIN] := gsin.Addr
    wavegfx[_NOI] := gnoi.Addr
    wavegfx[_SAMP] := gsamp.Addr

    controlname[_ATK] := @nATK
    controlname[_DEC] := @nDEC
    controlname[_SUS] := @nSUS
    controlname[_REL] := @nREL
    controlname[_WAV] := @nWAV
    controlname[_VOL] := @nVOL


OBJ

    gsin  : "gfx_wsin"
    gtri  : "gfx_wtri"
    gsaw  : "gfx_wsaw"
    gsqr  : "gfx_wsqr"
    gnoi  : "gfx_wnoi"
    gsamp : "gfx_wsamp"

DAT

nATK    byte    "ATK",0
nDEC    byte    "DEC",0
nSUS    byte    "SUS",0
nREL    byte    "REL",0
nWAV    byte    "WAV",0
nVOL    byte    "VOL",0

wSQR    byte    "Sqr",0
wTRI    byte    "Tri",0
wSAW    byte    "Saw",0
wSIN    byte    "Sine",0
wNOI    byte    "Noise",0
wSAMP   byte    "Samp",0

OBJ

    organ   :   "ins_hammond"

   
' **********************************************************
' * MIDI Controller
' **********************************************************

PRI SetChannel
    audio.SetADSR(0,control[_ATK],control[_DEC],control[_SUS],control[_REL])
    audio.SetParam(0,audio#_WAV, control[_WAV] // 6)
   ' audio.SetVolume(control[_VOL])
    audio.SetSample(organ.Addr)
 {{
PRI ControlKnob

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
    case databyte1
        $40:    

PRI ControlNote

    databyte1 := newbyte
    databyte2 := pst.CharIn
    
'    if statusnibble == $90
 '       audio.PlayNewNote(databyte1)
  '  if statusnibble == $80 or databyte2 == 0
   '     audio.StopNote(databyte1)

PRI ControlPitchBend

    databyte1 := newbyte
    databyte2 := pst.CharIn

PRI MIDIController

    repeat

        newbyte := pst.CharIn

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
}}
