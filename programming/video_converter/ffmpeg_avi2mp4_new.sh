#!/bin/bash
#
#
# FFMPEG XviD
# ffmpeg -i "input.avi" -f mp4 -vcodec libxvid -s 640x360 -b 768kb -r 25 -aspect 16:9 -acodec libfaac -ab 96kb -ar 44100 -ac 2 "output.mp4"
#
# FFMPEG X264
# ffmpeg -i "$in_file" -f mp4 -y -vcodec libx264 -b 400k -acodec libfaac -ab 96k -ac 2 -pass 1 -passlogfile ffmpeg_x264 -r 25 -s 320x240 -aspect 4:3 -vpre fastfirstpass -threads 2 -async 1 $out_file;


if [[ ${#@} < 2 ]]; then
    echo "Needs at least two arguments..."
    exit
fi

in_file="$1"
out_file="$2"


video_type="1.66" # 1.66 or 2.35 or 1.33
video_codec="libx264" # libxvid or libx264
vpre_pass1=""
vpre_pass2=""

bitrate="450k"

if [[ "$video_codec" == "libx264" ]]; then
    vpre_pass1="-vpre fastfirstpass -vpre baseline"
    vpre_pass2="-vpre hq -vpre baseline"

    if [[ "$video_type" == "2.35" ]]; then
        resolution="320x196"
        aspect="320:240"
        padtop="22"
        padbottom="22"
    elif [[ "$video_type" == "1.66" ]]; then
        resolution="320x240"
        aspect="320:240"
        pad_x=0
        pad_y=0
    elif [[ "$video_type" == "1.33" ]]; then
        resolution="320x240"
        aspect="320:240"
        padtop="0"
        padbottom="0"
    fi;

elif [[ "$video_codec" == "libxvid" ]]; then

    if [[ "$video_type" == "2.35" ]]; then
        resolution="640x272"
        aspect="640:272"
        padtop="44"
        padbottom="44"
    elif [[ "$video_type" == "1.66" ]]; then
        resolution="640x360"
        aspect="16:9"
        pad_x=0
        pad_y=0
    elif [[ "$video_type" == "1.33" ]]; then
        resolution="480x360"
        aspect="480:360"
        padtop="0"
        padbottom="0"
        padleft="80"
        padright="80"
    fi;
fi;




# 1st pass
echo ffmpeg -i "$in_file" \
       -f mp4 -y \
       -vcodec "$video_codec" -b "$bitrate" $vpre_pass1 \
       -acodec libfaac -ab 96k -ac 2 \
       -r 25 -s "$resolution" -aspect "$aspect" \
       -vf pad=640:360:"$pad_x":"$pad_y":black \
       -threads 2 -async 1 -pass 1  \
       "/dev/null"; # $out_file;

# 2nd pass
echo ffmpeg -i "$in_file" \
       -f mp4 -y \
       -vcodec "$video_codec" -b "$bitrate" $vpre_pass2 \
       -acodec libfaac -ab 96k -ac 2 \
       -r 25 -s "$resolution" -aspect "$aspect" \
       -vf pad=640:360:"$pad_x":"$pad_y":black \
       -threads 2 -async 1 -pass 2  \
       $out_file;
