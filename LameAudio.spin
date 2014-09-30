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
    SAMPLES     = 512                                           ' samples per cycle
    PERIOD      = 80_000_000 / 40_000                           ' clkfreq / sample rate
    OSCILLATORS = 4                                             ' hardcoded oscillators used by synthesizer

    #0, _SQUARE, _SAW, _TRIANGLE, _SINE, _NOISE, _SAMPLE        ' waveform options
                                                                ' 
    #0, _OFF, _A, _D, _S, _R                                    ' ADSR states
                                                                ' 
    #0, _ATK, _DEC, _SUS, _REL, _WAV, _STATE                    ' control registers per oscillator

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
    
    osc_attack      long    0
    osc_decay       long    0
    osc_sustain     long    0
    osc_release     long    0
    osc_waveform    long    0
    osc_state       long    0
    
    osc_volinc      long    0[4]
    osc_target      long    0[4]
    osc_vol         long    (127<<8)[4]
    osc_inc         long    0[4]
    osc_acc         long    0[4]
        
    osc_sample      word    0
  
    freqtable       long    439638, 465780, 493477, 522820, 553909, 586846      '   precalculated frequency constants
                    long    621742, 658713, 697882, 739380, 783346, 829926      '   see frequencytiming
    
PUB null
    
PUB Start
      
    parameter := @freqTable + (@osc_sample << 16)
    cognew(@oscmodule, @parameter)    'start assembly cog

PUB SetVolume(channel, value)
    
    osc_vol.long[channel] := value << 8

PUB SetNote(channel, value)
    
    osc_inc.long[channel] := long[@freqtable][value//12] >> (9 - value/12)
    
PUB SetFreq(channel, value)
    
    osc_inc.long[channel] := value                                              ' setting the phase increment to zero
                                                                                ' stops the oscillator.
PUB SetParam(channel, type, value)
    
    osc_attack.byte[(type << 2) + channel] := value

PUB SetADSR(channel, attackvar, decayvar, sustainvar, releasevar)
    
    SetParam(channel, _ATK, attackvar)
    SetParam(channel, _DEC, decayvar)
    SetParam(channel, _SUS, sustainvar)
    SetParam(channel, _REL, releasevar)

PUB SetWaveform(channel, value)
    
    SetParam(channel, _WAV, value)
    
PUB SetSample(value)
    
    osc_sample := value

PUB PlaySound(channel, value)
    
    SetNote(channel, value)

PUB StopSound(channel)
    
    SetFreq(channel, 0)
    
PUB StopAllSound | i

    repeat i from 0 to 3
        SetFreq(i, 0)

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

                        mov     phsAddr, oscAddr                        ' get phase accumulator register address
                        add     phsAddr, #24
    
' MAINLOOP ======================================================
mainloop                waitcnt time, periodval                         ' wait until next period
                        neg     phsa, output                            ' back up phsa so that it trips "value cycles from now
    
                        mov     output, #0                              ' zero out output long
                        mov     oscIndex, #OSCILLATORS                  ' count number of oscillators
                        
                        mov     phsPtr, phsAddr
           
' OSCLOOP -------------------------------------------------------                   
oscloop                 mov     oscPtr, #OSCILLATORS
                        sub     oscPtr, oscIndex
                        add     oscPtr, oscAddr
                        
                        ' get note controllers

                        add     oscPtr, #16
{{                        rdbyte  attack, oscPtr
                        add     oscPtr, #4
                        rdbyte  decay, oscPtr
                        add     oscPtr, #4
                        rdbyte  sustain, oscPtr
                        add     oscPtr, #4
                        rdbyte  release, oscPtr
                        add     oscPtr, #4
                    }}                        
                        rdbyte  waveform, oscPtr
                        add     oscPtr, #4
                        rdbyte  state, oscPtr
                                                    
' ENVELOPE CONTROL
                        rdlong  volinc, phsPtr
                        add     phsPtr, #16
                        rdlong  voltarget, phsPtr
                        add     phsPtr, #16
                        rdlong  volume, phsPtr                          ' get volume parameters
                                                                        ' 
                 '       cmp     volume, voltarget
                  '      add     phase, phaseinc
                        'mov     volume, sustainfull
                       ' wrlong  volume, phsPtr
                        add     phsPtr, #16
                        
' PHASE ACCUMULATOR
' shift and truncate phase to 512 samples

                        ' Update phase increment with new frequency
                        rdlong  phaseinc, phsPtr
                        add     phsPtr, #16

                        ' Add phase increment to accumulator of oscillator
                        rdlong  phase, phsPtr
                        add     phase, phaseinc
                        wrlong  phase, phsPtr
                        
                        sub     phsPtr, #60

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

:squarewave             cmp     phase, #256                 wc
                        negnc   osctemp, #128
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

:triwave                cmp     phase, #256                 wc
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
                        cmp     Addrtemp, #128              wc
if_nc                   xor     Addrtemp, #$FF
                        and     Addrtemp, #$7F

                        shl     Addrtemp, #5
                        add     Addrtemp, sineAddr
                        rdword  osctemp, Addrtemp
                        shr     osctemp, #9

                        cmp     phase, #256                 wc              
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
                        shr     volume, #11 'shift right 8 for sustain then 3 for multiplier
                        
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

'sustainfull     long    127 << 8
        
'variables for oscillator controller
outputoffset    long    PERIOD/2
oscIndex        long    0

multtemp        long    2
output          long    0

rand            long    203943

' temporary control registers      
oscAddr         res     1
phsAddr         res     1

oscPtr          res     1
phsPtr          res     1

attack          res     1
decay           res     1
sustain         res     1
release         res     1
waveform        res     1
state           res     1
    
volinc          res     1
voltarget       res     1
volume          res     1
phaseinc        res     1
phase           res     1

sample          res     1

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
