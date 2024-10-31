#!/bin/bash
function bluetooth {
	options="JBL Tune 500BT\nGalaxy Buds FE"
	selected=$(echo -e $options | tofi "$@" )
	if [[ $selected = "JBL Tune 500BT" ]]; then 
		bluetoothctl connect F4:BC:DA:54:2A:C7
	elif [[ $selected = "Galaxy Buds FE" ]]; then
		bluetoothctl connect 54:10:4F:31:B4:84
	fi
}
bluetooth "$@"
