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

They have been tested using Python 3.9, but likely work with other versions of Python.

### reformat_scores.py

When using the default high score batch file the text files generated for UltraDMD and PostIt tables are different than what is typically provided by the PINemHiHS program.  This script reformats them to match.

the UltraDMD high scores are typically formatted as follows:

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

```python reformat_scores.py leprechaun.txt leprechaun-2.txt UltraDMD```

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

#### Install

This script has no dependencies.  It can be run standalone or as part of the hiscore.bat script by copying them to the PinemHiHS directory and inserting the following lines at the end of the :ULTRADMD and :POSTIT sections (before the line `GOTO PNG`):

```
CALL python "%PINemHiHS%\reformat_scores.py" "%PINemHiHS%\%TEMPTXT%.txt" "%PINemHiHS%\%TEMPTXT%.txt" UltraDMD
```

```
CALL python "%PINemHiHS%\reformat_scores.py" "%PINemHiHS%\%TEMPTXT%.txt" "%PINemHiHS%\%TEMPTXT%.txt" PostIt
```

### text_to_image.py

This is a replacement for the default text rendering used by the high score script.  The main advantage is that it supports multiple columns for high score files that are many lines.  It will also automatically maximize the font size to fit.

Here's a somewhat extreme example of Medieval Madness high scores formatted for a DMD sized area:

```python text_to_image.py --text_color "#ff5820" --max_lines 8 mm_109c.txt mm_109c.png test/hiscore/HighSpeed.ttf```

![mm_109c.png](https://user-images.githubusercontent.com/4368882/103378788-6aaae080-4a98-11eb-9463-7352a1983e7c.png)

Here's an example for Attack from Mars with a different font:

```python text_to_image.py --text_color "#ff5820" --max_lines 8 afm_113b.txt afm_113b.png Hack-Bold.ttf```

![afm_113b](https://user-images.githubusercontent.com/4368882/103379284-07ba4900-4a9a-11eb-8bcb-392352e8acd4.png)

#### Install

This script has a dependency on the Pillow / PIL Python module.  See the following page for install instructions: https://pillow.readthedocs.io/en/stable/installation.html

To use it in the high score batch file, copy the script to the PINemHiHS directory and replace the following line:

```type "%PINemHiHS%\%TEMPTXT%.txt" | "%ImageMagick%\convert.exe" -font %Font% -background black -gravity center -fill grey -size 1776x445 caption:@- "%PINemHiPNG%\%TEMPTXT%.png"```

with

```CALL python --max_lines 8 --text_color "#ff5820" "%PINemHiHS%\text_to_image.py" "%PINemHiHS%\%TEMPTXT%.txt" "%PINemHiPNG%\%TEMPTXT%.png" "%Font%"```

### text_to_image.py

This script uses video instead of an image to display high scores.  Some examples:

![afm_113b.mp4](https://user-images.githubusercontent.com/4368882/103379950-405b2200-4a9c-11eb-9291-f490505a1de3.mp4)

![mm_109c.mp4](https://user-images.githubusercontent.com/4368882/103378913-cc6b4a80-4a98-11eb-90e1-b0585a83773c.mp4)

#### Install

This script uses moviepy.  Install instructions can be found here: https://zulko.github.io/moviepy/install.html  Pay careful attention to the section regarding ImageMagick.

Once installed, this can be used instead of (or in addition to) the image generation in the high score script.  Replace:

To use it in the high score batch file, copy the script to the PINemHiHS directory and replace the following line:

```type "%PINemHiHS%\%TEMPTXT%.txt" | "%ImageMagick%\convert.exe" -font %Font% -background black -gravity center -fill grey -size 1776x445 caption:@- "%PINemHiPNG%\%TEMPTXT%.png"```

with

```CALL python "%HiScoreDir%\text_to_video.py" --text_color "#ff5820" --text_speed 120 "%PINemHiHS%\%TEMPTXT%.txt" "%OUTPUT%\%~2%Suffix%.mp4" "%Font%"```
