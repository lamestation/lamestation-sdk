---
layout: learnpage
title: ctrl.Start
--- 

Initialize the LameControl library.

## Syntax

    Start

This command takes no parameters, and returns 0 or 1.

## Description

This command sets up the

Start must be called before any other LameControl commands.

## Example

    PUB Main
        ctrl.Start
     
        repeat
            ctrl.Update
            ' ...


