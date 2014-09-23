' LameAudio Synthesizer
' -------------------------------------------------
' Version: 1.0
' Copyright (c) 2013-2014 LameStation LLC
' See end of file for terms of use.
' 
' Authors: Brett Weir
' -------------------------------------------------
' Can be extended with:
'   LameMusic
'   LameSFX
'   LameMIDI

OBJ

    pin  :   "Pinout"
    
CON
    SAMPLES     = 512
    PERIOD      = 80_000_000 / 40_000                           ' clkfreq / sample rate
    OSCILLATORS = 4

    #0, _SQUARE, _SAW, _TRIANGLE, _SINE, _NOISE, _SAMPLE        ' waveform options
                                                                ' 
    #0, _OFF, _A, _D, _S, _R                                    ' ADSR states
                                                                ' 
    #0, _NOTE, _TRANS, _ATK, _DEC, _SUS, _REL, _WAV, _STATE     ' control registers per oscillator

'                   LSB|  osc 1   |   osc 2  |   osc 3  |  osc 4   |MSB
'                      |-------------------------------------------|
'    (byte)      Note -| 00000000 | 00000000 | 00000000 | 00000000 |
'            Tranpose -| 00000000 | 00000000 | 00000000 | 00000000 |
'                      |          |          |          |          |
'              Attack -| 00000000 | 00000000 | 00000000 | 00000000 |
'               Decay -| 00000000 | 00000000 | 00000000 | 00000000 |
'             Sustain -| 00000000 | 00000000 | 00000000 | 00000000 |
'             Release -| 00000000 | 00000000 | 00000000 | 00000000 |
'                      |          |          |          |          |
'            Waveform -| 00000000 | 00000000 | 00000000 | 00000000 |
'               State -| 00000000 | 00000000 | 00000000 | 00000000 |
'                      |-------------------------------------------|

DAT

    parameter       long    0
    
    osc_note        long    0
    osc_trans       long    0
    osc_attack      long    0
    osc_decay       long    0
    osc_sustain     long    0
    osc_release     long    0
    osc_waveform    long    0
    osc_state       long    0
    
    osc_volume      long    0[2]
    
    osc_acc         long    0[4]
    osc_inc         long    0[4]
    
    osc_sample      word    0

PUB null
    
PUB Start
      
    parameter := @freqTable + (@osc_sample << 16)
    cognew(@oscmodule, @parameter)    'start assembly cog

PUB SetFreq(channel, value)
    

PUB SetParam(channel, type, value)
    
    osc_note.byte[(type << 2) + channel] := value

PUB SetADSR(channel, attackvar, decayvar, sustainvar, releasevar)
    
    SetParam(channel, _ATK, attackvar)
    SetParam(channel, _DEC, decayvar)
    SetParam(channel, _SUS, sustainvar)
    SetParam(channel, _REL, releasevar)

PUB SetWaveform(channel, value)
    
    SetParam(channel, _WAV, value)
    
PUB SetSample(value)
    
    osc_sample := value

PUB PlaySound(channel, value) | i
    
    osc_note.byte[channel] := value
    osc_state.byte[channel] := 0

PUB StopSound(channel)
    
    osc_note.byte[channel] := -1
    
PUB StopAllSound | i

    repeat i from 0 to 3
        osc_note.byte[i] := -1  
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
                        add     time, periodval                         ' establish next period

                        mov     oscAddr, par                            ' get parameter address
                        rdlong  freqAddr, oscAddr                       ' get frequency table address
                        mov     sample, freqAddr                        ' get sample address
                        and     freqAddr, halfmask
                        shr     sample, #16
                        add     oscAddr, #4
                                           
                        mov     volAddr, oscAddr                        ' get volume register address
                        add     volAddr, #32
                        mov     phsAddr, volAddr                        ' get phase accumulator register address
                        add     phsAddr, #8
    
' MAINLOOP ======================================================
mainloop                waitcnt time, periodval                         ' wait until next period
                        neg     phsa, output                            ' back up phsa so that it trips "value cycles from now
    
                        mov     output, #0                              ' zero out output long
                        mov     oscIndex, #OSCILLATORS                  ' count number of oscillators
                        
                        mov     volPtr, volAddr
                        mov     phsPtr, phsAddr
           
' OSCLOOP -------------------------------------------------------                   
oscloop                 mov     oscPtr, #OSCILLATORS
                        sub     oscPtr, oscIndex
                        add     oscPtr, oscAddr
                        
                        ' get note controllers
                        rdbyte  note, oscPtr
                        add     oscPtr, #8
'                        rdbyte  transp, oscPtr
 '                       add     oscPtr, #4
                        rdbyte  attack, oscPtr
                        add     oscPtr, #4
                        rdbyte  decay, oscPtr
                        add     oscPtr, #4
                        
                        rdbyte  sustain, oscPtr
                        add     oscPtr, #8
'                        rdbyte  release, oscPtr
 '                       add     oscPtr, #4
                        rdbyte  waveform, oscPtr
                        add     oscPtr, #4
                        rdbyte  state, oscPtr
                        
    
' FREQUENCY LOOKUP
                        and     note, #$80                  nr, wz      ' (filler) ' SET Z FLAG FOR LATER OPERATION, REMEMBER!!!
                        and     note, #$7F
                        shl     note, #2
                        add     note, freqAddr
                        
                                             
' ENVELOPE CONTROL
                        rdword  volume, volPtr                          ' get volume parameters
                        
if_nz                   mov     state, #0
if_z                    cmp     state, #1                   wc
if_z_and_c              or      state, #1

                        and     state, #1                   nr, wz      ' ATTACK  
if_nz                   mov     targetvol, sustainfull
if_nz                   jmp     #attackjump

                        and     state, #2                   nr, wz      ' CHECK IF SHOULD BE SUSTAINING
if_nz                   mov     targetvol, sustain
if_nz                   shl     targetvol, #8
if_z                    mov     targetvol, #0

attackjump
                        cmps    volume, targetvol           wc
if_c                    adds    volume, attack
if_nc                   subs    volume, decay
if_nc                   and     state, #1                   nr, wz
if_nc_and_nz            add     state, #1

                      
                        cmps    volume, #0                 wc
if_c                    mov     volume, #0

                        wrbyte  state, oscPtr
                        wrword  volume, volPtr
                        add     volPtr, #2
                        
' PHASE ACCUMULATOR
' shift and truncate phase to 512 samples

                        ' Update phase increment with new frequency
                        rdlong  phaseinc, note   
                        wrlong  phaseinc, phsPtr
                        add     phsPtr, #16

                        ' Add phase increment to accumulator of oscillator
                        rdlong  phase, phsPtr
                        add     phase, phaseinc
                        wrlong  phase, phsPtr
                        
                        sub     phsPtr, #12

                        shr     phase, #12
'{deferred}             and     phase, #$1FF


' WAVEFORM SELECTOR
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

:sample                 rdword  Addrtemp, sample
                        add     Addrtemp, phase
                        rdbyte  osctemp, Addrtemp
                        subs    osctemp, #128
    
' ADSR MULTIPLIER
' calculates proper volume of this oscillator's sample

:oscOutput              mov     multtemp, osctemp
                        mov     osctemp, #0
                        shr     volume, #13 'shift right 10 for sustain then 3 for multiplier
                        
                        and     volume, #%00001      nr, wz
if_nz                   add     osctemp, multtemp                             
                        shl     multtemp, #1
                        and     volume, #%00010      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     volume, #%00100      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     volume, #%01000      nr, wz
if_nz                   add     osctemp, multtemp
                        shl     multtemp, #1
                        and     volume, #%10000      nr, wz
if_nz                   add     osctemp, multtemp
                            
                        sar     osctemp, #3     '5-2

' SUM 

                        adds    output, osctemp

                        djnz    oscIndex, #oscloop
' OSCLOOP END ---------------------------------------------------
                        
                        adds    output, outputoffset                ' Add DC offset for output to PWM
                        jmp     #mainloop
' MAINLOOP END ==================================================


diraval         long    |< pin#AUDIO                ' APIN=0
ctraval         long    %00100 << 26 + pin#AUDIO    ' NCO/PWM APIN=0
periodval       long    PERIOD                      ' period = clkfreq / period
time            long    0



Addrtemp        long    0
freqAddr        long    0
sineAddr        long    $E000
halfmask        long    $FFFF

sustainfull     long    127 << 8
        
'variables for oscillator controller
outputoffset    long    PERIOD/2
oscIndex        long    0

    
multtemp        long    2
output          long    0

rand            long    203943

' temporary control registers      
oscAddr         res     1
volAddr         res     1
phsAddr         res     1

oscPtr          res     1
volPtr          res     1
phsPtr          res     1
    
note            res     1
waveform        res     1
state           res     1
transp          res     1

attack          res     1
decay           res     1
sustain         res     1

release         res     1

sample          res     1
volume          res     1
targetvol       res     1

phaseinc        res     1
phase           res     1

osctemp         res     1

rand2           res     1
rand3           res     1
    
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
