# pinup-popper-scripts

This is a collection of scripts that can be used with the PinUp Popper Pinball System.  It is recommended that you clone this repository into *C:\PinUPSystems\Scripts* directory.  From the C:\PinUPSystems directory you can type:

*C:\PinUPSystems>* `git clone https://github.com/sharkusk/pinup-popper-scripts.git scripts`

## Visual Pinball X (vpx_launch.bat, vpx_close.bat, vpx_regset.bat)

This launch script approach is non-destructive, as it executes it creates a batch file that reverts all changes when the table closes.

This launch script implements the following ALTMODES:

* **backglass** - disable pup-pack and use backglass -- these optional backglass files should be in the table directory with the name: **[TABLENAME].directb2s.BG**
* **origsound** - plays the table in completely "original form": rom audio, disable pup-pack, and use backglass
* **altsound** - play table in original form with altsound enabled
* **pinsound** - play table in original form with pinsound enabled

The launch script will also enable _Cabinet Mode_ (removes splash screen) and disable _Pinball Test_ (makes starting tables faster).

### Install

1. Copy contents of vpx_launch.bat file into the **Launch Script** found in _Popper Setup->Emulators->Launch Setup (Visual Pinball X)_
2. Copy contents of vpx_close.bat file into the **Close Script** found in _Popper Setup->Emulators->Launch Setup (Visual Pinball X)_
3. Copy vpx_regset.bat to the PinUPSystems\Scripts directory (or modify the path in vpx_launch.bat accordingly)
4. Be sure the **ROM** field is correct in the _Games Manager_ for your tables

## PinSound (pinsound_launch.ahk)

This [AutoHotKey](https://www.autohotkey.com/) script launches and minimizes PinSound when Pinup Popper runs.  This cannot be done with a standard batch file because PinSound launches in a non standard way and automatically maximizes itself.  See the scripts for directions and update your paths accordingly.

## High Score (reformat_scores.py, text_to_image.py, text_to_video.py)

These files are designed to work in conjunction with the high score script found here: https://www.nailbuster.com/wikipinup/doku.php?id=high_scores_setup

### reformat_scores.py

When using the default high score script, the UltraDMD high scores are typically formatted as follows:

```python reformat_scores.py leprechaun.txt leprechaun-2.txt UltraDMD```

```
HIGH SCORES
MCK
3727456

MCK
2994430

MCK
2858580

SCO
1300000
```

The reformat script converts the above to the following:

```
HIGH SCORES
1) MCK             3,727,456
2) MCK             2,994,430
3) MCK             2,858,580
4) SCO             1,300,000
```

In a simliar way, PostIt scores look like this with the default high score script:

```
High scores:
CUPHEAD 75000
MUGMAN 70000
DEVIL 60000
KINGDICE 55000
ELDER 50000
```

After reformatting we get:

```python reformat_scores.py CupheadPro.txt test/hiscore/CupheadPro-2.txt PostIt```

```
High scores:
1) CUPHEAD         75,000
2) MUGMAN          70,000
3) DEVIL           60,000
4) KINGDICE        55,000
```
