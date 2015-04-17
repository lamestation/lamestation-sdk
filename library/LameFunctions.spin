PUB Sleep(milliseconds)
    waitcnt(clkfreq/1000*milliseconds + cnt)       ' delay for N ms
        
PUB TestBoxCollision(obj1x, obj1y, obj1w, obj1h, obj2x, obj2y, obj2w, obj2h)
    if obj1x + obj1w =< obj2x
        return
    if obj1x => obj2x + obj2w
        return
    if obj1y + obj1h =< obj2y
        return
    if obj1y => obj2y + obj2h
        return
    return 1

PUB SetClock
{ based on:
    Object File: Clock.spin
    Version:     1.2
    Date:        2006 - July 16, 2012
    Author:      Jeff Martin
    Company:     Parallax Semiconductor
    Email:       jmartin@parallaxsemiconductor.com
    Licensing:   MIT License - see end of file for terms of use.
}
    ifnot clkmode & $18
        clkset(clkmode & $07 | $68, clkfreq)
        waitcnt(oscDelay[clkmode & $7 <# 2] * |<(clkmode & $7 - 3 #> 0) + cnt)
                           
    clkset($6F, 80_000_000)                                                                                                                                                                                                             

CON
    WMIN = 381                                          'WAITCNT-expression overhead minimum
                                                        'ie: freeze protection
    
DAT
    oscDelay  long      20_000_000 / 100                'Sys Counter offset for 10 ms oscillator startup delay based on worst-case RCFAST frequency 
              long      33_000 / 100 #> WMIN            '<same as above> but based on worst-case RCSLOW frequency; limited to WMIN to prevent freeze                         
              long      5_000_000 / 100 #> WMIN         '<same as above> but based on external source (XIN) frequency                               

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