# pinup-popper-scripts

This is a collection of scripts that can be used with the PinUp Popper Pinball System.  It is recommended that you clone this repository into *C:\PinUPSystems\Scripts* directory.  From the C:\PinUPSystems directory you can type:

*C:\PinUPSystems>* `git clone https://github.com/sharkusk/pinup-popper-scripts.git scripts`

## Visual Pinball X

The launch script is completely non-destructive and as it executes it creates a batch file that reverts all changes when the table closes.

This launch script implements the following ALTMODES:

* **backglass** - disable pup-pack and use backglass -- these optional backglass files should be in the table directory with the name: **[TABLENAME].directb2s.BG**
* **origsound** - plays the table in completely "original form": rom audio, disable pup-pack, and use backglass
* **altsound** - play table in original form with altsound enabled
* **pinsound** - play table in original form with pinsound enabled

The launch script will also enable _Cabinet Mode_ (removes splash screen) and disable _Pinball Test_ (makes starting tables faster).

### Install

1. Copy contents of vpx_launch.bat file into the **Launch Script** found in _Popper Setup->Emulators->Launch Setup (Visual Pinball X)_
2. Copy contents of vpx_close.bat file into the **Close Script** found in _Popper Setup->Emulators->Launch Setup (Visual Pinball X)_
3. Be sure the **ROM** field is correct in the _Games Manager_ for your tables

## PinSound

These are [AutoHotKey](https://www.autohotkey.com/) scripts that automatically launch, minimize and close PinSound when Pinup Popper runs.  This cannot be done with a standard batch file because PinSound launches in a non standard way and automatically maximizes itself.  See the scripts for directions and update your paths accordingly.
