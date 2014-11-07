' LameAudio Synthesizer
' -------------------------------------------------
' Version: 1.0
' Copyright (c) 2013-2014 LameStation LLC
' See end of file for terms of use.
' 
' Authors: Brett Weir
' -------------------------------------------------

OBJ
    pin  :   "Pinout"
    
CON
    SAMPLES     = 512                                                           ' samples per cycle
    PERIOD      = 80_000_000 / 40_000                                           ' clkfreq / sample rate
    OSCILLATORS = 4                                                             ' hardcoded oscillators used by synthesizer

    #0, _SQUARE, _SAW, _TRIANGLE, _SINE, _NOISE, _SAMPLE                        ' waveform options
    #0, _ATK, _DEC, _SUS, _REL, _WAV

DAT
    osc_sample      long    0

    osc_envelope    long    $01010101   
    osc_attack      long    $7F7F7F7F
    osc_decay       long    0
    osc_sustain     long    $7F7F7F7F
    osc_release     long    0
    osc_waveform    long    0
    
    osc_volinc      long    1000[4]                                             ' 1000 is instaneous, 0 is never
    osc_target      long    (127<<12)[4]
    osc_vol         long    0[4]
    
    osc_inc         long    0[4]
    osc_acc         long    0[4]    
  
    freqtable       long    439638, 465780, 493477, 522820, 553909, 586846      ' precalculated frequency constants
                    long    621742, 658713, 697882, 739380, 783346, 829926      ' see frequencytiming

PUB null
   
PUB Start
    cognew(@entry, @osc_sample)    'start assembly cog
    
PUB SetVolume(channel, value)
    
    osc_target.long[channel] := value << 12
    
PUB SetVolumeSpeed(channel, value)
    
    osc_volinc.long[channel] := value << 12

PUB SetNote(channel, value)
    
    osc_inc.long[channel] := long[@freqtable][value//12] >> (9 - value/12)
    
PUB SetFreq(channel, value)
    
    osc_inc.long[channel] := value

PUB SetParam(channel, type, value)
    
    osc_attack.byte[channel + (type << 2)] := value
    
PUB SetADSR(channel, attackvar, decayvar, sustainvar, releasevar)
    
    osc_attack.byte[channel] := attackvar
    osc_decay.byte[channel] := decayvar
    osc_sustain.byte[channel] := sustainvar
    osc_release.byte[channel] := releasevar
    
PUB SetAttack(channel, value)
    
    osc_attack.byte[channel] := value
    
PUB SetRelease(channel, value)

    osc_release.byte[channel] := value

PUB SetWaveform(channel, value)
    
    osc_waveform.byte[channel] := value
    
PUB SetEnvelope(channel, value) | i
   
    osc_envelope.byte[channel] &= !1
    if value
        osc_envelope.byte[channel] |= 1
    
PUB StartEnvelope(channel, enable)
    osc_envelope.byte[channel] &= !2
    if enable
        osc_envelope.byte[channel] |= 2
 
PUB SetSample(value)
    
    osc_sample := value

PUB PlaySound(channel, value)
    
    StartEnvelope(channel, 1)
    SetNote(channel, value)

PUB StopSound(channel)
    
    StartEnvelope(channel, 0)
    
PUB StopAllSound | i

    repeat i from 0 to 3
        StopSound(i)
        
DAT
                        org
' ---------------------------------------------------------------
' Setup
' ---------------------------------------------------------------
entry                   mov     dira, diraval                               ' set APIN to output
                        mov     ctra, ctraval                               ' establish counter A mode and APIN
                        mov     frqa, #1                                    ' set counter to increment 1 each cycle

                        mov     time, cnt                                   ' record current time
                        add     time, periodval                             ' establish next period
                     
                        mov     t1, par                                     ' get parameter address
                        mov     addr_sample, t1                             ' get sample address
                        add     t1, #4

                        mov     addr_env, t1                                ' envelope address
                        add     t1, #4
                        mov     addr_atk, t1                                ' attack address
                        add     t1, #4
                        mov     addr_dec, t1                                ' decay address
                        add     t1, #4
                        mov     addr_sus, t1                                ' sustain address
                        add     t1, #4
                        mov     addr_rel, t1                                ' release address
                        add     t1, #4
                        mov     addr_wav, t1                                ' waveform address
                        add     t1, #4
                        
                        mov     addr_volinc, t1                             ' volume inc address
                        add     t1, #16
                        mov     addr_voltgt, t1                             ' volume target address
                        add     t1, #16
                        mov     addr_vol, t1                                ' volume address
                        add     t1, #16
                        
                        mov     addr_inc, t1                                ' phase inc address
                        add     t1, #16
                        mov     addr_acc, t1                                ' phase acc address
                        
' ---------------------------------------------------------------
' Main Loop
' ---------------------------------------------------------------
loop_main               waitcnt time, periodval                             ' wait until next period
                        neg     phsa, out_main                              ' back up phsa so that it trips "value cycles from now
    
                        mov     out_main, #0                                ' zero out out_main long
                        mov     index, #OSCILLATORS                         ' count number of oscillators
                        
                        rdlong  ptr_env, addr_env
                        rdlong  ptr_atk, addr_atk
                        rdlong  ptr_rel, addr_rel
                        rdlong  ptr_wav, addr_wav
                        
                        mov     ptr_volinc, addr_volinc
                        mov     ptr_voltgt, addr_voltgt
                        mov     ptr_vol, addr_vol
                        
                        mov     ptr_inc, addr_inc
                        mov     ptr_acc, addr_acc
                        
loop_channel            call    #routine_adsr
                        call    #routine_phase
                        call    #routine_waveform
                        call    #routine_amplitude
                        
                        shr     ptr_env, #8
                        shr     ptr_atk, #8
                        shr     ptr_rel, #8
                        shr     ptr_wav, #8
                        
                        add     ptr_volinc, #4
                        add     ptr_voltgt, #4
                        add     ptr_vol, #4
                        
                        add     ptr_inc, #4
                        add     ptr_acc, #4
    
                        djnz    index, #loop_channel

                        adds    out_main, outputoffset                      ' Add DC offset for output to PWM
                        jmp     #loop_main
                        
                       
' ---------------------------------------------------------------
' ADSR Envelope
' ---------------------------------------------------------------    
routine_adsr            mov     envelope, ptr_env
                        test    envelope, #1        wz ' envelope on
                if_nz   jmp     #:adsr_on
' ---------------------------------------------------------------
:adsr_off               rdlong  volinc, ptr_volinc
                        rdlong  voltarget, ptr_voltgt  
                        
                        jmp     #:adsr_tracker
' ---------------------------------------------------------------                          
:adsr_on                test    envelope, #2        wz

                        mov     volinc, #10                                 ' needed for volinc calculation.
                        
            if_z        jmp     #:state_R
' ``````````````````````````````````````````````````````````````` 
:state_A                mov     voltarget, #127
                        
                        mov     t1, ptr_atk                                 ' read attack
                        and     t1, #$FF
                        shr     t1, #3
                        shl     volinc, t1
                        
                        jmp     #:adsr_stateend
' ```````````````````````````````````````````````````````````````
:state_R                mov     voltarget, #0
                        
                        mov     t1, ptr_rel                                 ' read release
                        and     t1, #$FF
                        shr     t1, #4
                        mov     t2, #8
                        sub     t2, t1
                        shl     volinc, t2
                        
' ```````````````````````````````````````````````````````````````
:adsr_stateend          shl     voltarget, #12
      
' ---------------------------------------------------------------         
:adsr_tracker           rdlong  volume, ptr_vol                             ' get volume parameters

                        cmps    volume, voltarget           wc, wz              
            if_b        adds    volume, volinc                              ' if volume < target    volume += volinc
            if_a        subs    volume, volinc                              ' if volume > target    volume -= volinc
            
                        cmps    volume, #0                  wc              ' if volume < 0
            if_b        mov     volume, #0                                  '     volume := 0
                        

                        wrlong  volume, ptr_vol
routine_adsr_ret        ret

' ---------------------------------------------------------------                         
' Phase Accumulator
' --------------------------------------------------------------- 
routine_phase           rdlong  t1, ptr_inc                                 ' Update phase increment with new frequency
                        
                        rdlong  phase, ptr_acc                              ' Add phase increment to accumulator of oscillator
                        add     phase, t1
                        wrlong  phase, ptr_acc

                        shr     phase, #12                                  ' shift and truncate phase to 512 samples
                        and     phase, #$1FF
                        
routine_phase_ret       ret

' --------------------------------------------------------------- 
' Waveform Generator
' --------------------------------------------------------------- 
routine_waveform        mov     t1, ptr_wav
                        and     t1, #$FF

                        add     $+2, t1                                     ' jumps to the appropriate waveform handler
                        nop
                        jmpret  $, $+1                                      ' see "Here Symbol" in Propeller Manual

                        long    :squarewave, :rampwave,   :triwave
                        long    :sinewave,   :whitenoise, :sample
' ```````````````````````````````````````````````````````````````
:squarewave             cmp     phase, #256                 wc              ' if square wave, compare truncated phase with 128
                        negnc   out_osc, #128                               ' (half the height of 8 bits) and scale
                                                                            ' 
                        jmp     #:oscOutput
' ``````````````````````````````````````````````````````````````` 
:rampwave               mov     out_osc, phase                              ' if ramp wave, fit the truncated phase accumulator into
                        subs    out_osc, #256                               ' the proper 8-bit scaling and output as waveform
                        sar     out_osc, #1
                        
                        jmp     #:oscOutput
' ```````````````````````````````````````````````````````````````
:triwave                cmp     phase, #256                 wc              ' if triangle wave, double the amplitude of a square
if_c                    mov     out_osc, phase                              ' wave and add truncated phase for first half, and
if_nc                   mov     out_osc, #511                               ' subtract truncated phase for second half of cycle
if_nc                   subs    out_osc, phase
                        subs    out_osc, #128
                        
                        jmp     #:oscOutput
' ```````````````````````````````````````````````````````````````
:sinewave               mov     t1, phase                                   ' if sine wave, use truncated phase to read values
                        and     t1, #$FF                                    ' from sine table in main memory.  This requires
                        cmp     t1, #128                    wc              ' the most time to complete, with the exception
if_nc                   xor     t1, #$FF                                    ' of noise generation
                        and     t1, #$7F

                        shl     t1, #5
                        add     t1, sineAddr
                        rdword  out_osc, t1
                        shr     out_osc, #9

                        cmp     phase, #256                 wc              
if_nc                   neg     out_osc, out_osc

                        jmp     #:oscOutput
' ```````````````````````````````````````````````````````````````
:whitenoise             sar     rand, #1                                    ' pseudo-random number generator truncated to 8 bits.
                        mov     t1, rand
                        and     t1, #$FF
                        mov     t2, t1
                        shl     t2, #2
                        xor     t2, t1
                        shl     t2, #24
                        add     rand, t2

                        mov     out_osc, rand
                        and     out_osc, #$FF

                        jmp     #:oscOutput
' ```````````````````````````````````````````````````````````````
:sample                 rdword  t1, addr_sample
                        add     t1, phase
                        rdbyte  out_osc, t1
                        subs    out_osc, #128
' ```````````````````````````````````````````````````````````````
:oscOutput
routine_waveform_ret    ret 

' ---------------------------------------------------------------    
' Amplitude
' ---------------------------------------------------------------
routine_amplitude       mov     t1, out_osc
                        mov     t2, volume
                        call    #routine_multiply                           ' result is in tr
                        adds    out_main, tr

routine_amplitude_ret   ret

' ---------------------------------------------------------------
' Unrolled Multiplier
' ---------------------------------------------------------------
routine_multiply        mov     tr, #0
                        shr     t2, #15                                     ' shift right 8 for sustain then 3 for multiplier
                        
                        and     t2, #%00001                 nr, wz
if_nz                   add     tr, t1                             
                        shl     t1, #1
                        and     t2, #%00010                 nr, wz
if_nz                   add     tr, t1
                        shl     t1, #1
                        and     t2, #%00100                 nr, wz
if_nz                   add     tr, t1
                        shl     t1, #1
                        and     t2, #%01000                 nr, wz
if_nz                   add     tr, t1
                        shl     t1, #1
                        and     t2, #%10000                 nr, wz
if_nz                   add     tr, t1
                            
                        sar     tr, #5     '5-2
routine_multiply_ret    ret
    
' ---------------------------------------------------------------
' Variables
' ---------------------------------------------------------------
diraval         long    |< pin#AUDIO                                
ctraval         long    %00100 << 26 + pin#AUDIO                
periodval       long    PERIOD                                              ' period = clkfreq / period

sineAddr        long    $E000
outputoffset    long    PERIOD/2
rand            long    203943

time            res     1
index           res     1  

addr_sample     res     1
        
addr_env        res     1    
addr_atk        res     1
addr_dec        res     1
addr_sus        res     1
addr_rel        res     1
addr_wav        res     1

addr_volinc     res     1
addr_voltgt     res     1
addr_vol        res     1

addr_inc        res     1
addr_acc        res     1


ptr_env         res     1    
ptr_atk         res     1
ptr_rel         res     1
ptr_wav         res     1

ptr_volinc      res     1
ptr_voltgt      res     1
ptr_vol         res     1

ptr_inc         res     1
ptr_acc         res     1


envelope        res     1
attack          res     1
release         res     1
    
volinc          res     1
voltarget       res     1
volume          res     1
phase           res     1

out_main        res     1
out_osc         res     1

t1              res     1
t2              res     1
tr              res     1
' ---------------------------------------------------------------
    
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
