#!/bin/bash

ram_usage=$(free -h --si | awk '/Mem:/ {print $3 "/" $2}')

cpu_usage=$(top -bn1 | grep "Cpu(s)" | \
            sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \
            awk '{print 100 - $1"%"}')

date_time=$(date +"%Y-%m-%d %H:%M:%S")

message="RAM Usage: $ram_usage\nCPU Usage: $cpu_usage\nDate & Time: $date_time"

notify-send -t 6000 "System Info" "$message"

