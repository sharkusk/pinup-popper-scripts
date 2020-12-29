import argparse
import os
from moviepy.editor import *

def create_video_from_text(text, args):
    moviesize = tuple(map(int, args.size.split('x')))
    w, h = moviesize

    # Add blanks
    # text = 5*"\n" + text + 5*"\n"
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
    final.set_duration(duration).write_videofile(args.save_name, fps=int(args.fps), preset="ultrafast")

def video_file(fname):
    file_type = os.path.splitext(fname)[1] 
    if file_type not in ['.mp4', '.avi']:
        raise argparse.ArgumentTypeError
    return fname

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("text_file", help="Text file to convert to image or video")
    parser.add_argument("save_name", type=video_file, help="File path of output video file (.mp4 or .avi)")
    parser.add_argument("font", help="Full path to TrueType or OpenType font file")
    parser.add_argument("--size", help="Size of image or video to generate in format of WxH (e.g. '1776x445')", default="1776x445")
    parser.add_argument("--background_color", help="Background color", default="black")
    parser.add_argument("--text_color", help="Color of text", default="grey")
    parser.add_argument("--font_size", help="Size of font", default="100")
    parser.add_argument("--duration", help="Length of time for video clip", default="10")
    parser.add_argument("--text_speed", help="Speed of text scrolling (overrides duration) -- 120 is reasonable", default="")
    parser.add_argument("--fps", help="FPS of generated video file", default="12")
    args = parser.parse_args()

    with open(args.text_file, 'r') as f:
        text = f.read()
        create_video_from_text(text, args)
