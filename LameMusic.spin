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

    songcursor          long    0
    barcursor           long    0
    timeconstant        long    0
                                
    barAddr             word    0
    loopAddr            word    0
                                
    play                byte    0
    replay              byte    0
    stop                byte    0
    barres              byte    0
    transpose           long    0
                                
    LoopingPlayStack    long    0[40]
    songdata            word    0[2]

PUB Start
    cognew(LoopingSongParser, @LoopingPlayStack)
        
PUB LoadSong(songAddr) : n  ' n = alias of result, which initializes to 0, required for songdata[n++]
    
    wordmove(@songdata, songAddr, 2)
    repeat 2
        songdata[n++] += songAddr.word[1]
        
    barAddr := songdata[PATTERN]
    barres := byte[barAddr++]{0}

    loopAddr := songdata[SONG]
    
    songcursor := 0
    barcursor := 0

PUB PlaySong

    play := 1
    replay := 0

PUB LoopSong

    play := 1
    replay := 1
    
PUB StopSong

    replay := 0
    play := 0
    
    stop := 1
    repeat until not stop
    stop := 0
    
PUB SongPlaying

    return play
        
PRI CalculateTimeConstant(bpm)

    return ( clkfreq / bpm * 15 ) ' 60 / 4 for 16th note alignment

PRI LoopingSongParser | repeattime, linecursor, barshift, bartmp
    
    repeat
        repeattime := cnt
        
        if replay
            play := 1
            
        if play
            songcursor := 0
            repeat while byte[loopAddr][songcursor] <> SONGOFF and not stop
    
                if byte[loopAddr][songcursor] & $F0 == ADSRW
                    audio.LoadPatch(loopAddr + songcursor)                 'can't use array notation because loopAddr is word-size
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

                        repeat while byte[loopAddr][songcursor] <> BAROFF and not stop                          
                            barshift := (barres+1)*byte[loopAddr][songcursor]
                            bartmp := barshift+1+linecursor
                            
                            case byte[barAddr][bartmp]
                                SOFF:   audio.StopSound( byte[barAddr][barshift] )
                                0..127: audio.PlaySound( byte[barAddr][barshift] , byte[barAddr][bartmp] + transpose )  'channel, note
                                other:

                            songcursor += 1

                        waitcnt(repeattime += timeconstant)               

                    songcursor += 1

            play := 0
            audio.StopAllSound
        stop := 0

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
