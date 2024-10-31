#!/bin/bash

BLUE=$'\033[1;36m'
NC=$'\033[0m'

if [ "$(id -u)" != 0 ]; then
  echo "${BLUE}❄ Please run this script as root or using sudo!${NC}"
  exit 1
fi

echo -e "${BLUE}❄ Updating xbps packages...${NC}"
xbps-install -Su
echo -e "${BLUE}❄ Updating flatpaks...${NC}"
flatpak update
echo -e "${BLUE}❄ Applying wayland patch to flatpaks...${NC}"
sed -i 's|exec /usr/bin/flatpak run|exec /usr/bin/flatpak run --socket=wayland|g' /var/lib/flatpak/exports/bin/*
echo -e "${BLUE}❄ Done.${NC}"
