import argparse
from PIL import Image, ImageDraw, ImageFont
import os
import math
from moviepy.editor import *
from moviepy.video.tools.drawing import color_gradient

def create_video_from_text(text, args):
    moviesize = tuple(map(int, args.size.split('x')))
    w, h = moviesize

    # Add blanks
    # text = 5*"\n" + text + 5*"\n"
    if args.font_size == "":
        font_size = 100
    else:
        font_size = int(args.font_size)

    # CREATE THE TEXT IMAGE
    clip_txt = TextClip(text.strip(), bg_color=args.background_color, color=args.text_color,
        align='Center', fontsize=font_size, font=args.font, method='label')
    
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
            # Scroll in between pauses at start and end
            t = t - pause_time

        return gf(t)[int(txt_speed*t):int(txt_speed*t)+h,:]

    moving_txt = clip_txt.fl(fl, apply_to=['mask'])

    final = CompositeVideoClip([
            moving_txt.set_pos(('center','bottom'))],
            size = moviesize)

    # WRITE TO A FILE
    final.set_duration(duration).write_videofile(args.save_name, fps=int(args.fps)) #, preset="ultrafast")

def create_image_from_text(text, args):
    lines = text.strip().splitlines()
    nlines = len(lines)
    ncols = math.ceil(nlines / int(args.max_lines))
    img_size = tuple(map(int, args.size.split('x')))
    img = Image.new('RGB', img_size, color=args.background_color)
    draw = ImageDraw.Draw(img)

    lines_per_col = math.ceil(len(lines)/ncols)
    col_size = int(img_size[0] / ncols)

    # Optimize font size
    if args.font_size == "":
        font_size = int(img_size[1] / lines_per_col)

        font = ImageFont.truetype(args.font, font_size)

        biggest_line = 0
        biggest_line_size = (0, 0)

        # Find the biggest line
        for i, line in enumerate(lines):
            w, h = draw.textsize(line, font=font)
            if w > biggest_line_size[0]:
                biggest_line = i
                biggest_line_size = w, h
        
        # Optimize font size using binary search
        # We want to be as big as possible without going over our h or w limits
        under_fit = 10
        over_fit = 100
        prev_size = -1 
        margin = 0.95
        while True:
            print(f"under {under_fit}, over {over_fit}, size {font_size}")

            font_size = int((over_fit + under_fit)/2)
            if prev_size == font_size:
                # Font size is not changing so use the last under_fit as our optimal
                font_size = under_fit
                break

            font = ImageFont.truetype(args.font, font_size)
            w, h = draw.textsize(lines[biggest_line], font=font)
            if w > margin * col_size:
                print(f"w: {w} > {margin * col_size}")
                over_fit = font_size
            elif h > margin * (img_size[1]/lines_per_col):
                print(f"h: {h} > {margin * (img_size[1]/lines_per_col)}")
                over_fit = font_size
            else:
                under_fit = font_size
            prev_size = font_size
    else:
        font_size = int(args.font_size)

    print(f"Using font size of {font_size}")
    font = ImageFont.truetype(args.font, font_size)

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
        # draw.rectangle([x1, y1, x2, y2])

        start_line = end_line

    img.save(args.save_name)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("text_file", help="Text file to convert to image or video")
    parser.add_argument("save_name", help="File path of output graphic (.png or .jpg) or video file (.mp4 or .avi)")
    parser.add_argument("font", help="Full path to TrueType or OpenType font file")
    parser.add_argument("--size", help="Size of image or video to generate in format of WxH (e.g. '1776x445')", default="1776x445")
    parser.add_argument("--background_color", help="Background color", default="black")
    parser.add_argument("--text_color", help="Color of text", default="grey")
    parser.add_argument("--font_size", help="Name or path to font (default will maximize image)", default="")
    parser.add_argument("--max_lines", help="(image only) Maximum number of lines", default="8")
    parser.add_argument("--duration", help="(video only) Length of time for video clip", default="10")
    parser.add_argument("--text_speed", help="(video only) Speed of text scrolling (overrides duration) -- 120 is reasonable", default="")
    parser.add_argument("--fps", help="(video only) FPS of generated video file", default="12")
    args = parser.parse_args()

    if args.text_file != "":
        with open(args.text_file, 'r') as f:
            text = f.read()
            file_type = os.path.splitext(args.save_name)[1] 
            if file_type in ['.png', '.jpg']:
                create_image_from_text(text, args)
            elif file_type in ['.mp4', '.avi']:
                create_video_from_text(text, args)
