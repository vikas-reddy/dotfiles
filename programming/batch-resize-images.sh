#!/bin/bash

SOURCE_DIR="Pictures"
DEST_DIR="Pictures Resized"

# Cloning the empty directory tree
find $SOURCE_DIR -type d | while read sdir; do
  ddir="$(echo "$sdir" | sed "s/$SOURCE_DIR/$DEST_DIR/")"
  if [[ ! -d "$ddir" ]]; then
    echo mkdir -p "$ddir";
    mkdir -p "$ddir";
  fi
done

# Actual conversion
find $SOURCE_DIR -type f -name '*.JPG' | while read sfile; do
  dfile="$(echo "$sfile" | sed "s/$SOURCE_DIR/$DEST_DIR/")"
  if [[ ! -f "$dfile" ]]; then
    echo convert -resize 1280x1024 "$sfile" "$dfile";
    convert -resize 1280x1024 "$sfile" "$dfile";
  fi
done
