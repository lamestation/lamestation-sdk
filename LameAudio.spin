OBJ
    pin  :   "LamePinout"
    
CON
    SAMPLES     = 512                                                           ' samples per cycle
    PERIOD      = 80_000_000 / 40_000                                           ' clkfreq / sample rate
    OSCILLATORS = 4                                                             ' hardcoded oscillators used by synthesizer

    #0, _SQUARE, _SAW, _TRIANGLE, _SINE, _NOISE, _SAMPLE                        ' waveform options
    #0, _ATK, _DEC, _SUS, _REL, _WAV, _CONTROL
    #0, _O, _A, _D, _R
    
    ENVELOPE_ON = 1
    KEY_ON = 2
    TRIGGER_ON = 4

DAT
    osc_sample      long    0

    osc_attack      long    $7F7F7F7F
    osc_decay       long    0
    osc_sustain     long    $7F7F7F7F
    osc_release     long    0
    osc_waveform    long    0
    osc_control     long    0

    osc_state       long    0    
    osc_target      long    (127<<12)[4]
    osc_vol         long    (127<<12)[4]
    
    osc_inc         long    0[4]
    osc_acc         long    0[4]    
  
    freqtable       long    439638, 465780, 493477, 522820, 553909, 586846      ' precalculated frequency constants
                    long    621742, 658713, 697882, 739380, 783346, 829926      ' see frequencytiming

PUB null
   
PUB Start

    cognew(@entry, @osc_sample)

{
OBJ    
    gfx : "LameGFX"
    lcd : "LameLCD"
    txt : "LameText"
    fnt : "gfx_font6x8"
    
PUB ConsoleStart
    lcd.Start (gfx.Start)
    txt.Load (fnt.Addr, " ", 6, 8)
    gfx.InvertColor (true)


PUB Console
        gfx.ClearScreen (0)
        txt.Hex (osc_state, 8, 0,0)
        txt.Hex (osc_control, 8, 0,8)
        lcd.DrawScreen
}
PUB SetVolume(channel, value)
    
    osc_vol[channel] := value << 12
    
PUB SetNote(channel, value)
    
    osc_inc[channel] := freqtable[value//12] >> (9 - value/12)
    
PUB SetFrequency(channel, value)
    
    osc_inc[channel] := value

PUB SetParam(channel, type, value)

    byte[@osc_attack[type]][channel] := value
    
PUB SetADSR(channel, attack, decay, sustain, release)
    
    osc_attack.byte[channel]  := attack
    osc_decay.byte[channel]   := decay
    osc_sustain.byte[channel] := sustain
    osc_release.byte[channel] := release
    
PUB SetWaveform(channel, value)
    
    osc_waveform.byte[channel] := value
    
PUB SetEnvelope(channel, enabled)   

    osc_control.byte[channel] &= constant(!ENVELOPE_ON)
    if enabled
        osc_control.byte[channel] |= ENVELOPE_ON
    
PUB StartEnvelope(channel)

    osc_control.byte[channel] := constant(ENVELOPE_ON + KEY_ON + TRIGGER_ON)
    repeat 10
    osc_control.byte[channel] := constant(ENVELOPE_ON + KEY_ON)

PUB StopEnvelope(channel)

    osc_control.byte[channel] := constant(ENVELOPE_ON)
 
PUB SetSample(address)
 
    osc_sample := address

PUB LoadPatch(patchAddr) | i, j, t, c

    c := byte[patchAddr] & $F
        
    repeat j from 0 to 3
        if c & $1
            SetEnvelope(j,1)
            t := patchAddr + 1
            repeat i from _ATK to _WAV
                SetParam(j, i, byte[t++])
        c >>= 1
    
PUB PlaySound(channel, note)
    
    SetEnvelope(channel, 1)
    StartEnvelope(channel)
    SetNote(channel, note)

PUB StopSound(channel)
    
    StopEnvelope(channel)
    
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
                        
                        mov     addr_ctrl, t1                               ' adsr control address
                        add     t1, #4

                        mov     addr_state, t1                              ' adsr state address
                        add     t1, #4
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
                        
                        rdlong  ptr_atk, addr_atk
                        rdlong  ptr_dec, addr_dec
                        rdlong  ptr_sus, addr_sus
                        rdlong  ptr_rel, addr_rel
                        rdlong  ptr_wav, addr_wav
                        rdlong  ptr_ctrl, addr_ctrl

                        mov     ptr_state, addr_state
                        mov     ptr_voltgt, addr_voltgt
                        mov     ptr_vol, addr_vol
                        
                        mov     ptr_inc, addr_inc
                        mov     ptr_acc, addr_acc
                        
loop_channel            call    #routine_adsr
                        call    #routine_phase
                        call    #routine_waveform
                        call    #routine_amplitude
                        
                        shr     ptr_atk,  #8
                        shr     ptr_dec,  #8
                        shr     ptr_sus,  #8
                        shr     ptr_rel,  #8
                        shr     ptr_wav,  #8
                        shr     ptr_ctrl, #8

                        add     ptr_state, #1
                        add     ptr_voltgt,#4
                        add     ptr_vol,   #4
                        
                        add     ptr_inc, #4
                        add     ptr_acc, #4
    
                        djnz    index, #loop_channel

                        adds    out_main, outputoffset                      ' Add DC offset for output to PWM
                        jmp     #loop_main
                        
                       
' ---------------------------------------------------------------
' ADSR Envelope
' ---------------------------------------------------------------    
routine_adsr            rdlong  volume, ptr_vol                             ' get volume parameters
                        rdbyte  state, ptr_state
                        mov     volinc, #10                                 ' needed for volinc calculation.

                        test    ptr_ctrl, #ENVELOPE_ON      wz
        if_z            jmp     #routine_adsr_ret
        
                        test    ptr_ctrl, #TRIGGER_ON       wz
        if_nz           mov     state, #_A
        if_nz           jmp     #:state_O
            
                        test    ptr_ctrl, #KEY_ON           wz
        if_nz           cmp     state, #_A                  wc
        if_nz_and_c     mov     state, #_A

        if_z            cmp     state, #_R                  wc
        if_z_and_c      mov     state, #_R    

                        add     $+2, state                                  ' jumps to the appropriate ADSR phase
                        nop
                        jmpret  $, $+1                                      ' see "Here Symbol" in Propeller Manual

                        long    :state_O, :state_A
                        long    :state_D, :state_R                        
' ---------------------------------------------------------------
:state_O                mov     volume, #0
                        
                        jmp     #:adsr_write
                        
' ``````````````````````````````````````````````````````````````` 
:state_A                mov     voltarget, #127
                        shl     voltarget, #12

                        mov     t1, ptr_atk                                 ' read attack
                        and     t1, #$7F
                        shr     t1, #3
                        shl     volinc, t1

                        cmps    volume, voltarget           wc, wz
            if_b        adds    volume, volinc                              ' if volume < target    volume += osc_volinc
            if_ae       mov     volume, voltarget
            if_ae       mov     state, #_D
                        
                        jmp     #:adsr_write

' ```````````````````````````````````````````````````````````````
:state_D                mov     voltarget, ptr_sus
                        and     voltarget, #$7F
                        shl     voltarget, #12
                        
                        mov     t1, ptr_dec
                        and     t1, #$7F
                        shr     t1, #3
                        shl     volinc, t1
                        
                        cmps    volume, voltarget           wc, wz          ' track downwards
            if_a        subs    volume, volinc                              ' if volume > target    volume -= osc_volinc
            if_be       mov     volume, voltarget

                        jmp     #:adsr_write

' ```````````````````````````````````````````````````````````````
:state_R                mov     voltarget, #0

                        mov     t1, ptr_rel                                 ' read release
                        and     t1, #$7F
                        shr     t1, #3
                        shl     volinc, t1
                        
                        cmps    volume, voltarget           wc, wz          ' track downwards
            if_a        subs    volume, volinc                              ' if volume > target    volume -= osc_volinc
            if_be       mov     volume, voltarget
            if_be       mov     state,  #_O

' ---------------------------------------------------------------
:adsr_write             wrlong  volume, ptr_vol
                        wrbyte  state, ptr_state

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
        
addr_atk        res     1
addr_dec        res     1
addr_sus        res     1
addr_rel        res     1
addr_wav        res     1

addr_state      res     1
addr_ctrl       res     1

addr_voltgt     res     1
addr_vol        res     1

addr_inc        res     1
addr_acc        res     1

ptr_atk         res     1
ptr_dec         res     1
ptr_sus         res     1
ptr_rel         res     1
ptr_wav         res     1

ptr_state       res     1
ptr_ctrl        res     1

ptr_voltgt      res     1
ptr_vol         res     1

ptr_inc         res     1
ptr_acc         res     1

state           res     1
    
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
