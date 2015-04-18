---
layout: learnpage
title: ctrl.Update
--- 

Update the state of all LameStation controls.

## Syntax

    Update

This command takes no parameters, and returns 0 or 1.

## Description

The state of the Propeller pins can change at any time, regardless of
the state of your application. Since you are likely to want to check the
value of a command multiple times in a program, LameControl saves the
state of the Propeller pins to another register, which are then returned
by the various commands. This means that the value returned is
guaranteed to be the same until another call to `        Update       `
.

`        Update       ` must be called before attempting to retrieve
control states.

## Example

    PUB Main
        ctrl.Start
     
        repeat
            ctrl.Update
            ' ...
     
            if ctrl.A
                ' ...
     
            if ctrl.A
                ' ...
     
            ' ...


