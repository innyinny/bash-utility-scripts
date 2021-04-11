# add all these to your .bash_aliases or just include them
# many helpful utility commands and helpful batchers


# renames files within a directory to zero pad the number
# and remove/replace the rest of the name
# $1 is a prefix to ignore on original (useful for ignoring chapter numbers)
# $2 is a prefix to add on renamed (useful for adding chapter numbers)
# $3 is a suffix to add on renamed (useful for adding or changing filetype)
# $4 is a mathamtical operation to apply to the number (useful for shifting the sequence)
renumber() {
    echo "Renaming the following files"
    prefix1="$1"
    prefix2="\"$2\"."
    suffix="$3"
    operation="$4"
    rename -n 'if (m/'"$prefix1"'([0-9]+).*(\..+)/) {$_ = '"$prefix2"'sprintf("%03d",$1'"$operation"')."'"$suffix"'$2";}' *
    read -p "Continue? " -n 1 -r
    echo # new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        rename 'if (m/'"$prefix1"'([0-9]+).*(\..+)/) {$_ = '"$prefix2"'sprintf("%03d",$1'"$operation"')."'"$suffix"'$2";}' *
    fi
}



# ffmpeg converters

# adds an audio track
copyaudio() {
    ffmpeg -i $2 -i $1 -c copy -map 0:0 -map 1:1 -shortest $1_redub.mp4
}

# shrinks video quality to a lower but still decent quality
shrink1000() {
    ffmpeg \
        -i "$1" \
        -vf scale=1024:600 -c:v libx264 \
        -x264-params bitrate=1000:bframes=2:subq=4:b_pyramid=normal:weight_b \
        -c:a copy \
        -max_muxing_queue_size 400 \
        -movflags faststart \
        "$1_shrunk.mp4";
    du -h "$1"*
}

# converts a series of images to an mkv
imgtomkv() {
    ffmpeg -loop 1 -i $1 -r 30 -t 1 -c:v libx264 -x264-params bitrate=2000:bframes=2:subq=4:b_pyramid=normal:weight_b -shortest -y "$1_new.mkv"
    du -h "$1"*
}

# converts video to mkv
convertmkv() {
    ffmpeg \
        -i "$1" \
        -c:v libx264 \
        -x264-params bitrate=2000:bframes=2:subq=4:b_pyramid=normal:weight_b \
        -c:a copy \
        -movflags faststart \
        -y \
        "$1_conv.mkv";
    du -h "$1"*
#        -c:a copy \
#        -c:a libvorbis -b:a 48k \
}

# trim a video
# $1 video
# $2 start time
# $3 end time
trim() {
    ffmpeg \
        -i "$1" \
        -ss "$2" \
        -to "$3" \
        -c copy \
        "$1_trimmed.mp4";
    du -h "$1"*
}

# add a subtitle file
addsubtitle() {
    ffmpeg \
        -i "$1" \
        -i "$2" \
        -c copy \
        -c:s copy \
        -disposition:s:0 default \
        "$1_subbed.mkv";
    du -h "$1"*
}



# uses tesseract to scrape japanese text off of an image
scrape() {
    # disabled preprocessing.. probably unneeded
    #convert "$1" \
    #    -colorspace gray \
    #    -auto-level \
    #    -threshold 50% \
    #    - | \
    # disabled args for tesseract
    #    -c tessedit_write_images=1 \
    #    -c textord_force_make_prop_words=F \
    tesseract "$1" - \
        -l jpn_ver5 \
        --dpi 300 \
        --psm 12 \
        -c chop_enable=1 \
        -c edges_max_children_per_outline=3 \
        -c min_orientation_margin=1 \
        2>/dev/null | \
    sed 's/ //g'
}


alias shrink1000all='for f in *.*; do shrink1000 "$f"; done'
alias convertall='for f in *.*; do convertmkv "$f"; done'

# compress all pngs to jpg of good quality
alias compresspngall='for f in *.png; do convert -strip -interlace JPEG -quality 90 "$f" "$f.jpg"; done'

# resize all images in directory to a nice standard comic size and good quality
alias resizepngall='for f in *.png; do convert -geometry 1280x -strip "$f" "$f"_resized.png; done'
alias resizejpgall='for f in *.jpg; do convert -geometry 1280x -strip -interlace JPEG -quality 90 "$f" "$f"_resized.png; done'

alias scrapeall='set -o noclobber; for f in *.jpg; do scrape "$f" > "$f.txt"; echo "scraping $f" . "..."; done'

# run stupidcyfer operations on all in directory
alias stupidcyferall='for f in *.txt; do stupidcyfer.py "$f" -y; done'
alias stupiddecyferall='for f in *.scy; do stupidcyfer.py "$f" -y; done'


