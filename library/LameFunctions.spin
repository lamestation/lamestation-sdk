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

