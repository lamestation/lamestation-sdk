---
layout: learnpage
title: Music
--- 

 Music

LameStation uses a custom, loop-based song format that has a very small
footprint, allowing more songs to be included in a given game.

-   [Syntax](#Music-Syntax)
-   [Description](#Music-Description)
    -   [The Header](#Music-TheHeader)
    -   [Loop Definitions](#Music-LoopDefinitions)
    -   [Song Definition](#Music-SongDefinition)
    -   [Footer](#Music-Footer)
-   [Example](#Music-Example)

# Syntax

    song
     
    ' header
    byte    BARS
    byte    TEMPO
    byte    NOTES_PER_BAR
     
    ' bars
    byte    CHANNEL, NOTE, NOTE, ... , NOTE
    byte    CHANNEL, NOTE, NOTE, ... , NOTE
     
    ' song
    byte    BAR, [BAR, BAR...], BAROFF
    ...
    ...
    ...
    byte    BAR, [BAR, BAR...], BAROFF
     
    byte    SONGOFF

-   `           BARS         ` - Number of bars defined in the song
-   `           TEMPO         ` - The tempo of the song in beats per
    minute. Max value: 255.
-   `           NOTES_PER_BAR         ` - The number of notes in each
    bar. To save space, this format assumes all notes are the same
    granularity, and each line has however many notes you define. Common
    values include:
    -   4/4 -\> 8, 16, 4
    -   3/4 -\> 6, 12
    -   12/8 -\> 12
    -   Arbitrary amounts -\> 3, 7, 13
-   `           CHANNEL         ` - The synthesizer channel to send the
    notes to (see [Audio
    Stuff](https://lamestation.atlassian.net/wiki/display/DEV/Audio+Stuff)
    for more info).
-   `           NOTE         ` - The note number between C0 and C12 (see
    [MIDI Note
    Chart](https://lamestation.atlassian.net/wiki/display/DEV/MIDI+Note+Chart)
    ). Valid note range is between 0-127. Values 128-255 are considered
    control values and may have special meaning (see table below).

# Description

## The Header

The first part of every song is the header, which contains information
describing how the song should be played.

    titleScreenSong
    byte    15     'number of bars
    byte    28    'tempo
    byte     8      'notes per bar

## Loop Definitions

Second is the definition of loops that are used in the song. The first
byte tells the parser on which note channel to play that loop on; this
prevents conflicts between different loops.

**Special Note Codes**

Name

Value

Meaning

SNOFF

\$FC

End the currently playing note.

SNOP

\$FD

Indicates no change / do nothing.

BAROFF

\$FE

End of song line.

SONGOFF

\$FF

End of song.

Do not forget: every single line is a loop. When referenced later, they
are referred to by line.

    'ROOT BASS
    byte    0, 36,SOFF,  36,SOFF,   34,  36,SOFF,  34
    byte    1, 24,SOFF,  24,SOFF,   22,  24,SOFF,  22
    'DOWN TO SAD
    byte    0, 32,SNOP,  32,SOFF,   31,  32,SOFF,  31
    byte    1, 20,SNOP,  20,SOFF,   19,  20,SOFF,  19 
    'THEN FOURTH
    byte    0, 29,SNOP,  29,SOFF,   27,  29,SOFF,  27
    byte    1, 17,SNOP,  17,SOFF,   15,  17,SOFF,  15
    byte    2,   48,SNOP,SOFF,  50, SNOP,SOFF,  51,SNOP
    byte    2, SNOP,SOFF,  48,SNOP,   51,SNOP,  48,SNOP
    byte    2,   53,SNOP,SNOP,  51, SNOP,SNOP,  50,SNOP
    byte    2, SNOP,  51,SNOP,SNOP,   50,  51,  50,SNOP  
    'melody
    byte    2,   48,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
    byte    2, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF      
    'harmonies
    byte    3,   44,SNOP,SNOP,  43, SNOP,SNOP,  41,SNOP
    byte    3, SNOP,  39,SNOP,SNOP,   38,SNOP,SNOP,SNOP
    byte    3, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF

## Song Definition

Thirdly is the song definition. This is where the previous 8-note loops
are linked together and made into meaningful music. Each line is a
string of bytes that ends in a BAROFF byte. This allows as many loops to
be played on top of each other as needed, but keep in mind that you are
limited by the number of voices the oscillator can play (specified by
the VOICES constant in LameAudio), which is 4 by default.

With adjustments to frequency timing, it is possible to increase the
number of voices, but it is not recommended. Also, the number of voices
must be a power of 2 as bitmasking is used by the code.

    'SONG ------
    byte 0,BAROFF
    byte 0,BAROFF
    byte 0,BAROFF
    byte 0,BAROFF
    byte 0,1,BAROFF
    byte 0,1,BAROFF
    byte 0,1,BAROFF
    byte 0,1,BAROFF
    'verse 
    byte 0,1,6,BAROFF
    byte 0,1,7,BAROFF
    byte 0,1,8,BAROFF
    byte 0,1,9,BAROFF
    byte 2,3,10,12,BAROFF
    byte 2,3,13,BAROFF
    byte 4,5,BAROFF
    byte 4,5,11,14,BAROFF
    'verse
    byte 0,1,6,BAROFF
    byte 0,1,7,BAROFF
    byte 0,1,8,BAROFF
    byte 0,1,9,BAROFF
    byte 2,3,10,12,BAROFF
    byte 2,3,13,BAROFF
    byte 4,5,BAROFF
    byte 4,5,11,14,BAROFF

## Footer

Finally is the footer. All that is needed is this single line to close a
song, which tells the parser it is over.

    byte SONGOFF

# Example

    titleScreenSong

    byte    15      'number of bars
    byte    28      'tempo
    byte     8      'notes per bar

    'ROOT BASS
    byte    0, 36,SOFF,  36,SOFF,   34,  36,SOFF,  34
    byte    1, 24,SOFF,  24,SOFF,   22,  24,SOFF,  22

    'DOWN TO SAD
    byte    0, 32,SNOP,  32,SOFF,   31,  32,SOFF,  31
    byte    1, 20,SNOP,  20,SOFF,   19,  20,SOFF,  19 

    'THEN FOURTH
    byte    0, 29,SNOP,  29,SOFF,   27,  29,SOFF,  27
    byte    1, 17,SNOP,  17,SOFF,   15,  17,SOFF,  15
    byte    2,   48,SNOP,SOFF,  50, SNOP,SOFF,  51,SNOP
    byte    2, SNOP,SOFF,  48,SNOP,   51,SNOP,  48,SNOP
    byte    2,   53,SNOP,SNOP,  51, SNOP,SNOP,  50,SNOP
    byte    2, SNOP,  51,SNOP,SNOP,   50,  51,  50,SNOP  

    'melody
    byte    2,   48,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SNOP
    byte    2, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF  
        
    'harmonies
    byte    3,   44,SNOP,SNOP,  43, SNOP,SNOP,  41,SNOP
    byte    3, SNOP,  39,SNOP,SNOP,   38,SNOP,SNOP,SNOP
    byte    3, SNOP,SNOP,SNOP,SNOP, SNOP,SNOP,SNOP,SOFF  

    'SONG ------
    byte    0,BAROFF
    byte    0,BAROFF
    byte    0,BAROFF
    byte    0,BAROFF
    byte    0,1,BAROFF
    byte    0,1,BAROFF
    byte    0,1,BAROFF
    byte    0,1,BAROFF

    'verse 
    byte    0,1,6,BAROFF
    byte    0,1,7,BAROFF
    byte    0,1,8,BAROFF
    byte    0,1,9,BAROFF
    byte    2,3,10,12,BAROFF
    byte    2,3,13,BAROFF
    byte    4,5,BAROFF
    byte    4,5,11,14,BAROFF

    'verse
    byte    0,1,6,BAROFF
    byte    0,1,7,BAROFF
    byte    0,1,8,BAROFF
    byte    0,1,9,BAROFF
    byte    2,3,10,12,BAROFF
    byte    2,3,13,BAROFF
    byte    4,5,BAROFF
    byte    4,5,11,14,BAROFF

    byte    SONGOFF
