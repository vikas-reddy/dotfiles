#!/bin/bash
#
# Vikas Reddy @
# http://vikas-reddy.blogspot.in/2012/04/bypass-proxy-servers-file-size-download.html
#
#

# Erase the current line in stdout
erase_line() {
    echo -ne '\r\033[K'
}

# Asynchronously (as a different process) display the filesize continously
# (once per second).
# * Contains an infinite loop; runs as long as this script is active
# * Takes one argument, the total filepath
async_display_size() {
    PARENT_PID=$BASHPID
    {
        # Run until this script ends
        until [[ -z "$(ps x | grep -E "^\s+$PARENT_PID")" ]]; do
            # Redraw the `du` line every second
            erase_line
            echo -n "$(du -sh "$1") "
            sleep 1
        done
    }&
    updater_pid="$!"
}

# Defaults
fsize_limit=$((14*1024*1024)) # 14MB
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

# Exit if no URL is provided
[[ $# -eq 0 ]] && exit

# Only one argument, please!
url="$1"

# Guessing the output filename
[ -z "$filename" ] && \
    filename="$(echo "$(echo "$url" | sed -r 's|^.*/([^/]+)$|\1|')" | echo -e "$(sed 's/%/\\x/g')")"
filepath="${output_dir%/}/$filename"

# Overwriting the file
truncate --size 0 "$filepath"

# Asynchronously (as a different process) start displaying the filesize
# even before the download is started!
async_display_size "$filepath"

i=1
while true; do   # infinite loop, until the file is fully downloaded

    # setting the range
    [ $i -eq 1 ] && start=0 || start=$(( $fsize_limit * ($i - 1) + 1))
    stop=$(( $fsize_limit * i ))

    # downloading
    curl --fail \
         --location \
         --user-agent "$user_agent" \
         --range "$start"-"$stop" \
         "$url" >> "$filepath" 2> /dev/null; # No progress bars and error msgs, please!

    exit_status="$?"

    if [[ $exit_status -eq 22 ]] || [[ $exit_status -eq 36 ]]; then
        # Download finished
        erase_line
        echo "$(du -sh "$filepath")... done!"
        break
    elif [[ $exit_status -gt 0 ]]; then
        # Unknown exit status! Something has gone wrong
        erase_line
        echo "Unknown exit status: $exit_status. Aborting..."
        break
    fi

    i=$(($i + 1))

done
