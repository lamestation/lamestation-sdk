OBJ
    ctrl    : "LameControl"
    pin     : "LamePinout"

CON
    LED_PIN = pin#LED

PUB Main

    dira[LED_PIN]~~

    repeat
        ctrl.Update

        if ctrl.A or ctrl.B or ctrl.Up or ctrl.Down or ctrl.Left or ctrl.Right
            outa[LED_PIN]~~
        else
            outa[LED_PIN]~
