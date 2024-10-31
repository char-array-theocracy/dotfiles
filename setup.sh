#!/bin/bash

# Check if the Script is Running as Root
if [ "$(id -u)" -eq 0 ]; then
  echo "Please do not run this script as root or using sudo!"
  exit 1
fi

# Check if the Script is Running on tty1
if [ "$(tty)" = "/dev/tty1" ]; then
  echo "This script should not be run on tty1."
  exit 1
fi

sudo bash ./commands.sh
