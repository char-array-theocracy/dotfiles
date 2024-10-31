#!/bin/bash
function keyboard {
	options="us\nlt"
	selected=$(echo -e $options | tofi "$@" )
	if [[ $selected = "us" ]]; then
		riverctl keyboard-layout us
		setxkbmap us
		pkill -RTMIN+10 waybar
	elif [[ $selected = "lt" ]]; then
		riverctl keyboard-layout lt
		setxkbmap lt
		pkill -RTMIN+10 waybar
	fi
}
keyboard "$@"
