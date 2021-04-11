#!/bin/bash

# recombines segmented videos into 1 video
# trips start and end clip (adjust seconds)

pattern=$1
startclip='0:00:05'
endclip='0:00:04'

subtime() {
    local EPOCH='jan 1 1970' sum=0
    sum="$(($(date -d "$EPOCH $1" +%s) - $(date -d "$EPOCH $2" +%s)))"
    res=`TZ=UTC date -d @$sum +%H:%M:%S`
}

trim() {
    ffmpeg \
        -i "$1" \
        -ss "$2" \
        -to "$3" \
        -c copy \
        "$1_trimmed.mp4";
}

touch ${pattern}.concat
rm  ${pattern}.concat

#echo $pattern
#echo $startclip
#echo $endclip
for f in `find . -type f -name "${pattern}*" | sort`; do 
    echo $f
    duration=`ffmpeg -i "$f" 2>&1 | grep Duration | awk '{print $2}' | tr -d ,`
    #echo $duration
    subtime $duration $endclip
    #echo $res
    trim $f $startclip $res
    echo "file ${f:2}_trimmed.mp4" >> ${pattern}.concat
done

ffmpeg -f concat -i ${pattern}.concat -c:v copy -c:a copy ${pattern}full.mp4
#rm  ${pattern}.concat
