#!/bin/bash
# This script watermarks a given directory of images.
# HOWTO: Navigate from terminal to a directory containing image files
#        execute this script.

# Modify the paths to your watermark image files bellow.
# Watermark image file paths, one for landscapes and one for portraits
LANDSCAPE="$HOME/Pictures/watermarks/watermark.png"
PORTRAIT="$HOME/Pictures/watermarks/watermark_portrait.png"

# Gets image's orientation
function get_image_orientation() {
    echo $(identify -quiet -format '%[exif:orientation]' "$1")
}

# Apply the watermark image with the correct orientation
# Possible values:
#                   1 (landscape)
#                   8 (portrait shutter button up)
#                   3 (landscape shutter button down)
#                   6 (portrait shutter button down)
# For more info about orientation interpretations check the following URLs
# https://www.impulseadventure.com/photo/exif-orientation.html
# http://sylvana.net/jpegcrop/exif_orientation.html
# https://stackoverflow.com/a/40055711/307826
function apply_watermark() {
    orientation="$(get_image_orientation "$image")";
    # get filename and file extension
    extension="${image##*.}"
    filename="${image%.*}"

    if [[ "$orientation" -eq 1 ]] || [[ "$orientation" -eq 3 ]]; then
        composite -gravity SouthWest \( "$LANDSCAPE" -resize 40% \) "$image" "$filename"_watermarked."$extension"
    elif [[ "$orientation" -eq 8 ]] || [[ "$orientation" -eq 6 ]]; then
        composite -gravity SouthEast \( "$PORTRAIT" -resize 40% \) "$image" "$filename"_watermarked."$extension"
    fi
}

# Loop over all images in current working directory
function parse_image_files() {
    for image in $(find "$PWD" -type f -name '*.jpg' -or -name '*.JPG' -or -name '*.jpeg' -or -name '*.png' -or -name '*.PNG'); do
        apply_watermark "$image"
    done
}

echo "Watermarking images from $PWD"
parse_image_files "$1"
echo "Finished!"
