PUB Sleep(milliseconds) | count
    waitcnt(clkfreq/1000*milliseconds + cnt)       ' delay for 1ms
    
        
PUB TestBoxCollision(obj1x, obj1y, obj1w, obj1h, obj2x, obj2y, obj2w, obj2h)
    if obj1x + obj1w - 1 < obj2x
        return 0
    if obj1x > obj2x + obj2w - 1
        return 0
    if obj1y + obj1h - 1 < obj2y
        return 0
    if obj1y > obj2y + obj2h - 1
        return 0
    return 1
