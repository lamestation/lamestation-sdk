{{
Pikemanz - Battle Engine
-------------------------------------------------
Version: 1.0
Copyright (c) 2014 LameStation.
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
CON
    _clkmode        = xtal1 + pll16x
    _xinfreq        = 5_000_000     

OBJ
    lcd     :   "LameLCD"
    gfx     :   "LameGFX"
    audio   :   "LameAudio"
    music   :   "LameMusic"
    ctrl    :   "LameControl"
   
    pk1     :   "gfx_pk_pakechu2"
    pk2     :   "gfx_pk_mootoo"

    song    :   "song_battle"
    
    dia     :   "PikeCore"
    pike    :   "PikeManager"

VAR
    byte    front_pk
    byte    back_pk
    
    byte    health
    byte    hp_dsp[2]
        
    byte    click
    
PUB Main
    lcd.Start(gfx.Start)
    audio.Start
    music.Start    
    ctrl.Start
    
    Run
    
PUB Run    

    music.LoadSong(song.Addr)
    music.LoopSong
    
    front_pk := pike.SetPikeman(0, string("PAKECHU"), 76, 40, 32, 50, pk1.Addr)
    back_pk := pike.SetPikeman(1, string("MOOTOO"), 76, 40, 32, 50, pk2.Addr)
    
    hp_dsp[back_pk] := pike.GetHealth(back_pk)
    hp_dsp[front_pk] := pike.GetHealth(front_pk)
    
    repeat
        ctrl.Update
        gfx.ClearScreen(gfx#WHITE)
        
        if ctrl.A
            if not click
                click := 1
                pike.Hurt(back_pk, 20)
        else
            click := 0

        if ctrl.Down
            pike.Hurt(front_pk, 2)
        if ctrl.Up
            pike.Heal(front_pk, 2)
            
        Handler
        

        pike.Draw(back_pk, 78, 0)
        pike.Draw(front_pk, 20, 20)
    
        dia.StatusBox(pike.GetName(back_pk),hp_dsp[back_pk], pike.GetMaxHealth(back_pk), 1, 1, 1)    
        dia.StatusBox(pike.GetName(front_pk),hp_dsp[front_pk], pike.GetMaxHealth(front_pk), 76, 40,0)
            
        dia.MessageBox(string("JAKE wants",10,"to FIGHT"), 1,40,72,24,6,6)
'        dia.AttackBox(string(
        
        if ctrl.B
            lcd.InvertScreen(True)
        else
            lcd.InvertScreen(False)
        
        lcd.DrawScreen

DAT
    

PUB HealthHandler | i
    repeat i from 0 to pike#PIKEZ-1
        if hp_dsp[i] > pike.GetHealth(i)
            hp_dsp[i]--
        if hp_dsp[i] < pike.GetHealth(i)
            hp_dsp[i]++

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
