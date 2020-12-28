import argparse
from PIL import Image, ImageDraw, ImageFont
import os
import math
import numpy as np
from moviepy.editor import *
from moviepy.video.tools.drawing import color_gradient

def create_video_from_text(text, args):
    moviesize = tuple(map(int, args.size.split('x')))
    w, h = moviesize

    # Add blanks
    # text = 5*"\n" + text + 5*"\n"

    # CREATE THE TEXT IMAGE
    clip_txt = TextClip(text.strip(), color=args.text_color, align='Center',
            fontsize=int(args.font_size), font=args.font, method='label')
    
    # SCROLL THE TEXT IMAGE BY CROPPING A MOVING AREA

    pause_time = 2
    if args.text_speed == "":
        duration = int(args.duration)
        txt_speed = (clip_txt.size[1] - h) / (duration - (2 * pause_time))
    else:
        txt_speed = int(args.text_speed)
        duration = 2 * pause_time + ((clip_txt.size[1] - h) / txt_speed)

    def fl(gf, t):
        if t < pause_time:
            # Pause at start
            t = 0
        elif t > duration - pause_time:
            # Pause at end
            t = duration - (2 * pause_time)
        else:
            t = t - pause_time

        return gf(t)[int(txt_speed*t):int(txt_speed*t)+h,:]

    moving_txt = clip_txt.fl(fl, apply_to=['mask'])

    if False:
        # ADD A VANISHING EFFECT ON THE TEXT WITH A GRADIENT MASK
        grad = color_gradient(moving_txt.size,p1=(0,2*h/3),
                        p2=(0,h/4),col1=0.0,col2=1.0)
        gradmask = ImageClip(grad,ismask=True)
        fl = lambda pic : np.minimum(pic,gradmask.img)
        moving_txt.mask = moving_txt.mask.fl_image(fl)

    final = CompositeVideoClip([
            moving_txt.set_pos(('center','bottom'))],
            size = moviesize)

    filename = os.path.join(args.popmedia, args.gamename + args.suffix + ".mp4")

    # WRITE TO A FILE
    final.set_duration(duration).write_videofile(filename, fps=int(args.fps), codec="mpeg4")

def create_image_from_text(text, args):
    lines = text.strip().splitlines()
    nlines = len(lines)
    ncols = math.ceil(nlines / int(args.max_lines))
    img_size = tuple(map(int, args.size.split('x')))
    img = Image.new('RGB', img_size, color=args.background_color)
    font = ImageFont.truetype(args.font, int(args.font_size))
    draw = ImageDraw.Draw(img)

    lines_per_col = math.ceil(len(lines)/ncols)
    col_size = int(img_size[0] / ncols)
    
    start_line = 0
    for i in range(ncols):
        # Do not start a column with a blank line
        while lines[start_line] == "":
            start_line += 1

        end_line = start_line + lines_per_col

        t = '\n'.join(lines[start_line:end_line])

        x = i * col_size
        bounding_box = [x, 0, x+col_size, img_size[1]]
        x1, y1, x2, y2 = bounding_box  # For easy reading

        # Calculate the width and height of the text to be drawn, given font size
        w, h = draw.textsize(t, font=font)

        # Calculate the mid points and offset by the upper left corner of the bounding box
        x = (x2 - x1 - w)/2 + x1
        y = (y2 - y1 - h)/2 + y1

        # Write the text to the image, where (x,y) is the top left corner of the text
        draw.text((x, y), t, align='center', font=font, color=args.text_color)

        # Draw the bounding box to show that this works
        draw.rectangle([x1, y1, x2, y2])
        start_line = end_line

    filename = os.path.join(args.popmedia, args.gamename + args.suffix + ".png")
    img.save(filename)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("rom", help="ROM name (VPinMame), CGname (UltraDMD), or high score filename (PostIT)")
    parser.add_argument("gamename", help="Popper gamename used to generate image filename")
    parser.add_argument("gametype", help="Set to UltraDMD or BAM (for FP), otherwise unneeded")
    parser.add_argument("-v", "--verbose", help="increase output verbosity", action="store_true")
    parser.add_argument("--size", help="Size of image to generate (e.g. 1776x445)", default="1776x445")
    parser.add_argument("--background_color", help="Background color of image", default="black")
    parser.add_argument("--background_image", help="Path to background image", default="")
    parser.add_argument("--text_color", help="Color of text", default="grey")
    parser.add_argument("--max_lines", help="Maximum number of lines per column", default="8")
    parser.add_argument("--font", help="Name or path to font", default="Impact")
    parser.add_argument("--font_size", help="Name or path to font", default="40")
    parser.add_argument("--nvpath", help="Path to VPinMAME's NVRAM directory", default="C:/Visual Pinball/VPinMame/nvram")
    parser.add_argument("--userpath", help="Path to Visual Pinballs's User directory", default="C:/Visual Pinball/User")
    parser.add_argument("--popmedia", help="Path to directory to store image", default="c:/PinupSystem/POPMedia/Visual Pinball X/DMD")
    parser.add_argument("--suffix", help="Added to the table's imagename to avoid conflicts with other meida files", default="")
    parser.add_argument("--duration", help="Length of time for video clip", default="10")
    parser.add_argument("--text_speed", help="Speed of text scrolling (overrides duration) -- 120 is reasonable", default="")
    parser.add_argument("--fps", help="FPS of generated video file", default="12")
    parser.add_argument("--text_file", help="Specify text file to use instead of processing table", default="")
    args = parser.parse_args()

    if args.text_file != "":
        with open(args.text_file, 'r') as f:
            text = f.read()
            # create_image_from_text(text, args)
            create_video_from_text(text, args)
