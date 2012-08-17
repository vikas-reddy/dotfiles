#!/bin/bash

hosts="hosts.txt"
uptimes="uptimes.txt"
CMD="uptime"

# emtying file
echo -n "" > "$uptimes"

while read line; do
    if [[ $(echo "$line" | awk '{print NF}') < '3' ]]; then
        echo "Invalid input line '${line}'..."
        continue
    fi

    user="$(echo "$line" | awk '{print $2}')"
    host="$(echo "$line" | awk '{print $1}')"
    pass="$(echo "$line" | awk '{print $3}')"

    VAR=$(expect -c "
    spawn ssh -o StrictHostKeyChecking=no $user@$host $CMD
    match_max 100000
    expect \"*?assword:*\"
    send -- \"$pass\r\"
    send -- \"\r\"
    expect eof
    ")

    uptime="$(echo "$VAR" | tail -n 1 | sed -r 's/^ [[:digit:]:]+ up[^[:space:]]*([^,]+?),.*$/\1/')"


    # updating file
    echo "$host --> $uptime" >> "$uptimes"

done < "$hosts"

