#!/bin/bash
#     vikas
#     convert to nHD (640x360)

files=$@

for file in $files; do
    echo "Converting $file ...";

    mencoder "$file" \
        -oac mp3lame \
        -lameopts abr:br=160 \
        -ovc xvid \
        -xvidencopts pass=1:turbo \
        -vf scale=640:360 \
        -ofps 24000/1001 \
        -o /dev/null;
        
    mencoder "$file" \
        -oac mp3lame \
        -lameopts abr:br=160 \
        -ovc xvid \
        -xvidencopts pass=2:bitrate=-700000 \
        -vf scale=640:360 \
        -ofps 24000/1001 \
        -o "enc_{$file}";
        
end
