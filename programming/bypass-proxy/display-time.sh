#!/bin/bash

async_display_time() {
    {
        while true; do
            echo -n "$(date) "
            echo -ne '\r'
        done
    }&
    printer_pid="$!"
}

echo "before async..."
async_display_time
sleep 3
kill $printer_pid 1>/dev/null 2>&1
