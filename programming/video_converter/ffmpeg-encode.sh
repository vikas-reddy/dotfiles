#!/bin/bash
#
#    Vikas Reddy @ http://vikas-reddy.blogspot.com/
#
# ffmpeg libxvid
# --------------
# ffmpeg -i Input-Filename.avi -f mp4 -y \
#   -vcodec libxvid -b:v 600k -acodec libfaac -b:a 96k -ac 2 -ar 44100 \
#   -r 25 -s 640x272 -aspect 640:360 -vf pad=640:360:0:44 \
#   -threads 2 -async 1 -pass 1 /dev/null
# ffmpeg -i Input-Filename.avi -f mp4 \
#   -y -vcodec libxvid -b:v 600k -acodec libfaac -b:a 96k -ac 2 -ar 44100 \
#   -r 25 -s 640x272 -aspect 640:360 -vf pad=640:360:0:44 \
#   -threads 2 -async 1 -pass 2 ./Input-Filename-ffmpeg.mp4
#
# ffmpeg libx264
# --------------
# ffmpeg -i Input-Filename.avi -f mp4 -y \
#   -vcodec libx264 -b:v 600k -acodec libfaac -b:a 96k -ac 2 -ar 44100 \
#   -r 25 -s 320x196 -aspect 320:240 -vf pad=320:240:0:22 \
#   -threads 2 -async 1 -pass 1 /dev/null
# ffmpeg -i Input-Filename.avi -f mp4 -y \
#   -vcodec libx264 -b:v 600k -acodec libfaac -b:a 96k -ac 2 -ar 44100 \
#   -r 25 -s 320x196 -aspect 320:240 -vf pad=320:240:0:22 \
#   -threads 2 -async 1 -pass 2 ./Input-Filename-ffmpeg.mp4
#  
#  Usage
#  -----
#  Command-line options: 
#  -a : Video aspect ratio. Could be either 1.77 or 2.35 (default)
#  -b : Video bitrate. Should be in the form of 600k (default)
#  -c : Video codec. Should be either libx264 or libxvid (default)
#  -d : Output directory. Current directory (.) is the default
#  -y : Whether to ask confirmation before overwriting any file.
#       Should be either "yes" (default) or "no"
#  
#  Examples
#  --------
#  1) ./ffmpeg-encode.sh The.Movie.Filename.avi 
#     would output the xvid-encoded video to The.Movie.Filename-ffmpeg.mp4 in the current directory
#  2) ./ffmpeg-encode.sh -a 1.77 -b 650k -c libx264 -d /home/vikas/downloads/ -y The.Movie.Filename.avi 
#  


# Command-line options
while getopts 'a:b:c:d:o:p:y' opt "$@"; do
    case "$opt" in
        a) video_aspect="$OPTARG" ;;
        b) vbitrate="$OPTARG" ;;
        c) video_codec="$OPTARG" ;;
        d) output_dir="$OPTARG" ;;
        o) addl_options="$OPTARG" ;;
        p) passes="$OPTARG" ;;
        y) ask_confirmation="no" ;;
    esac
done
shift $((OPTIND - 1))


# Defaults
video_aspect="${video_aspect:-2.35}"
video_codec="${video_codec:-libxvid}" # or libx264
vbitrate="${vbitrate:-600k}"
passes="${passes:-2}"
output_dir="${output_dir:-.}"


vpre=""

if [[ "$video_codec" == "libx264" ]]; then
    vpre="-vpre ipod320"
    aspect="320:240"

    if [[ "$video_aspect" == "2.35" ]]; then
        resolution="320x196"
        pad="pad=320:240:0:22"
    elif [[ "$video_aspect" == "1.77" ]]; then
        resolution="320x240"
        pad="pad=320:240:0:0"
    fi;

elif [[ "$video_codec" == "libxvid" ]]; then
    aspect="640:360"

    if [[ "$video_aspect" == "2.35" ]]; then
        resolution="640x272"
        pad="pad=640:360:0:44"
    elif [[ "$video_aspect" == "1.77" ]]; then
        resolution="640x360"
        pad="pad=640:360:0:0"
    fi;
fi;


echo "Encoding '${#@}' video(s)";

for in_file in "$@"; do

    # If the filename has no extension
    if [[ -z "$(echo "$in_file" | grep -Ei "\.[a-z]+$")" ]]; then
        fname="$(basename "${in_file}")-ffmpeg.mp4"
    else
        fname="$(basename "$in_file" | sed -sr 's/^(.*)(\.[^.]+)$/\1-ffmpeg.mp4/')"
    fi
    out_file="${output_dir%/}/${fname}"

    # Avoid overwriting files
    if [[ "$ask_confirmation" != "no" ]] && [[ -f "$out_file" ]]; then
        echo -n "'$out_file' already exists. Do you want to overwrite it? [y/n] "; read response
        [[ -z "$(echo "$response" | grep -i "^y")" ]] && continue
    fi

    # 1st pass
    ffmpeg -i "$in_file" \
           -f mp4 -y $addl_options \
           -vcodec "$video_codec" -b:v "$vbitrate" $vpre \
           -acodec libfaac -b:a 96k -ac 2 -ar 44100 \
           -r 25 -s "$resolution" -aspect "$aspect" -vf "$pad" \
           -threads 2 -async 1 -pass 1  \
           "/dev/null"; # $out_file;

    # 2nd pass
    ffmpeg -i "$in_file" \
           -f mp4 -y $addl_options \
           -vcodec "$video_codec" -b:v "$vbitrate" $vpre \
           -acodec libfaac -b:a 96k -ac 2 -ar 44100 \
           -r 25 -s "$resolution" -aspect "$aspect" -vf "$pad" \
           -threads 2 -async 1 -pass 2  \
           "$out_file";
done
