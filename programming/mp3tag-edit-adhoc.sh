#! /bin/bash
# 01 Hejjegondu Hejje - Tippu,Swetha Mohan - BangaloreLiving.Com.mp3

for f in *.mp3; do
    echo mv "$f" "$(basename "$f" " - BangaloreLiving.Com.mp3").mp3"
    echo "$f" | sed -sr 's/^([0-9]+) (.+) - ([^-]+) - ([^-]+)$/id3v2 -a "\3" -A "Prithvi" -g 12 -t "\2" -y 2010 -T \1 "&"/'
done
