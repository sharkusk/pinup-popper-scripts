import argparse

def process_postit(text):
    lines = text.strip().splitlines()
    # First line is HIGHEST SCORES
    new_text = lines[0]

    # Name, Score, and blank line for each score
    rank = 0
    for i in range(1, len(lines)-1, 3):
        rank += 1
        name = lines[i].strip()
        score = int(lines[i+1].strip())
        hi_score = f"{rank}) {name:15} {score:,d}"
        new_text = '\n'.join([new_text, hi_score])
    return new_text + '\n'

def process_ultradmd(text):
    lines = text.strip().splitlines()
    # First line is HIGHEST SCORES
    new_text = lines[0]

    # Name, Score - one per line
    rank = 0
    for i in range(1, len(lines)-1):
        rank += 1
        name, score = lines[i].split()
        score = int(score)
        hi_score = f"{rank}) {name:15} {score:,d}"
        new_text = '\n'.join([new_text, hi_score])
    return new_text + '\n'

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("input_path", help="Input filename path")
    parser.add_argument("output_path", help="Output filename path")
    parser.add_argument("file_type", choices=['UltraDMD', 'PostIt'])
    args = parser.parse_args()

    with open(args.input_path, 'r') as f:
        text = f.read()

        if args.file_type == 'UltraDMD':
            text = process_ultradmd(text)
        elif args.file_type == 'PostIt':
            text = process_postit(text)

    with open(args.output_path, 'w') as f:
        f.write(text)
