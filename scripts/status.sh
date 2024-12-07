#!/bin/bash

echo '{"version":1}' 
echo '['  
echo '[],'

while true; do
    mem_usage=$(free | awk '/Mem/ {printf("%.0f%%", $3/$2 * 100)}')
    date_time=$(date +'%Y-%m-%d %X')
    batt_perc=$(acpi -b | awk -F', ' '{print $2}')

    echo "[{\"full_text\":\"Bat: $batt_perc | Mem: $mem_usage | $date_time\"}],"
    sleep 1
done
