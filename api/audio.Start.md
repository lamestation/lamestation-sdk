---
layout: learnpage
title: audio.Start
--- 

Initialize the LameAudio synthesizer.

## Syntax

    Start

This command takes no arguments and returns no result.

## Description

LameAudio is a standalone 4-oscillator synthesizer that runs in its own
processor core.

**`         Start        ` should only be run once** throughout the
duration of a program, otherwise multiple synthesizers will be competing
for a single register bank resulting in an undefined state.

LameAudio however can be included in as many objects as necessary
allowing for convenient code organization.

## Example

    CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

    OBJ
        audio   :               "LameAudio"

    PUB Noise
        audio.Start
        audio.SetWaveform(1, 4)
        audio.SetADSR(1,127, 1, 0, 70)
        audio.PlaySound(1,50)

See also: [music.Start](music.Start.html) .

Initialize the LameAudio synthesizer.
