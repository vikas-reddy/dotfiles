#!/bin/bash
#
# Vikas Reddy @ http://vikas-reddy.blogspot.in/2012/04/bypass-proxy-servers-file-size-download.html
#
#
# Usage:
#     ./curl-multi-url.sh -d OUTPUT_DIRECTORY -u USER_AGENT http://url-1/ http://url-2/;
#     ./curl-multi-url.sh -f FILE_NAME http://url-1/;
#     Arguments -f, -d and -u are optional
#
#

# Defaults
fsize_limit=$((14*1024*1024))
user_agent="Firefox/10.0"
output_dir="."


# Command-line options
while getopts 'f:d:u:' opt "$@"; do
    case "$opt" in
        f) filename="$OPTARG"  ;;
        d) output_dir="$OPTARG";;
        u) user_agent="$OPTARG";;
    esac
done
shift $((OPTIND - 1))


# output directory check
if [ -d "$output_dir" ]; then
    echo "Downloading all files to '$output_dir'"
else
    echo "Target directory '$output_dir' doesn't exist. Aborting..."
    exit 1
fi;


for url in "$@"; do
    [ -z "$filename" ] && \
        filename="$(echo "$(echo "$url" | sed -r 's|^.*/([^/]+)$|\1|')" | echo -e "$(sed 's/%/\\x/g')")"
    filepath="$output_dir/$filename"

    # Avoid overwriting the file
    if [[ -f "$filepath" ]]; then
        echo -n "'$filepath' already exists. Do you want to overwrite it? [y/n] "; read response
        [ -z "$(echo "$response" | grep -i "^y")" ] && continue
    else
        cat /dev/null > "$filepath"
    fi

    echo -e "\nDownload of $url started..."
    echo -e "\nSaving to $filepath..."
    i=1
    while true; do   # infinite loop, until the file is fully downloaded

        # setting the range
        [ $i -eq 1 ] && start=0 || start=$(( $fsize_limit * ($i - 1) + 1))
        stop=$(( $fsize_limit * i ))

        # downloading
        curl --fail \
             --location \
             --progress-bar \
             --user-agent "$user_agent" \
             --range "$start"-"$stop" \
             "$url" >> "$filepath";

        exit_status="$?"

        # download finished
        [ $exit_status -eq 22 ] && echo -e "Saved $filepath\n" && break

        # other exceptions
        [ $exit_status -gt 0 ] && echo -e "Unknown exit status: $exit_status. Aborting...\n" && break

        i=$(($i + 1))
    done
done
