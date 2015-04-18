---
layout: learnpage
title: wav2dat
--- 

# wav2dat

This application serves the important purpose of converting single-cycle
16-bit mono WAV files into DAT blacks to be copied into a Spin source
file.

-   [What Is A Single-Cycle
    Waveform?](#wav2dat-WhatIsASingle-CycleWaveform?)
-   [Usage](#wav2dat-Usage)
-   [Details On The WAV Format](#wav2dat-DetailsOnTheWAVFormat)

## What Is A Single-Cycle Waveform?

## Usage

Call it with the executable followed by the wav file with no extension.

So if the audio clip is a file called filename.wav, you type:

    ./wav2dat filename

A file named filename.dat will be generated, with the following output
shown.

    $ ./wav2dat sinewave
    wav2dat v0.1
    IT OPENED!

      file size:    4140 bytes
      data size:    4096 bytes
      bit depth:    16 bytes
       src size:    2048 samples
       dst size:    512 samples
     sample inc:    4.0 samples
    127 129 130 132 133 135 136 138 139 140 142 143 145 146 148 149 150 152 153 155 156 157 159 160 162 163 164 166 167 168 170 171 172 174 175 176 178 179 180 182 183 184 185 187 188 189 190 192 193 194 195 196 197 199 200 201 202 203 204 205 206 207 208 210 211 212 213 214 215 215 216 217 218 219 220 221 222 223 224 224 225 226 227 228 228 229 230 230 231 232 232 233 234 234 235 235 236 237 237 238 238 239 239 239 240 240 241 241 241 242 242 242 243 243 243 243 244 244 244 244 244 245 245 245 245 245 245 245 245 245 245 245 245 245 245 245 244 244 244 244 244 244 243 243 243 242 242 242 241 241 241 240 240 240 239 239 238 238 237 237 236 236 235 234 234 233 232 232 231 230 230 229 228 228 227 226 225 224 224 223 222 221 220 219 218 217 216 216 215 214 213 212 211 210 209 207 206 205 204 203 202 201 200 199 198 196 195 194 193 192 190 189 188 187 185 184 183 182 180 179 178 176 175 174 173 171 170 168 167 166 164 163 162 160 159 157 156 155 153 152 150 149 148 146 145 143 142 140 139 138 136 135 133 132 130 129 128 126 125 123 122 120 119 117 116 115 113 112 110 109 107 106 105 103 102 100 99 98 96 95 93 92 91 89 88 87 85 84 83 81 80 79 77 76 75 73 72 71 70 68 67 66 65 63 62 61 60 59 58 56 55 54 53 52 51 50 49 48 47 45 44 43 42 41 40 40 39 38 37 36 35 34 33 32 31 31 30 29 28 28 27 26 25 25 24 23 23 22 21 21 20 20 19 18 18 17 17 16 16 16 15 15 14 14 14 13 13 13 12 12 12 12 11 11 11 11 11 10 10 10 10 10 10 10 10 10 10 10 10 10 10 10 11 11 11 11 11 11 12 12 12 13 13 13 14 14 14 15 15 15 16 16 17 17 18 18 19 19 20 21 21 22 23 23 24 25 25 26 27 27 28 29 30 31 31 32 33 34 35 36 37 38 39 39 40 41 42 43 44 45 46 48 49 50 51 52 53 54 55 56 57 59 60 61 62 63 65 66 67 68 70 71 72 73 75 76 77 79 80 81 83 84 85 87 88 89 91 92 93 95 96 98 99 100 102 103 105 106 107 109 110 112 113 115 116 117 119 120 122 123 125 126 
    samples taken:  512 samples

Or if you failed to supply a valid file name.

    $ ./wav2dat
    wav2dat v0.1
    No file given!

## Details On The WAV Format

    2048 samples = 4096 bytes (16 bit mono)
    actual size = 4140 bytes (16 bit mono)

    total size of pre-data stuffz = 4 + 4 + 4 + 4 + = 16 + 12 + 12 + 4 = 44
                                    4 + 2 + 2 + 4 +   
                    4 + 2 + 2 + 4 + 
                    4

    44 + 2048*2 = 44 + 4096 = 4140
    Therefore NO END OF FILE CHARACTER


    ChunkSize = 4132
        + 8 = 4140 = size of file

    44AC little endian = 44.1kHz

    byte rate = 88200 = samplerate * numchannels * bitspersample/8
            = 44100 * 1 * 16/8 = 44100 * 2
    block align = numchannels * bitspersample/8 = 1 * 2 = 2
    bits per sample = 16 bits

    subchunk2size = numsamples * numchannels * bitspersample/8 = 4096

    THEN ACTUAL SOUND DATA

    Actual sound data occurs at 0x00000029


    8-bit stored as unsigned bytes 0-255
    16-bit stored as 2's complement signed integers...

For a more detailed discussion of the WAV format, [see
here](https://ccrma.stanford.edu/courses/422/projects/WaveFormat/) .
