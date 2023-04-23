#!/bin/bash
# Sets lockscreen for betterlockscreen

WALLPAPERS="${WALLPAPERS:-${HOME}/.local/share/wallpapers/Wallpapers}"
betterlockscreen -u "${WALLPAPERS}" -- display 1 --span 2>&1 &

