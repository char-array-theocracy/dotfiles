#!/bin/bash

SOURCE_DIR="/home/clem/Projects/NIER"
DEST_USER="clem"
DEST_HOST="192.168.1.155"
DEST_DIR="~/"

inotifywait -m -r -e modify,create,delete,move "$SOURCE_DIR" --format '%w%f' |
while read FILE
do
    echo "Detected change in $FILE. Syncing..."
    rsync -az --delete "$SOURCE_DIR" "$DEST_USER@$DEST_HOST:$DEST_DIR"
done

