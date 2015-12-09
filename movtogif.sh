#! /bin/bash
#
# Transform a mov file into an animated GIF!
#
# before using, please install:
# - ffmpeg
# - sips (already installed on OSX)
# - gifsicle

### 1/ get parameters: .mov file, framerate (Hz),

OPTIND=1
# Initialize our own variables:
OUTPUT="animation.gif"
RATE=10

while getopts "h:o:r:w:" opt; do
    case "$opt" in
    h)  HEIGHT=$OPTARG
        ;;
    o)  OUTPUT=$OPTARG
        ;;
    r)  RATE=$OPTARG
        ;;
    w)  WIDTH=$OPTARG
        ;;
    esac
done

INPUT="${@:$OPTIND}"
if [[ $INPUT == "" ]]; then
	echo "Missing source file parameter"
	exit;
fi
if [ ! -f $INPUT ]; then
    echo "$INPUT does not exist"
    exit;
fi
if [[ ${INPUT: -4} != ".mov" ]]; then
    echo "Input file must be .mov"
    exit;
fi

let DELAY="100/${RATE}"

### to png files
mkdir pngs
echo "ffmpeg -i $INPUT -r $RATE ./pngs/out%04d.png"
ffmpeg -i $INPUT -r $RATE ./pngs/out%04d.png

### to gif files
mkdir gifs
echo "sips -s format gif pngs/*.png --out gifs &>/dev/null"
sips -s format gif pngs/*.png --out gifs &>/dev/null

### to 1 animated gif file
if [[ $WIDTH == "" ]]; then
    WIDTH="_"
fi
if [[ $HEIGHT == "" ]]; then
    HEIGHT="_"
fi
RESIZE="${WIDTH}x${HEIGHT}"

if [[ $RESIZE == "_x_" ]]; then
    echo "gifsicle --optimize=3 --delay=$DELAY --loopcount gifs/*.gif > $OUTPUT"
    gifsicle --optimize=3 --delay=$DELAY --loopcount gifs/*.gif > $OUTPUT
else
    echo "gifsicle --optimize=3 --delay=$DELAY --loopcount --resize $RESIZE gifs/*.gif > $OUTPUT"
    gifsicle --optimize=3 --delay=$DELAY --loopcount --resize $RESIZE gifs/*.gif > $OUTPUT
fi

### clean
rm pngs/* gifs/*
rmdir pngs gifs
