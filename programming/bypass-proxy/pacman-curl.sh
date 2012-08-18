#!/bin/bash
#
# Vikas Reddy @
# http://vikas-reddy.blogspot.in/2012/04/bypass-proxy-servers-file-size-download.html
#
#

# Asynchronously (as a different process) display the filesize continously
# (once per second).
# * Contains an infinite loop; runs as long as this script is active
# * Takes one argument, the total filepath
async_display_size() {
    PARENT_PID=$BASHPID
    {
        while true; do
            echo -n "$(du -sh "$1")"
            echo -ne '\r'
            sleep 1

            # break if the current script is not running
            [[ -z "$(ps x | grep -E "^\s+$PARENT_PID")" ]] && break
        done
    }&
    updater_pid="$!"
}

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

# Exit if no URL is provided
[[ $# -eq 0 ]] && exit

# Only one argument, please!
url="$1"

[ -z "$filename" ] && \
    filename="$(echo "$(echo "$url" | sed -r 's|^.*/([^/]+)$|\1|')" | echo -e "$(sed 's/%/\\x/g')")"
filepath="${output_dir%/}/$filename"

# Overwriting the file
truncate --size 0 "$filepath"

# Asynchronously (as a different process) start displaying the filesize
# even before the download gets started!
async_display_size "$filepath"

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
         "$url" >> "$filepath" 2> /dev/null;

    exit_status="$?"

    # download finished
    [ $exit_status -eq 22 ] && echo -e "$(du -sh "$filepath")... done!" && break

    # other exceptions
    [ $exit_status -gt 0 ] && echo -e "Unknown exit status: $exit_status. Aborting...\n" && break

    i=$(($i + 1))

done
