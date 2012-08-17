#!/bin/bash

last_line="$(tail -n 5 board_master.txt | grep -vE '^[[:space:]]$' | tail -n 1)"

state="searching"
updates=''

while read line; do

    if [[ "$state" == "reading" ]]; then
        updates="$updates$line"
        echo '*************************'
        echo "$line"
        echo "$updates"
        echo '*************************'
    fi

    if [[ "$line" == "$last_line" ]]; then
        state="reading"
    fi

done < board_latest.txt

