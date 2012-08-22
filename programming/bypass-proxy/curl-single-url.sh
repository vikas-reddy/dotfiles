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
        until [[ -z "$(ps x | grep -E "^\s*$PARENT_PID")" ]]; do
            # Redraw the `du` line every second
            erase_line
            echo -n "$(du -sh "$1") "
            sleep 1
        done
    }&
    updater_pid="$!"
}

# Defaults
fsize_limit=$((1*1024*1024)) # 14MB
user_agent="Firefox/10.0"
output_dir="."
ask_confirmtion=true
resume=false


# Command-line options
while getopts 'f:d:u:yc' opt "$@"; do
    case "$opt" in
        f) filename="$OPTARG"    ;;
        d) output_dir="$OPTARG"  ;;
        u) user_agent="$OPTARG"  ;;
        y) ask_confirmtion=false ;;
        c) resume=true           ;;
    esac
done
shift $((OPTIND - 1))

# Exit if no URL or filename argument is provided
if [[ $# -eq 0 ]] || [[ -z "$filename" ]]; then
    exit
fi

# Only one argument, please!
url="$1"

# Output directory checking
if ! [[ -d "$output_dir" ]]; then
    echo "Output directory "$output_dir" doesn't exist."
    echo "Give a valid one! Aborting..."
    exit
fi

# Setting the full filepath
filepath="${output_dir%/}/$filename"

# Avoid overwriting the file
if [[ -e "$filepath" ]]; then
    echo -n "'$filepath' already exists. [Overwrite/Resume/Abort] [o/r/A]? "; read response

    if [[ -n "$( echo "$response" | egrep -i "^o" )" ]]; then

        # Truncate the output file
        truncate --size 0 "$filepath"

    elif [[ -z "$( echo "$response" | egrep -i "^r" )" ]]; then

        # Abort the process
        echo "Abort"
        exit
    fi
else
    # Create the output file
    truncate --size 0 "$filepath"
fi


# Asynchronously (as a different process) start displaying the filesize
# even before the download is started!
async_display_size "$filepath"

# Where to start from: Resume or Start?
if $resume; then
  start_from=$(( $(du -b "$filepath" | sed -r 's/^\s*([0-9]+).*$/\1/') + 1 ))
  i=$(( $start_from / $fsize_limit + 1))
else
  i=1
fi

# infinite loop, until the file is fully downloaded
for (( ; 1; i++ )); do

    # setting the range
    if [[ -n $start_from ]]; then
        start=$(( $start_from - 1 )) # (-1) ?? Don't why!!
        unset start_from
    else
        [ $i -eq 1 ] && start=0 || start=$(( $fsize_limit * ($i - 1) + 1))
    fi
    stop=$(( $fsize_limit * i ))

    # downloading
    curl --fail \
         --location \
         --user-agent "$user_agent" \
         --range "$start"-"$stop" \
         "$url" >> "$filepath" 2> /dev/null; # No progress bars and error msgs, please!

    # catching the exit status
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

done
