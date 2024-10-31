#!/bin/bash

CONFIG="root"

snapper -c "$CONFIG" create --description "Weekly Snapshot - $(date '+%Y-%m-%d')"

snapper -c "$CONFIG" list --columns number,date --csv-output | tail -n +2 | \
awk -F ';' -v date="$(date --date='-1 month' +%F)" '$2 < date {print $1}' | \
xargs -r snapper -c "$CONFIG" delete
