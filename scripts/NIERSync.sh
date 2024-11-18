#!/bin/bash

SOURCE_DIR="/home/clem/Projects/NIER"
DEST_USER="clem"
DEST_HOST="192.168.1.155"
DEST_DIR="~/"
DEBOUNCE_INTERVAL=5       # Minimum time between syncs in seconds
PERIODIC_SYNC_INTERVAL=20 # Periodic sync time in seconds
CHANGE_DELAY=1            # Delay after detecting changes before syncing

LAST_SYNC_TIME=0          # Keeps track of the last sync time
LAST_CHANGE_TIME=0        # Tracks the time of the last detected change
SYNC_PENDING=false        # Indicates if a sync is pending due to changes

# Function to perform the rsync
perform_sync() {
    echo "Performing sync..."
    rsync -az --update "$SOURCE_DIR" "$DEST_USER@$DEST_HOST:$DEST_DIR"
}

# Perform initial full sync with --delete
echo "Initial sync: forcing full sync with --delete"
rsync -az --delete "$SOURCE_DIR" "$DEST_USER@$DEST_HOST:$DEST_DIR"

# Monitor source directory for changes
inotifywait -m -r -e modify,create,delete,move "$SOURCE_DIR" --format '%w%f' |
while read -r FILE
do
    CURRENT_TIME=$(date +%s)
    echo "Detected change in $FILE. Queuing sync after $CHANGE_DELAY second(s)..."

    LAST_CHANGE_TIME=$CURRENT_TIME
    SYNC_PENDING=true
done &

# Background process to handle delayed syncs
while true; do
    sleep 1  # Check every second
    CURRENT_TIME=$(date +%s)

    # Handle delayed syncs
    if $SYNC_PENDING && (( CURRENT_TIME - LAST_CHANGE_TIME >= CHANGE_DELAY )); then
        if (( CURRENT_TIME - LAST_SYNC_TIME >= DEBOUNCE_INTERVAL )); then
            echo "Performing delayed sync after change delay."
            perform_sync
            LAST_SYNC_TIME=$CURRENT_TIME
            SYNC_PENDING=false
        else
            echo "Debouncing: Waiting for minimum sync interval."
        fi
    fi

    # Perform periodic syncs
    if (( CURRENT_TIME - LAST_SYNC_TIME >= PERIODIC_SYNC_INTERVAL )); then
        echo "Periodic sync: Ensuring consistency..."
        perform_sync
        LAST_SYNC_TIME=$CURRENT_TIME
    fi
done

