#!/bin/bash
#     vikas
#     convert to nHD (640x360)

files=$@

for file in $files; do
    echo "Converting $file ...";

    #mencoder -of lavf -lavfopts format=mp4 -oac lavc -ovc lavc -lavcopts aglobal=1:vglobal=1:acodec=libfaac:vcodec=mpeg4:abitrate=96:vbitrate=800:keyint=250:mbd=1:vqmax=10:lmax=10:vpass=1:turbo -ofps 25 -af lavcresample=44100 -vf harddup,scale=640:-3 -sub 'input.srt' 'input.avi' -o 'output.mp4'
    #mencoder -of lavf -lavfopts format=mp4 -oac lavc -ovc lavc -lavcopts aglobal=1:vglobal=1:acodec=libfaac:vcodec=mpeg4:abitrate=96:vbitrate=800:keyint=250:mbd=1:vqmax=10:lmax=10:vpass=2 -ofps 25 -af lavcresample=44100 -vf harddup,scale=640:-3 -sub 'input.srt' 'input.avi' -o 'output.mp4'

    input_file=$file;
    output_file=$(echo "$file" | sed -r 's/^(.*)\.[^\.]+$/\1.mp4/');
    width=$(midentify "$file" | grep 'ID_VIDEO_WIDTH' | awk -F= '{print $2}')
    height=$(midentify "$file" | grep 'ID_VIDEO_HEIGHT' | awk -F= '{print $2}')
    height_2=$(

    ffmpeg -i "$input_file" \
           -f mp4 -pass 1 -passlogfile ffmpeg-log \
           -vcodec libx264 -r 30 -s 640x240 \
           -acodec libfaac -ab 96k -ac 2 \
           -threads 0 -async 1 \
           -b 400k -aspect 4:3 "$output_file";

    ffmpeg -i "$input_file" \
           -f mp4 -pass 2 -passlogfile ffmpeg-log \
           -vcodec libx264 -r 30 -s 320x240 \
           -acodec libfaac -ab 96k -ac 2 \
           -threads 0 -async 1 \
           -b 400k -aspect 4:3 "$output_file";

done
