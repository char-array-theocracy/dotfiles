#!/bin/bash
function powermenu {
	options="Shutdown\nRestart\nHibernate"
	selected=$(echo -e $options | tofi "$@" )
	if [[ $selected = "Shutdown" ]]; then 
		loginctl poweroff
	elif [[ $selected = "Restart" ]]; then
		loginctl reboot
	elif [[ $selected = "Hibernate" ]]; then
		loginctl hibernate
	fi
}
powermenu "$@"
