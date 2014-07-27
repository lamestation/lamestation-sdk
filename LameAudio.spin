{{
LameAudio Synthesizer
-------------------------------------------------
Version: 1.0
Copyright (c) 2013-2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}


CON
    PERIOD1 = 2000         ' 'FS = 80MHz / PERIOD1'
    FS      = 40000
    SAMPLES = 512
    PERVOICE = 1
    VOICES = 4
    OSCILLATORS = VOICES*PERVOICE
    REGPEROSC = 4

    OUTPUTPIN_MONO = 27
    
    KEYBITS = $180
    HELDBIT = $80
    KEYONBIT = $100
    SUSPEDALBIT = $800000

    NOTEBITS = $7F
    'VELOCITYBITS = $7F00
    VOLUMEBITS = $FFFFFF

    ADSRBITS = $3000000 'new
    ATTACKBIT = $1000000
    SUSTAINBIT = $2000000

    'ADSR register
    '       4bit      7bit       7bit       7bit       7bit
    '       0000    0000000    0000000    0000000    0000000
    '        W         R          S          D          A


    A_OFFSET = 0
    D_OFFSET = 7
    S_OFFSET = 14
    R_OFFSET = 21
    W_OFFSET = 28

    A_MASK = !($7F << A_OFFSET)
    D_MASK = !($7F << D_OFFSET)
    S_MASK = !($7F << S_OFFSET)
    R_MASK = !($7F << R_OFFSET)
    W_MASK = !($F << W_OFFSET)
    
    SONGS = 1
    SONGOFF = 255
    BAROFF = 254
    SNOP = 253
    SOFF = 252 

    BYTES_SONGHEADER = 3
    BYTES_BARHEADER = 1

    '0 timestamp     amount (shift by 12)
    '1 note on    note  channel
    '2 note off   channel

        
    '0 - note (last 8 bits)
    '1 - target volume         
    '2 - phase inc
    '3 - phase acc

    'NEW NOTE REGISTER

    'note registers
    ' $           ----------- 16 bits ----------
    ' $0000      0000000      0       0    0000000
    '            velocity   keyon    held  notenum




    'target volume register
    ' --- 6bits ---     2bit            --------- 24 bits ----------
    '    %0000_00       00             0000_0000 0000_0000 0000_0000
    '               ADSR state               current volume

    'phase inc and acc registers
    ' ----------------- 32 bits -------------
    ' %0000_0000 0000_0000 0000_0000 0000_0000       value to increment
    ' %0000_0000 0000_0000 0000_0000 0000_0000       accumulator
         



    'CHANNEL PARAM REGISTER

    
    OSCREGS = OSCILLATORS*REGPEROSC
    OSCBITMASK = (OSCILLATORS-1) << 2
    INITVAL = 127

OBJ

    fn  :       "LameFunctions"

VAR

    'ASM data structure (do not mess up)
    long    parameter
    long    outputlong

    long    channelparam  'volume   'waveform LSB
    long    channelADSR

    long    oscRegister[OSCREGS]


    byte    oscindexer
    byte    oscindexcounter
    byte    oscoffindexer

    long    songcursor
    long    barcursor
    long    timeconstant
    word    loopsongPtr     '' This value points to the first address of the song definition in a song

    byte    bar
    byte    barinc   
    byte    totalbars
    byte    play
    byte    replay
    byte    barres
    word    bartmp

    word    barAddr

    word    barshift
    byte    linecursor

    long    LoopingPlayStack[20]
    word    sample

PUB Start
      
    parameter := @freqTable + (@sample<<16)
    channelparam := (INITVAL << 8)
    'channelADSR := LONG[@instruments][0]
    
    cognew(@oscmodule, @parameter)    'start assembly cog
    cognew(LoopingSongParser, @LoopingPlayStack)
    

PUB SetAttack(attackvar)
    channelADSR := (channelADSR & A_MASK) + (attackvar << A_OFFSET)

PUB SetDecay(decayvar)
    channelADSR := (channelADSR & D_MASK) + (decayvar << D_OFFSET)

PUB SetSustain(sustainvar)
    channelADSR := (channelADSR & S_MASK) + (sustainvar << S_OFFSET)

PUB SetRelease(releasevar)
    channelADSR := (channelADSR & R_MASK) + (releasevar << R_OFFSET)

PUB SetWaveform(waveformvar)
    channelADSR := (channelADSR & W_MASK) + (waveformvar << W_OFFSET)

PUB SetVolume(volumevar)
    channelparam := (channelparam & $FFFF00FF) + (volumevar << 8)

PUB SetADSR(attackvar, decayvar, sustainvar, releasevar)
    SetAttack(attackvar)
    SetDecay(decayvar)
    SetSustain(sustainvar)
    SetRelease(releasevar)

PUB SetSample(samplevar)
    sample := samplevar

PUB PressPedal
    channelADSR |= SUSPEDALBIT

PUB ReleasePedal
    channelADSR &= !SUSPEDALBIT
    repeat oscoffindexer from 0 to OSCREGS-1 step REGPEROSC
        if oscRegister[oscoffindexer] & HELDBIT == 0           'if note is not being held
            oscRegister[oscoffindexer] &= !KEYONBIT        '9th bit


'PUB LoadInstr(instrnum)

'    channelADSR := LONG[@instruments][instrnum]

PUB FindFreeOscillator
    oscindexcounter := 0
    repeat while oscRegister[oscindexer+1] & ADSRBITS <> 0 and oscindexcounter < OSCILLATORS
        oscindexcounter += 1
        oscindexer += 4
        oscindexer &= OSCBITMASK

PUB PlayNewNote(note)
    FindFreeOscillator

    if oscRegister[oscindexer] & HELDBIT == 0
        oscRegister[oscindexer] := note + KEYBITS
    else
        oscindexcounter := 0
        repeat while oscRegister[oscindexer] & HELDBIT <> 0 and oscindexcounter < OSCILLATORS
            oscindexcounter += 1
            oscindexer += 4
            oscindexer &= OSCBITMASK
        oscRegister[oscindexer] := note + KEYBITS

    oscindexer += 4
    oscindexer &= OSCBITMASK

PUB StopNote(note)

    if channelADSR & SUSPEDALBIT == 0
        repeat oscoffindexer from 0 to OSCREGS-1 step REGPEROSC
            if oscRegister[oscoffindexer] & NOTEBITS == note
                oscRegister[oscoffindexer] &= !KEYBITS
    else
        repeat oscoffindexer from 0 to OSCREGS-1 step REGPEROSC
            if oscRegister[oscoffindexer] & NOTEBITS == note
                oscRegister[oscoffindexer] &= !HELDBIT           '9th bit


        
  
PUB PlaySound(channel, note)
    if note < 128 and channel < VOICES
        oscindexer := channel << 2
        oscRegister[oscindexer] &= !KEYBITS          
        oscRegister[oscindexer+1] &= !ADSRBITS
        oscRegister[oscindexer] := note + KEYBITS

PUB StopSound(channel)

    if channel < VOICES
        oscindexer := channel << 2          
        oscRegister[oscindexer] &= !KEYBITS 

PUB StopAllSound

    repeat oscindexer from 0 to OSCREGS-1 step REGPEROSC
        oscRegister[oscindexer] &= !KEYBITS

PUB LoadSong(songBarAddrvar)

    barAddr := songBarAddrvar
    totalbars := byte[songBarAddrvar][0]
    timeconstant := CalculateTimeConstant(byte[songBarAddrvar][1])
    barres := byte[songBarAddrvar][2]
    loopsongPtr := barAddr + totalbars*(barres+BYTES_BARHEADER) + BYTES_SONGHEADER        
    
    songcursor := 0
    barcursor := 0

PUB PlaySong
    play := 1
    replay := 0
    
PUB LoopSong
    play := 1
    replay := 1    

PUB StopSong

    play := 0
    replay := 0
    StopAllSound
    
PUB SongPlaying
    return play
        
PRI FindLoopBarFromSongPointer | x
'' This function increments the loop pointer by
'' the value of the song pointr

    x := 0
    barshift := 0
    repeat while x++ < byte[loopsongPtr][songcursor]
        barshift += barres+BYTES_BARHEADER

PRI CalculateTimeConstant(bpm)
    return ( clkfreq / bpm * 15 ) ' 60 / 4 for 16th note alignment

PRI LoopingSongParser | repeattime
    

    repeat
        repeattime := cnt
        
        if replay
            play := 1
            
        if play
            songcursor := 0
            repeat while byte[loopsongPtr][songcursor] <> SONGOFF and play
                
                barcursor := songcursor
                repeat linecursor from 0 to (barres-1)
                
                    songcursor := barcursor

                    ' play all notes defined in song definition
                    repeat while byte[loopsongPtr][songcursor] <> BAROFF and play 
                        FindLoopBarFromSongPointer 
                        
                        bartmp := barshift+BYTES_SONGHEADER+BYTES_BARHEADER+linecursor
                        
                        if byte[barAddr][bartmp] == SNOP

                        elseif byte[barAddr][bartmp] == SOFF
                            StopSound( byte[barAddr][barshift+BYTES_SONGHEADER] )       
                            
                        else
                            PlaySound( byte[barAddr][barshift+BYTES_SONGHEADER] , byte[barAddr][bartmp] )  'channel, note

                            
                        songcursor += 1

                    waitcnt(repeattime += timeconstant)               

                songcursor += 1

            play := 0
            StopAllSound


DAT


freqTable

long		858, 909, 963, 1021, 1081, 1146, 1214, 1286
long		1363, 1444, 1529, 1620, 1717, 1819, 1927, 2042
long		2163, 2292, 2428, 2573, 2726, 2888, 3059, 3241
long		3434, 3638, 3855, 4084, 4327, 4584, 4857, 5146
long		5452, 5776, 6119, 6483, 6869, 7277, 7710, 8169
long		8654, 9169, 9714, 10292, 10904, 11552, 12239, 12967
long		13738, 14555, 15421, 16338, 17309, 18338, 19429, 20584
long		21808, 23105, 24479, 25935, 27477, 29111, 30842, 32676
long		34619, 36677, 38858, 41169, 43617, 46211, 48959, 51870
long		54954, 58222, 61684, 65352, 69238, 73355, 77717, 82339
long		87235, 92422, 97918, 103740, 109909, 116445, 123369, 130705
long		138477, 146711, 155435, 164678, 174470, 184845, 195836, 207481
long		219819, 232890, 246738, 261410, 276954, 293423, 310871, 329356
long		348941, 369690, 391673, 414963, 439638, 465780, 493477, 522820
long		553909, 586846, 621742, 658713, 697882, 739380, 783346, 829926
long		879276, 931561, 986954, 1045641, 1107819, 1173693, 1243484, 1317426


DAT

                        org

oscmodule               mov       dira, diraval         ' set APIN to output
                        mov       ctra, ctraval         ' establish counter A mode and APIN
                        mov       frqa, #1              ' set counter to increment 1 each cycle

                        mov       time, cnt             ' record current time
                        add       time, period          ' establish next period

' Establish communication between cog and spin

                        mov       Addr, par             ' get address of frequency table

                        rdlong    freqAddr, Addr
                        mov       sampleAddr, freqAddr
                        and       freqAddr, halfmask
                        shr       sampleAddr, #16
                        
                        add       Addr, #4
                        mov       outputAddr, Addr      ' get output address
                        add       Addr, #4
                        mov       paramAddr, Addr       ' get channel parameters
                        add       Addr, #4
                        mov       adsrAddr, Addr        ' get adsr parameters
                        add       Addr, #4
                        mov       oscAddr, Addr         ' get oscillator registers

 

'MAIN LOOP START       
mainloop                waitcnt   time, period          ' wait until next period
                        neg       phsa, output          ' back up phsa so that it trips "value cycles from now

' Update channel parameters before anything else

                        rdlong    adsrtemp, adsrAddr              
              
                        'attack
                        mov       attack, adsrtemp
                        and       attack, #$7F
                        'decay
                        shr       adsrtemp, doffset
                        mov       decay, adsrtemp
                        and       decay, #$7F
                        'sustain 
                        shl       adsrtemp, #3
                        mov       sustain, adsrtemp
                        and       sustain, bigsusmask
                        'release               
                        shr       adsrtemp, #17
                        mov       release, adsrtemp
                        and       release, #$7F  
                        
                        'waveform               
                        shr       adsrtemp, #7
                        mov       waveform, adsrtemp
                        and       waveform, #$F  

' Initialize oscillator loop

                        mov       output, #0
                        mov       oscIndex, oscTotal
                        mov       oscPtr, oscAddr
              
' Get frequency from note value using table lookup

oscloop                 rdlong    noteAddrtemp, oscPtr

                        and       noteAddrtemp, keyonmask     nr, wz 'SET Z FLAG FOR LATER OPERATION, REMEMBER!!!

                        and       noteAddrtemp, #$7F
                        shl       noteAddrtemp, #2
                        add       noteAddrtemp, freqAddr
                        add       oscPtr, #4
                                                
                        'ADSR FILTER (or in this case, ADS filter?)
                        rdlong    voltemp, oscPtr
                        mov       vollongtemp, voltemp

                        'since Z flag still set from previous operation, no extra instructions needed
                        and       vollongtemp, ADSRmask
if_z                    mov       vollongtemp, #0
if_nz                   cmp       vollongtemp, #1               wc
if_nz_and_c             or        vollongtemp, attackmask



                            

                        and       vollongtemp, attackmask       nr, wz  'ATTACK  
if_nz                   mov       targetvol, sustainfull
if_nz                   jmp       #attackjump

                        and       vollongtemp, sustainmask      nr, wz  'CHECK IF SHOULD BE SUSTAINING
if_nz                   mov       targetvol, sustain
if_z                    mov       targetvol, #0
attackjump


                        and       voltemp, volmask
                        cmps      voltemp, targetvol        wc
if_c                    adds      voltemp, attack
if_nc                   subs      voltemp, decay
if_nc                   and       vollongtemp, attackmask        nr, wz
if_nc_and_nz            add       vollongtemp, attackmask

                      
                        cmps      voltemp, #0           wc
if_c                    mov       voltemp, #0

                        add       voltemp, vollongtemp
                        wrlong    voltemp, oscPtr

                        add       oscPtr, #4




              
' Update phase increment with new frequency

                        rdlong    phaseinc, noteAddrtemp      
                        wrlong    phaseinc, oscPtr
                        add       noteAddrtemp, #4
                        add       oscPtr, #4

 ' Add phase increment to accumulator of oscillator

                        rdlong    phase, oscPtr
                        add       phase, phaseinc
                        wrlong    phase, oscPtr
                        add       oscPtr, #4

              
' PHASE ACCUMULATOR
' shift and truncate phase to 512 samples

                        shr     phase, #12
'{deferred}             and     phase, #$1FF


' WAVEFORM SELECTOR
' jumps to the appropriate waveform handler

                        add     $+2, waveform       ' $ is the program counter, $+2 is the jumpret instruction, see "Here Symbol" in Propeller Manual
                        and     phase, #$1FF        ' self-modifying code needs a filler instruction,  so this moved here to save space
                        jmpret  $, $+1

                        long    :rampwave, :squarewave, :triwave, :sinewave
                        long    :whitenoise, :sample
 
' RAMP WAVE
' if ramp wave, fit the truncated phase accumulator into
' the proper 8-bit scaling and output as waveform

:rampwave               mov     osctemp, phase
                        subs    osctemp, #256
                        sar     osctemp, #1
                        jmp     #:oscOutput
  
' SQUARE WAVE
' if square wave, compare truncated phase with 128
' (half the height of 8 bits) and scale

:squarewave             cmp     phase, #256             wc
if_nc                   mov     osctemp, #0
if_c                    mov     osctemp, #256
                        subs    osctemp, #128   
                        jmp     #:oscOutput

' TRIANGLE WAVE
' if triangle wave, double the amplitude of a square
' wave and add truncated phase for first half, and
' subtract truncated phase for second half of cycle

:triwave                cmp     phase, #256             wc
if_c                    mov     osctemp, phase
if_nc                   mov     osctemp, #511
if_nc                   subs    osctemp, phase
                        subs    osctemp, #128
                        jmp     #:oscOutput

' SINE WAVE
' if sine wave, use truncated phase to read values
' from sine table in main memory.  This requires
' the most time to complete, with the exception
' of noise generation

:sinewave               mov     Addrtemp, phase
                        and     Addrtemp, #$FF
                        cmp     Addrtemp, #128          wc
if_nc                   xor     Addrtemp, #$FF
                        and     Addrtemp, #$7F

                        shl     Addrtemp, #5
                        add     Addrtemp, sineAddr
                        rdword  osctemp, Addrtemp
                        shr     osctemp, #9

                        cmp     phase, #256             wc              
if_nc                   neg     osctemp, osctemp

                        jmp     #:oscOutput           

' SAMPLER

:sample                 rdword  Addrtemp, sampleAddr
                        add     Addrtemp, phase
                        rdbyte  osctemp, Addrtemp
                        subs    osctemp, #128

                        jmp     #:oscOutput         

' WHITE NOISE GENERATOR
' pseudo-random number generator truncated to 8 bits.

:whitenoise             sar     rand, #1
                        mov     rand2, rand
                        and     rand2, #$FF
                        mov     rand3, rand2
                        shl     rand3, #2
                        xor     rand3, rand2
                        shl     rand3, #24
                        add     rand, rand3

                        mov     osctemp, rand
                        and     osctemp, #$FF

' ADSR MULTIPLIER
' calculates proper volume of this oscillator's sample

:oscOutput              mov     multtemp, osctemp
                        mov     osctemp, #0
                        shr     voltemp, #13 'shift right 10 for sustain then 3 for multiplier
                        
                        and     voltemp, #%00001      nr, wz
if_nz                   add     osctemp, multtemp                             
                        shl     multtemp, #1
                        and     voltemp, #%00010      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     voltemp, #%00100      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     voltemp, #%01000      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     voltemp, #%10000      nr, wz
if_nz                   add     osctemp, multtemp
                            
                        sar     osctemp, #3     '5-2

' SUM 

                        adds    output, osctemp
                        djnz    oscIndex, #oscloop

' Add DC offset for output to PWM

                        adds    output, outputoffset
                        wrlong    output, outputAddr
      
' End of oscillator loop

                        jmp       #mainloop






diraval       long      |< OUTPUTPIN_MONO               'APIN=0
ctraval       long      %00100 << 26 + OUTPUTPIN_MONO   'NCO/PWM APIN=0
period        long      PERIOD1               '800kHz period (_clkfreq / period)
time          long      0

waveform      long      3     '0 = ramp    1 = square    2 = triangle    3 = sine    4 = pseudo-random noise    5 = sine perversion
volume        long      127

halfmask        long    $FFFF
multarg       long      3
multtemp      long      2

attack        long      0
decay         long      0
sustain       long      127 << 10
sustainfull   long      127 << 10
release       long      0
adsrtemp      long      0
targetvol     long      0
volAddrtemp   long      0
voltemp       long      0
vollongtemp   long      0
volmask       long      VOLUMEBITS

keyonmask     long      KEYONBIT
heldmask      long      HELDBIT
ADSRmask      long      ADSRBITS
sustainmask   long      SUSTAINBIT
attackmask    long      ATTACKBIT
bigsusmask    long      $1FC00


doffset       long      D_OFFSET
soffset       long      S_OFFSET
roffset       long      R_OFFSET
woffset       long      W_OFFSET

dmask         long      !D_MASK
smask         long      !S_MASK
rmask         long      !R_MASK
wmask         long      !W_MASK

'variables for oscillator controller
oscPtr        long      0
oscIndex      long      0

phaseinc      long      0
phase         long      0
noteAddrtemp  long      0
notelongtemp  long      0

'oscillator data                                                                                      
oscAddr       long      0
oscTotalRegs  long      OSCREGS
oscTotal      long      OSCILLATORS

'volumeshift   long      1

osctemp       long      0
outputoffset  long      PERIOD1/2
output        long      0

Addr          long      0
Addrtemp      long      0
freqAddr      long      0
outputAddr    long      0
sineAddr      long      $E000
sampleAddr     long      0

paramAddr     long      0
adsrAddr      long      0

rand          long      203943
rand2         long      0
rand3         long      0
              fit 496

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