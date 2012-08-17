#!/bin/bash


mencoder "$1" \
    -ovc xvid -xvidencopts bitrate=-600 \
    -oac faac -faacopts br=96 \
    -vf scale=640:360 \
    -o "$2";
