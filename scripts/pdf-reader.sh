#!/bin/bash

function open_document {
    files=$(ls ~/Documents)

    selected=$(echo "$files" | wmenu "$@")

    if [[ -n $selected ]]; then
        zathura "$HOME/Documents/$selected"
    fi
}

open_document "$@"
