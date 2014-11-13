' LameMusic Song Player Module
'   Extends:    LameAudio
' -------------------------------------------------
' Version: 1.0
' Copyright (c) 2013-2014 LameStation LLC
' See end of file for terms of use.
' 
' Authors: Brett Weir
' -------------------------------------------------
' NOTE: Start LameAudio before calling LameMusic
' functionality

OBJ

    audio   :   "LameAudio"

CON

    SONGOFF = $80
    BAROFF  = $81
    SNOP    = $82
    SOFF    = $83
    
    ADSRW   = $A0
    TEMPO   = $B0
    TRANS   = $C0
        
    #0, PATTERN, SONG
    
DAT
    MusicPlayerStack    long    0[40]

    ptr_song            long    0
    ptr_pattern         long    0
    timeconstant        long    0
    transpose           long    0

    songdata            word    0[2]
    addr_pattern        word    0
    addr_song           word    0

    sig_play            byte    0
    sig_replay          byte    0
    sig_stop            byte    0
    barres              byte    0

PUB Start
    cognew(MusicPlayer, @MusicPlayerStack)
        
PUB Load(songAddr) : n
    ' n = alias of result, which initializes to 0, required for songdata[n++]
    Stop
    
    wordmove(@songdata, songAddr, 2)
    repeat 2
        songdata[n++] += songAddr.word[1]
        
    addr_pattern := songdata[PATTERN]
    barres := byte[addr_pattern++]{0}

    addr_song := songdata[SONG]
    
    ptr_song := 0
    ptr_pattern := 0

PUB Play

    sig_play := 1
    sig_replay := 0

PUB Loop

    sig_play := 1
    sig_replay := 1
    
PUB Stop

    sig_replay := 0
    sig_play := 0
    
    sig_stop := 1
    repeat until not sig_stop
    sig_stop := 0
    
PUB IsPlaying

    return sig_play
        
PRI CalculateTimeConstant(bpm)

    return ( clkfreq / bpm * 15 ) ' 60 / 4 for 16th note alignment

PRI MusicPlayer | repeattime, linecursor, barshift, bartmp
    
    repeat
        repeattime := cnt
        
        if sig_replay
            sig_play := 1
            
        if sig_play
            ptr_song := 0
            
            repeat while byte[addr_song][ptr_song] <> SONGOFF and not sig_stop
    
                if byte[addr_song][ptr_song] & $F0 == ADSRW
                    audio.LoadPatch(addr_song + ptr_song)               ' can't use array notation because addr_song is word-size
                    ptr_song += 6
                    next
                        
                if byte[addr_song][ptr_song] & $F0 == TEMPO
                    timeconstant := CalculateTimeConstant(byte[addr_song][ptr_song+1])
                    ptr_song += 2
                    next

                if byte[addr_song][ptr_song] & $F0 == TRANS
                    transpose := byte[addr_song][ptr_song+1]
                    ptr_song += 2
                    next
                            
                else
                    ptr_pattern := ptr_song
                    repeat linecursor from 0 to (barres-1)
                        if sig_stop
                            quit
                    
                        ptr_song := ptr_pattern

                        repeat while byte[addr_song][ptr_song] <> BAROFF and not sig_stop                          
                            barshift := (barres+1)*byte[addr_song][ptr_song]
                            bartmp := barshift+1+linecursor
                            
                            case byte[addr_pattern][bartmp]
                                SOFF:   audio.StopSound( byte[addr_pattern][barshift] )
                                0..127: audio.PlaySound( byte[addr_pattern][barshift] , byte[addr_pattern][bartmp] + transpose )  'channel, note
                                other:

                            ptr_song += 1

                        waitcnt(repeattime += timeconstant)               

                    ptr_song += 1

            sig_play := 0
            audio.StopAllSound
        sig_stop := 0

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
