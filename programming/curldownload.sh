#!/bin/bash
#
# Vikas Reddy @ http://vikas-reddy.blogspot.com/
#
#


# Set the file size limit parameter
fsize_limit=$((14*1024*1024))
user_agent="Firefox/10.0"

if [[ $# < 1 ]]; then
    echo "Provide the url as the first, and target directory (defaults to './') as the second argument.";
    exit;
fi;

# output directory
[ -z "$2" ] && ouput_dir="." || ouput_dir="$2"
if [ ! -d "$ouput_dir" ]; then
    echo "Target directory '$ouput_dir' doesn't exist. Aborting..."
    exit 1
fi;


url="$1"
filename="$(echo "$url" | sed -r 's|^.*/([^/]+)$|\1|')"
filepath="$ouput_dir/$filename"


# Avoid overwriting the file
if [[ -f "$filepath" ]]; then
    echo -n "'$filepath' already exists. Do you want to overwrite it? [y/n] "; read response
    [ -z "$(echo "$response" | grep -i "^y")" ] && exit
fi

# Touching the file
cat /dev/null > "$filepath"


echo "Downloading to $filepath ..."
i=1
while true; do   # infinite loop, until the file is fully downloaded

    # setting the range
    [ $i -eq 1 ] && start=0 || start=$(( $fsize_limit * ($i - 1) + 1))
    stop=$(( $fsize_limit * i ))

    # downloading
    curl --fail --location --user-agent "$user_agent" --range "$start"-"$stop" "$url" >> "$filepath"

    exit_status="$?"

    # download finished
    [ $exit_status -eq 22 ] && break;

    echo "$exit_status"
    # other exceptions
    [ $exit_status -gt 0 ] && echo "Unknown exit status: $exit_status. Aborting..." && exit 1

    i=$(($i + 1))
done
echo "Finished downloading!"
