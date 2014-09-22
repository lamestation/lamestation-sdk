{{
LameAudio Synthesizer
-------------------------------------------------
Version: 1.0
Copyright (c) 2013-2014 LameStation LLC
See end of file for terms of use.

Authors: Brett Weir
-------------------------------------------------
}}
OBJ
    pin  :   "Pinout"
    
CON
    PERIOD1 = 2000         ' 'FS = 80MHz / PERIOD1'
    FS      = 40000
    SAMPLES = 512
    OSCILLATORS = 4
    REGPEROSC = 5
    OSCREGS = OSCILLATORS*REGPEROSC
    
    KEYBITS = $180
    HELDBIT = $80
    KEYONBIT = $100

    VOLUMEBITS = $FFFFFF

    ADSRBITS = $3000000 'new
    ATTACKBIT = $1000000
    SUSTAINBIT = $2000000

    #0, _ATK, _DEC, _SUS, _REL, _WAV
    #0, _SQUARE, _SAW, _TRIANGLE, _SINE, _NOISE, _SAMPLE

'NEW LAYOUT
'                        MSB                             LSB
'                      | .----2 bytes----. .-byte-. .-byte-.
'                Note -| 00000000_00000000 00000000 00000000
'                      |      Sample       Waveform   Note 
'     
'                      | .-byte-. .-byte-. .-byte-. .-byte-.
'                ADSR -| 00000000 00000000 00000000 00000000
'                      |     R        S        D        A
'     
'                      | .-byte-. .--------3 bytes---------.
'              Volume -| 00000000 00000000_00000000_00000000
'                      |   State            Volume
'     
'                      | .-------------4 bytes-------------.
'     Phase Increment -| 00000000_00000000_00000000_00000000

'                      | .-------------4 bytes-------------.
'   Phase Accumulator -| 00000000_00000000_00000000_00000000


    '0 - note (last 8 bits)
    '1 - target volume         
    '2 - phase inc
    '3 - phase acc

'OLD REGISTER LAYOUT

    'ADSR register
    ' 4bit   7bit    7bit    7bit    7bit
    ' 0000 0000000 0000000 0000000 0000000
    '  W      R       S       D       A

    'note register
    ' $          ----------- 16 bits ----------
    ' $0000      0000000     0     0    0000000
    '            velocity  keyon  held  notenum

    'target volume register
    ' -- 6bits --    2bit      --------- 24 bits ----------
    '   %0000_00      00       0000_0000 0000_0000 0000_0000
    '              ADSR state         current volume

    'phase inc and acc registers
    ' ----------------- 32 bits -------------
    ' %0000_0000 0000_0000 0000_0000 0000_0000       value to increment
    ' %0000_0000 0000_0000 0000_0000 0000_0000       accumulator
         

VAR

    'ASM data structure (do not mess up)
    long    parameter
    long    channelADSR[2]

    long    oscRegister[OSCREGS]
    
    

    byte    oscindexer
    byte    oscindexcounter
    byte    oscoffindexer

    word    sample

PUB null
    
PUB Start
      
    parameter := @freqTable + (@sample<<16)
    
    cognew(@oscmodule, @parameter)    'start assembly cog
    cognew(LoopingSongParser, @LoopingPlayStack)

PUB SetParam(type, value)
    channelADSR.byte[type] := value

PUB SetADSR(attackvar, decayvar, sustainvar, releasevar)
    SetParam(_ATK, attackvar)
    SetParam(_DEC, decayvar)
    SetParam(_SUS, sustainvar)
    SetParam(_REL, releasevar)

PUB SetSample(samplevar)
    sample := samplevar

PUB PlaySound(channel, note)
    if note < 128 and channel < OSCILLATORS
        oscindexer := channel << 2
        oscRegister[oscindexer] &= !KEYBITS          
        oscRegister[oscindexer+1] &= !ADSRBITS
        oscRegister[oscindexer] := note + KEYBITS

PUB StopSound(channel)

    if channel < OSCILLATORS
        oscindexer := channel << 2          
        oscRegister[oscindexer] &= !KEYBITS 

PUB StopAllSound

    repeat oscindexer from 0 to OSCREGS-1 step REGPEROSC
        oscRegister[oscindexer] &= !KEYBITS

CON
    SONGOFF = $80
    BAROFF  = $81
    SNOP    = $82
    SOFF    = $83
    
    ADSRW   = $A0
    TEMPO   = $B0
    TRANS   = $C0
        
    #0, PATTERN, SONG
    
VAR
    long    songcursor
    long    barcursor
    long    timeconstant
    
    word    barAddr
    word    loopAddr     '' This value points to the first address of the song definition in a song

    byte    play
    byte    replay
    byte    stop
    byte    barres
    word    bartmp
    long    transpose

    word    barshift
    byte    linecursor

    long    LoopingPlayStack[20]
    word    songdata[2]
    
PUB LoadPatch(patchAddr, number)
    SetParam(_ATK,byte[++patchAddr])
    SetParam(_DEC,byte[++patchAddr])
    SetParam(_SUS,byte[++patchAddr])
    SetParam(_REL,byte[++patchAddr])
    SetParam(_WAV,byte[++patchAddr])
    
PUB LoadSong(songAddr) : n  ' n = alias of result, which initializes to 0, required for songdata[n++]
    
    wordmove(@songdata, songAddr,3)
    repeat 2
        songdata[n++] += songAddr.word[1]
        
    barAddr := songdata[PATTERN]
    barres := byte[barAddr++]{0}

    loopAddr := songdata[SONG]
    
    songcursor := 0
    barcursor := 0

PUB SetTranspose(transvar)
    transpose := transvar
    
PUB SetSpeed(speed)
    timeconstant := CalculateTimeConstant( speed )
    
PUB PlaySong
    play := 1
    replay := 0

PUB LoopSong
    play := 1
    replay := 1
    
PUB StopSong
    play := 0
    replay := 0
    stop := 1
    
PUB SongPlaying
    return play
        
PRI CalculateTimeConstant(bpm)
    return ( clkfreq / bpm * 15 ) ' 60 / 4 for 16th note alignment

PRI LoopingSongParser | repeattime
    
    repeat
        repeattime := cnt
        
        if replay
            play := 1
            
        if play and not stop
            songcursor := 0
            repeat while byte[loopAddr][songcursor] <> SONGOFF and play and not stop
    
                if byte[loopAddr][songcursor] & $F0 == ADSRW
                    LoadPatch(loopAddr + songcursor, 0)                 'can't use array notation because loopAddr is word-size
                    songcursor += 6
                    next
                        
                if byte[loopAddr][songcursor] & $F0 == TEMPO
                    timeconstant := CalculateTimeConstant(byte[loopAddr][songcursor+1])
                    songcursor += 2
                    next

                if byte[loopAddr][songcursor] & $F0 == TRANS
                    transpose := byte[loopAddr][songcursor+1]
                    songcursor += 2
                    next
                            
                else
                    barcursor := songcursor
                    repeat linecursor from 0 to (barres-1)
                        if stop
                            quit
                    
                        songcursor := barcursor

                        repeat while byte[loopAddr][songcursor] <> BAROFF and play                             
                            barshift := (barres+1)*byte[loopAddr][songcursor]
                            bartmp := barshift+1+linecursor
                            
                            case byte[barAddr][bartmp]
                                SOFF:   StopSound( byte[barAddr][barshift] )
                                0..127: PlaySound( byte[barAddr][barshift] , byte[barAddr][bartmp] + transpose )  'channel, note
                                other:

                            songcursor += 1

                        waitcnt(repeattime += timeconstant)               

                    songcursor += 1

            play := 0
            StopAllSound
        stop := 0



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

oscmodule               mov     dira, diraval                           ' set APIN to output
                        mov     ctra, ctraval                           ' establish counter A mode and APIN
                        mov     frqa, #1                                ' set counter to increment 1 each cycle

                        mov     time, cnt                               ' record current time
                        add     time, period                            ' establish next period

                        ' Establish communication between cog and spin

                        mov     Addr, par                               ' get address of frequency table

                        rdword  freqAddr, Addr                          ' get frequency table address
                        add     Addr, #2
                        rdword  sampleAddr, Addr                        ' get sample address
                        add     Addr, #2                   
                        mov     adsrAddr, Addr                          ' get adsr parameters
                        add     Addr, #8
                        mov     oscAddr, Addr                           ' get oscillator registers


' MAINLOOP ======================================================
mainloop                waitcnt time, period                            ' wait until next period
                        neg     phsa, output                            ' back up phsa so that it trips "value cycles from now

                        
                        rdbyte  attack, adsrAddr                        ' read attack
                        add     adsrAddr, #1

                        mov     output, #0                              ' filler (1/3)

                        rdbyte  decay, adsrAddr
                        add     adsrAddr, #1

                        mov     oscIndex, oscTotal                      ' filler (2/3)

                        rdbyte  sustain, adsrAddr
                        add     adsrAddr, #1

                        mov     oscPtr, oscAddr                         ' filler (3/3)

                        rdbyte  release, adsrAddr
                        add     adsrAddr, #1
    
                        rdbyte  waveform, adsrAddr
                        
                            
                        sub     adsrAddr, #4

    
                        
' OSCLOOP -------------------------------------------------------                   
oscloop                 rdlong  noteAddrtemp, oscPtr                    ' Get frequency from note value using table lookup

                        and     noteAddrtemp, keyonmask         nr, wz  'SET Z FLAG FOR LATER OPERATION, REMEMBER!!!

                        and     noteAddrtemp, #$7F
                        shl     noteAddrtemp, #2
                        add     noteAddrtemp, freqAddr
                        add     oscPtr, #4
                                                
                        'ADSR FILTER (or in this case, ADS filter?)
                       
                        rdlong  voltemp, oscPtr
                        mov     vollongtemp, voltemp

                        'since Z flag still set from previous operation, no extra instructions needed
                        
                        and     vollongtemp, ADSRmask
if_z                    mov     vollongtemp, #0
if_nz                   cmp     vollongtemp, #1                 wc
if_nz_and_c             or      vollongtemp, attackmask



                            

                        and     vollongtemp, attackmask         nr, wz  'ATTACK  
if_nz                   mov     targetvol, sustainfull
if_nz                   jmp     #attackjump

                        and     vollongtemp, sustainmask        nr, wz  'CHECK IF SHOULD BE SUSTAINING
if_nz                   mov     targetvol, sustain
if_z                    mov     targetvol, #0
attackjump


                        and     voltemp, volmask
                        cmps    voltemp, targetvol              wc
if_c                    adds    voltemp, attack
if_nc                   subs    voltemp, decay
if_nc                   and     vollongtemp, attackmask         nr, wz
if_nc_and_nz            add     vollongtemp, attackmask

                      
                        cmps    voltemp, #0                     wc
if_c                    mov     voltemp, #0

                        add     voltemp, vollongtemp
                        wrlong  voltemp, oscPtr

                        add     oscPtr, #4




              
                        ' Update phase increment with new frequency
                        rdlong  phaseinc, noteAddrtemp      
                        wrlong  phaseinc, oscPtr
                        add     noteAddrtemp, #4
                        add     oscPtr, #4

                        ' Add phase increment to accumulator of oscillator

                        rdlong  phase, oscPtr
                        add     phase, phaseinc
                        wrlong  phase, oscPtr
                        add     oscPtr, #4

              
' PHASE ACCUMULATOR
' -------------------------------------------------------------
' shift and truncate phase to 512 samples

                        shr     phase, #12
'{deferred}             and     phase, #$1FF


' WAVEFORM SELECTOR
' -------------------------------------------------------------
' jumps to the appropriate waveform handler

                        add     $+2, waveform       ' $ is the program counter, $+2 is the jumpret instruction, see "Here Symbol" in Propeller Manual
                        and     phase, #$1FF        ' self-modifying code needs a filler instruction,  so this moved here to save space
                        jmpret  $, $+1

                        long    :squarewave, :rampwave, :triwave, :sinewave
                        long    :whitenoise, :sample
 

  
                        ' SQUARE WAVE
                        ' if square wave, compare truncated phase with 128
                        ' (half the height of 8 bits) and scale

:squarewave             cmp     phase, #256             wc
if_nc                   mov     osctemp, #0
if_c                    mov     osctemp, #256
                        subs    osctemp, #128   
                        jmp     #:oscOutput

    
                        ' RAMP WAVE
                        ' if ramp wave, fit the truncated phase accumulator into
                        ' the proper 8-bit scaling and output as waveform

:rampwave               mov     osctemp, phase
                        subs    osctemp, #256
                        sar     osctemp, #1
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

                        jmp     #:oscOutput 
                                
                        ' SAMPLER

:sample                 rdword  Addrtemp, sampleAddr
                        add     Addrtemp, phase
                        rdbyte  osctemp, Addrtemp
                        subs    osctemp, #128
    
' ADSR MULTIPLIER
' -------------------------------------------------------------
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
' OSCLOOP END ---------------------------------------------------
                        
                        adds    output, outputoffset                ' Add DC offset for output to PWM
      
                        ' End of oscillator loop
                        jmp     #mainloop
' MAINLOOP END ==================================================


diraval       long      |< pin#AUDIO                'APIN=0
ctraval       long      %00100 << 26 + pin#AUDIO    'NCO/PWM APIN=0
period        long      PERIOD1                     '800kHz period (_clkfreq / period)
time          long      0


attack        long      0
decay         long      0
sustain       long      127 << 10
sustainfull   long      127 << 10
release       long      0
waveform      long      _SINE    

multtemp      long      2

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

'variables for oscillator controller
oscPtr        long      0
oscIndex      long      0

phaseinc      long      0
phase         long      0
noteAddrtemp  long      0

'oscillator data                                                                                      
oscAddr       long      0
oscTotal      long      OSCILLATORS

osctemp       long      0
outputoffset  long      PERIOD1/2
output        long      0

Addr          long      0
Addrtemp      long      0
freqAddr      long      0
outputAddr    long      0
sineAddr      long      $E000
sampleAddr     long      0

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
