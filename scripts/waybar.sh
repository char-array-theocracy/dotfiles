#!/bin/bash
while true; do
    waybar -c /home/clem/.config/waybar/config.jsonc -s /home/clem/.config/waybar/style.css
    echo "Waybar crashed. Restarting in 1 second..." >&2
    sleep 1
done

